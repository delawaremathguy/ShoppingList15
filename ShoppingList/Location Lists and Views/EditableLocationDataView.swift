	//
	//  EditableLocationDataView.swift
	//  ShoppingList
	//
	//  Created by Jerry on 12/10/21.
	//  Copyright © 2021 Jerry. All rights reserved.
	//

import SwiftUI

	// the EditableLocationDataView is a simple Form that allows the user to edit
	// the default fields for a new Location, of the fields associated with a Location
	// that already exists.
struct EditableLocationDataView: View {
	
	// incoming data = values for a Location + what action to take if the user
	// decides to delete the Location
	@ObservedObject var editableLocationData: EditableLocationData
	var deleteActionTrigger: (() -> ())?
	private var locationCanBeDeleted: Bool {
		editableLocationData.representsExistingLocation
			&& !editableLocationData.associatedLocation.isUnknownLocation
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
					TextField("Location name", text: $editableLocationData.locationName)
				}
				
				if editableLocationData.visitationOrder != kUnknownLocationVisitationOrder {
					Stepper(value: $editableLocationData.visitationOrder, in: 1...100) {
						HStack {
							SLFormLabelText(labelText: "Visitation Order: ")
							Text("\(editableLocationData.visitationOrder)")
						}
					}
				}
				
				ColorPicker("Location Color", selection: $editableLocationData.color)
			} // end of Section 1
			
				// Section 2: Delete button, if the data is associated with an existing Location
			if locationCanBeDeleted {
				Section(header: Text("Location Management").sectionHeader()) {
					SLCenteredButton(title: "Delete This Location")  {
						deleteActionTrigger?()
					}
					.foregroundColor(Color.red)
				}
			} // end of Section 2
			
//				 Section 3: Items assigned to this Location, if we are editing a Location
			if editableLocationData.representsExistingLocation {
				SimpleItemsList(location: editableLocationData.associatedLocation,
												isAddNewItemSheetShowing: $isAddNewItemSheetShowing)
			}
			
		} // end of Form
		.sheet(isPresented: $isAddNewItemSheetShowing) {
			NavigationView {
				AddNewItemView(location: editableLocationData.associatedLocation) {
					isAddNewItemSheetShowing = false
				}
			}
		}

	}

}

struct SimpleItemsList: View {
	
	@FetchRequest	private var items: FetchedResults<Item>
	@Binding var isAddNewItemSheetShowing: Bool
	
	init(location: Location, isAddNewItemSheetShowing: Binding<Bool>) {
		let request = Item.allItemsFR(at: location)
		_items = FetchRequest(fetchRequest: request)
		_isAddNewItemSheetShowing = isAddNewItemSheetShowing
	}
	
	var body: some View {
		Section(header: ItemsListHeader()) {
			ForEach(items) { item in
				NavigationLink(destination: ModifyExistingItemView(editableItem: item)) {
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
