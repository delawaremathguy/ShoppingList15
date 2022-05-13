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
	var locations: [Location] { dataManager.locations }
	
		// this is the @FetchRequest that ties this view to CoreData Locations
//	@FetchRequest(fetchRequest: Location.allLocationsFR())
//	private var locations: FetchedResults<Location>
	
		// state to trigger a sheet to appear that adds a new location
	@State private var identifiableSheetItem: IdentifiableSheetItem?
	
		// states to trigger an alert to appear to delete a location and set up title and message
	@State private var isDeleteConfirmationPresented = false
	@State private var locationToDelete: Location?
	
	var body: some View {
		VStack(spacing: 0) {
			
			Rectangle()
				.frame(height: 1)
			
			List {
				Section(header: Text("Locations Listed: \(locations.count)").sectionHeader()) {
					ForEach(locations) { location in
						NavigationLink {
							ModifyExistingLocationView(location: location, dataManager: dataManager)
						} label: {
							LocationRowView(rowData: LocationRowData(location: location))
						} // end of NavigationLink
					} // end of ForEach
					.onDelete(perform: deleteLocations)
				} // end of Section
			} // end of List
			.listStyle(InsetGroupedListStyle())
			
			Divider() // keeps list from running through tab bar (!)
		} // end of VStack
		.navigationBarTitle("Locations")
		.toolbar {
			ToolbarItem(placement: .navigationBarTrailing, content: addNewButton)
		}
		.alert(alertTitle(), isPresented: $isDeleteConfirmationPresented) {
			Button("OK", role: .destructive) {
				withAnimation { dataManager.delete(location: locationToDelete!) }
			}
		} message: { Text(alertMessage()) }
		.sheet(item: $identifiableSheetItem) { item in
			item.content().environmentObject(dataManager)
		}
		.onAppear {
			logAppear(title: "LocationsTabView")
			handleOnAppear()
		}
		.onDisappear() {
			logDisappear(title: "LocationsTabView")
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
			return "Are you sure you want to delete the Location named \'\(location.name)\'? All items at this location will be moved to the Unknown Location.  This action cannot be undone."
		}
		return ""
	}
	
	func deleteLocations(at offsets: IndexSet) {
		guard let firstIndex = offsets.first else { return }
		let location = locations[firstIndex]
		if !location.isUnknownLocation {
			locationToDelete = location
			isDeleteConfirmationPresented = true
		}
	}
	
	func handleOnAppear() {
		// because the unknown location is created lazily, this will make sure that
		// we'll not be left with an empty screen
		if locations.count == 0 {
			let _ = dataManager.unknownLocation
		}
	}
	
	// defines the usual "+" button to add a Location
	func addNewButton() -> some View {
		Button {
			identifiableSheetItem = AddNewLocationSheetItem(dataManager: dataManager, dismiss: { identifiableSheetItem = nil })
		} label: {
			Image(systemName: "plus")
		}
	}
	
}
