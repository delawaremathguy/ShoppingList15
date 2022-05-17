	//
	//  DraftLocationView.swift
	//  ShoppingList
	//
	//  Created by Jerry on 12/10/21.
	//  Copyright © 2021 Jerry. All rights reserved.
	//

import SwiftUI

	// the DraftLocationView is a simple Form that allows the user to edit
	// the default fields for a new Location, of the fields associated with a Location
	// that already exists.
struct DraftLocationView: View {
	@Environment(\.dismiss) var dismiss
	@EnvironmentObject private var dataManager: DataManager
	
		// incoming data = values for a Location + what action to take if the user
		// decides to delete the Location
	@ObservedObject var draftLocation: DraftLocation

		// control for confirmation alert
	@State private var isDeleteConfirmationPresented = false

		// we can only show a list of items associated with a draftLocation or offer
		// an option to delete the location associated with the draftLocation if
		// the draftLocation represents a real location.
	private var draftRepresentsRealLocation: Bool {
		guard let location = dataManager.location(associatedWith: draftLocation) else {
			return false
		}
		
			// note to future self.  we cannot delete the unknownLocation.  but, when the cloud
			// is in action, it's possible that we could wind up with more than one UL.
			// in that case, the resolution would be to move all the items from one UL to
			// the other, and then delete the UL with no items.  i'd not want to automate
			// that -- just leave it to the user.  so add the condition here:
			//
			// dataManager.locations.count(where: { $0.isUnknownLocation }) > 1
		return !location.isUnknownLocation
	}
	
		// trigger for adding a new item at this Location
	@State private var isAddNewItemSheetShowing = false

	var body: some View {
		Form {
				// 1: Name, Visitation Order, Colors.  These are shown for both an existing
				// location and a potential new Location about to be created.
			Section(header: Text("Basic Information").sectionHeader()) {
				HStack {
					SLFormLabelText(labelText: "Name: ")
					TextField("Location name", text: $draftLocation.name)
				}
				
				if draftLocation.visitationOrder != kUnknownLocationVisitationOrder {
					Stepper(value: $draftLocation.visitationOrder, in: 1...100) {
						HStack {
							SLFormLabelText(labelText: "Visitation Order: ")
							Text("\(draftLocation.visitationOrder)")
						}
					}
				}
				
				ColorPicker("Location Color", selection: $draftLocation.color)
			} // end of Section 1
			
				// Sections 2: Delete button, if we are editing a real Location
			if draftRepresentsRealLocation {
				Section(header: Text("Location Management").sectionHeader()) {
					SLCenteredButton(title: "Delete This Location")  {
						//alertModel.type = .confirmDeleteLocation(draftLocation.associatedLocation, { dismiss() })
						//deleteActionTrigger?()
						isDeleteConfirmationPresented = true
					}
					.foregroundColor(Color.red)
				} // end of Section
			} // end of if
			
			if let location = dataManager.location(associatedWith: draftLocation) {
				Section(header: ItemsListHeader(location: location)) {
					SimpleItemsList(location: location, isAddNewItemSheetShowing: $isAddNewItemSheetShowing)
				}
			}


		} // end of Form
		
			// note to self on this .sheet: it can only be triggered if the draftLocation is associated with a real Location
		.sheet(isPresented: $isAddNewItemSheetShowing) {
			AddNewItemView(dataManager: dataManager, draftLocation: draftLocation) {
				isAddNewItemSheetShowing = false
			}
		}
		
			// note to self on this .alert: it can only be triggered if the draftLocation is associated with a real Location
		.alert("Delete \(draftLocation.name)?", isPresented: $isDeleteConfirmationPresented) {
			Button("OK", role: .destructive) {
				dataManager.delete(location: dataManager.location(associatedWith: draftLocation)!)
			}
		} message: {
			Text("Are you sure you want to delete the Location named \'\(draftLocation.name)\'? All items at this location will be moved to the Unknown Location.  This action cannot be undone.")
		}

	} // end of var body: some View
	
	func ItemsListHeader(location: Location) -> some View {
		HStack {
			Text("At this Location: \(location.itemCount) items").sectionHeader()
			Spacer()
			SystemImageButton("plus") {
				isAddNewItemSheetShowing = true
			}
		}
	}

}

struct SimpleItemsList: View {
	
	@EnvironmentObject private var dataManager: DataManager
	var items: [Item] { dataManager.items.filter({ $0.location == location }) }

	var location: Location
	
		// our hook back to the parent view (the DraftLocationView) to add a new
		// Item at this Location.
	@Binding var isAddNewItemSheetShowing: Bool
	
	init(location: Location, isAddNewItemSheetShowing: Binding<Bool>) {
		self.location = location
		_isAddNewItemSheetShowing = isAddNewItemSheetShowing
	}
	
	var body: some View {
//		Section(header: ItemsListHeader()) {
			ForEach(items) { item in
				NavigationLink {
					ModifyExistingItemView(item: item, dataManager: dataManager)
				} label: {
					Text(item.name)
				}
			}
//		}
	}
	
//	func ItemsListHeader() -> some View {
//		HStack {
//			Text("At this Location: \(items.count) items").sectionHeader()
//			Spacer()
//			SystemImageButton("plus") {
//				isAddNewItemSheetShowing = true
//			}
//		}
//	}
}
