//
//  LocationsView.swift
//  ShoppingList
//
//  Created by Jerry on 5/6/20.
//  Copyright © 2020 Jerry. All rights reserved.
//

import SwiftUI

struct LocationsTabView: View {
	
	// this is the @FetchRequest that ties this view to CoreData Locations
	@FetchRequest(fetchRequest: Location.allLocationsFR())
	private var locations: FetchedResults<Location>
	
	// local state to trigger a sheet to appear to add a new location
	@State private var isAddNewLocationSheetShowing = false
	
	// parameters to control triggering an Alert and defining what action
	// to take upon confirmation
	//@State private var confirmationAlert = ConfirmationAlert(type: .none)
	@State private var confirmDeleteLocationAlert: ConfirmDeleteLocationAlert?

	// this implements a seemingly well-known strategy to get the list drawn
	// cleanly without any highlighting
	@State private var listDisplayID = UUID()
	
	var body: some View {
		VStack(spacing: 0) {
			
			// 1. add new location "button" is at top.  note that this will put up the
			// AddorModifyLocationView inside its own NavigationView (so the Picker will work!)
			Button(action: { isAddNewLocationSheetShowing = true }) {
				Text("Add New Location")
					.foregroundColor(Color.blue)
					.padding(10)
			}
			.sheet(isPresented: $isAddNewLocationSheetShowing) {
				NavigationView { AddOrModifyLocationView() }
			}
			
			Rectangle()
				.frame(height: 1)
			
			
			// 2. then the list of locations
			List {
				Section(header: Text("Locations Listed: \(locations.count)").sectionHeader()) {
					ForEach(locations) { location in
						NavigationLink(destination: AddOrModifyLocationView(location: location)) {
							LocationRowView(rowData: LocationRowData(location: location))
								.contextMenu { contextMenuButton(for: location) }
						} // end of NavigationLink
					} // end of ForEach
				} // end of Section
			} // end of List
			.listStyle(InsetGroupedListStyle())
			
			Divider()
		} // end of VStack
		.navigationBarTitle("Locations")
		.toolbar { ToolbarItem(placement: .navigationBarTrailing, content: addNewButton) }
		//.alert(isPresented: $confirmationAlert.isShowing) { confirmationAlert.alert() }
		.alert(item: $confirmDeleteLocationAlert) { item in item.alert() }
		.onAppear {
			logAppear(title: "LocationsTabView")
			handleOnAppear()
		}
		.onDisappear() {
			logDisappear(title: "LocationsTabView")
			PersistentStore.shared.saveContext()
		}
		
	} // end of var body: some View
	
	func handleOnAppear() {
		// updating listDisplayID makes SwiftUI think the list of locations is a whole new
		// list, thereby removing any highlighting.
		listDisplayID = UUID()
		// because the unknown location is created lazily, this will make sure that
		// we'll not be left with an empty screen
		if locations.count == 0 {
			let _ = Location.unknownLocation()
		}
	}
	
	// defines the usual "+" button to add a Location
	func addNewButton() -> some View {
		Button(action: { isAddNewLocationSheetShowing = true }) {
			Image(systemName: "plus")
				.font(.title2)
		}
	}
	
	// a convenient way to build this context menu without having it in-line
	// in the view code above
	@ViewBuilder
	func contextMenuButton(for location: Location) -> some View {
		Button(action: {
			if !location.isUnknownLocation {
				confirmDeleteLocationAlert = ConfirmDeleteLocationAlert(location: location)
				//confirmationAlert.trigger(type: .deleteLocation(location))
			}
		}) {
			Text(location.isUnknownLocation ? "(Cannot be deleted)" : "Delete This Location")
			Image(systemName: location.isUnknownLocation ? "trash.slash" : "trash")
		}
	}
	
}
