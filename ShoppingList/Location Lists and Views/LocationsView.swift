//
//  LocationsView.swift
//  ShoppingList
//
//  Created by Jerry on 5/6/20.
//  Copyright © 2020 Jerry. All rights reserved.
//

import SwiftUI

struct LocationsView: View {
	
	@EnvironmentObject private var dataManager: DataManager
	var locationStructs: [LocationStruct] { dataManager.locationStructs }
		
		// states to trigger an alert to appear to delete a location and set up title and message
	@State private var isDeleteConfirmationPresented = false
	@State private var locationToDelete: LocationStruct?
	
	@State private var isSheetPresented = false
	
	var body: some View {
		VStack(spacing: 0) {
			
			Rectangle()
				.frame(height: 1)
			
			List {
				Section(header: Text("Locations Listed: \(locationStructs.count)").sectionHeader()) {
					ForEach(locationStructs) { locationStruct in
						NavigationLink {
							ModifyExistingLocationView(locationStruct: locationStruct, dataManager: dataManager)
						} label: {
							LocationRowView(locationStruct: locationStruct)
						} // end of NavigationLink
					} // end of ForEach
					.onDelete(perform: deleteLocations)
				} // end of Section
			} // end of List
			.listStyle(InsetGroupedListStyle())
			
			Divider() // keeps list from running through tab bar in iOS 15 (!)
		} // end of VStack
		.navigationBarTitle("Locations")
		.toolbar {
			ToolbarItem(placement: .navigationBarTrailing, content: addNewButton)
		}
		.alert(alertTitle(), isPresented: $isDeleteConfirmationPresented) {
			Button("OK", role: .destructive) {
				withAnimation { dataManager.delete(locationStruct: locationToDelete!) }
			}
		} message: { Text(alertMessage()) }
		.sheet(isPresented: $isSheetPresented) {
			AddNewLocationView(dataManager: dataManager) {
				isSheetPresented = false
			}
		}
		.onAppear {
			handleOnAppear()
		}
		.onDisappear() {
			dataManager.saveData()
		}
		
	} // end of var body: some View
	
	func alertTitle() -> String {
		if let location = locationToDelete {
			return "Delete \(location.name)?"
		}
		return ""
	}
	
	func alertMessage() -> String {
		if let location = locationToDelete {
			return "Are you sure you want to delete the Location named \'\(location.name)\'?" +
							"  All items at this location will be moved to the Unknown Location." +
							"This action cannot be undone."
		}
		return ""
	}
	
	func deleteLocations(at offsets: IndexSet) {
			// we do want to confirm doing this, so we opt to delete only the Location
			// that's first by index.  (do we really ever get multiple offsets here?)
		guard let firstIndex = offsets.first else { return }
		let locationStruct = locationStructs[firstIndex]
		if !locationStruct.isUnknownLocation {
			locationToDelete = locationStruct
			isDeleteConfirmationPresented = true
		}
	}
	
	func handleOnAppear() {
			// because the unknown location is created lazily, and may not have been
			// created yet, this will make sure we have an unknown location and that
			// the view will not be empty.
			//
			// this introduces a little bit of a problem: we may be creating one here,
			// and then find out that we already had one of these created in the cloud
			// that makes its way onto the device.
			// there are ways around that, but that's for another day.
		dataManager.assertUnknownLocationExists()
	}
	
	// defines the usual "+" button to add a Location
	func addNewButton() -> some View {
		SystemImageButton("plus") {
			isSheetPresented = true
		}
	}
	
}
