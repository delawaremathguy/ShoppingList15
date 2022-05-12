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
		//@ObservedObject var alertModel: AlertModel
	var deleteActionTrigger: (() -> ())?
	
		// definition of whether we can offer a deletion option in this view
		// (it's a real location that's not the unknown location)
	private var locationCanBeDeleted: Bool {
		draftLocation.representsExistingLocation
			&& !draftLocation.associatedLocation.isUnknownLocation
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
					TextField("Location name", text: $draftLocation.locationName)
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
			
				// Section 2: Delete button, if the data is associated with an existing Location
			if locationCanBeDeleted {
				Section(header: Text("Location Management").sectionHeader()) {
					SLCenteredButton(title: "Delete This Location")  {
						//alertModel.type = .confirmDeleteLocation(draftLocation.associatedLocation, { dismiss() })
						deleteActionTrigger?()
					}
					.foregroundColor(Color.red)
				}
			} // end of Section 2
			
//				 Section 3: Items assigned to this Location, if we are editing a Location
			if draftLocation.representsExistingLocation {
				SimpleItemsList(location: draftLocation.associatedLocation,
												isAddNewItemSheetShowing: $isAddNewItemSheetShowing)
			}
			
		} // end of Form
		.sheet(isPresented: $isAddNewItemSheetShowing) {
			AddNewItemView(location: draftLocation.associatedLocation, dataManager: dataManager) {
				isAddNewItemSheetShowing = false
			}
		}

	}

}

struct SimpleItemsList: View {
	
	@EnvironmentObject private var dataManager: DataManager
	var items: [Item] { dataManager.items.filter({ $0.location == location }) }

	var location: Location
	
	@Binding var isAddNewItemSheetShowing: Bool
	
	init(location: Location, isAddNewItemSheetShowing: Binding<Bool>) {
		self.location = location
		_isAddNewItemSheetShowing = isAddNewItemSheetShowing
	}
	
	var body: some View {
		Section(header: ItemsListHeader()) {
			ForEach(items) { item in
				NavigationLink {
					ModifyExistingItemView(item: item, dataManager: dataManager)
				} label: {
					Text(item.name)
				}
			}
		}
	}
	
	func ItemsListHeader() -> some View {
		HStack {
			Text("At this Location: \(items.count) items").sectionHeader()
			Spacer()
			Button {
				isAddNewItemSheetShowing = true
			} label: {
				Image(systemName: "plus")
			}
		}
	}
}
