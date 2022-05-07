//
//  LocationsView.swift
//  ShoppingList
//
//  Created by Jerry on 5/6/20.
//  Copyright © 2020 Jerry. All rights reserved.
//

import SwiftUI

struct LocationsView: View {
	
	@Environment(\.dismiss) var dismiss: DismissAction
	
		// this is the @FetchRequest that ties this view to CoreData Locations
	@FetchRequest(fetchRequest: Location.allLocationsFR())
	private var locations: FetchedResults<Location>
	
		// state to trigger a sheet to appear that adds a new location
	@State private var identifiableSheetItem: IdentifiableSheetItem?
	
	// state to trigger an Alert to confirm deleting a Location
	@State private var confirmDeleteLocationAlert: ConfirmDeleteLocationAlert?
//	@StateObject private var alertModel = AlertModel()
	
	var body: some View {
		VStack(spacing: 0) {
			
			Rectangle()
				.frame(height: 1)
			
			List {
				Section(header: Text("Locations Listed: \(locations.count)").sectionHeader()) {
					ForEach(locations) { location in
						NavigationLink {
							ModifyExistingLocationView(location: location)
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
		.alert(item: $confirmDeleteLocationAlert) { item in item.alert() }
			//		.alert(alertModel.title, isPresented: $alertModel.isPresented, presenting: alertModel,
			//					 actions: { model in model.actions() },
			//					 message: { model in model.message })
		.sheet(item: $identifiableSheetItem) { item in
			NavigationView {
				item.content()
			}
		}
		
		.onAppear {
			logAppear(title: "LocationsTabView")
			handleOnAppear()
		}
		.onDisappear() {
			logDisappear(title: "LocationsTabView")
			PersistentStore.shared.saveContext()
		}
		
	} // end of var body: some View
	
	func deleteLocations(at offsets: IndexSet) {
		guard let firstIndex = offsets.first else { return }
		let location = locations[firstIndex]
		if !location.isUnknownLocation {
			confirmDeleteLocationAlert = ConfirmDeleteLocationAlert(location: location)
			//alertModel.updateAndTrigger(for: .confirmDeleteLocation(location, nil))
		}
	}
	
	func handleOnAppear() {
		// because the unknown location is created lazily, this will make sure that
		// we'll not be left with an empty screen
		if locations.count == 0 {
			let _ = Location.unknownLocation()
		}
	}
	
	// defines the usual "+" button to add a Location
	func addNewButton() -> some View {
		Button {
			identifiableSheetItem = AddNewLocationSheetItem(dismiss: { identifiableSheetItem = nil })
		} label: {
			Image(systemName: "plus")
		}
	}
	
}
