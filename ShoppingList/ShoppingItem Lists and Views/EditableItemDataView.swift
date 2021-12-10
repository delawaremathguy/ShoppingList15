	//
	//  EditableItemView.swift
	//  ShoppingList
	//
	//  Created by Jerry on 12/8/21.
	//  Copyright © 2021 Jerry. All rights reserved.
	//

import SwiftUI

// the EditableItemDataView allows the user to edit the fields associated with an Item.
struct EditableItemDataView: View {
	
	@Binding var editableItemData: EditableItemData
	private var deleteActionTrigger: (() -> ())?
	private var itemExists: Bool
	
		// we need all locations so we can populate the Picker.
	@FetchRequest(fetchRequest: Location.allLocationsFR())
	private var locations: FetchedResults<Location>
	
		// incoming parameters
		// -- the item we're editing (this is a pseudo-live edit)
		// -- whether the item can be deleted and what to do after the user deletes the Item
	init(editableItemData: Binding<EditableItemData>, deleteActionTrigger: (() -> ())?) {
		_editableItemData = editableItemData
		self.deleteActionTrigger = deleteActionTrigger
		itemExists = (deleteActionTrigger != nil)
	}
	
	var body: some View {
		Form {
				// Section 1. Basic Information Fields
			Section(header: Text("Basic Information").sectionHeader()) {
				
				HStack(alignment: .firstTextBaseline) {
					SLFormLabelText(labelText: "Name: ")
					TextField("Item name", text: $editableItemData.name)
				}
				
				Stepper(value: $editableItemData.quantity, in: 1...10) {
					HStack {
						SLFormLabelText(labelText: "Quantity: ")
						Text("\(editableItemData.quantity)")
					}
				}
				
				Picker(selection: $editableItemData.location, label: SLFormLabelText(labelText: "Location: ")) {
					ForEach(locations) { location in
						Text(location.name).tag(location)
					}
				}
				
				HStack(alignment: .firstTextBaseline) {
					Toggle(isOn: $editableItemData.onList) {
						SLFormLabelText(labelText: "On Shopping List: ")
					}
				}
				
				HStack(alignment: .firstTextBaseline) {
					Toggle(isOn: $editableItemData.isAvailable) {
						SLFormLabelText(labelText: "Is Available: ")
					}
				}
				
				if itemExists {
					HStack(alignment: .firstTextBaseline) {
						SLFormLabelText(labelText: "Last Purchased: ")
						Text("\(editableItemData.dateText)")
					}
				}
				
			} // end of Section 1
			
				// Section 2. Item Management (Delete), if present
			if itemExists {
				Section(header: Text("Shopping Item Management").sectionHeader()) {
					SLCenteredButton(title: "Delete This Shopping Item",
													 action: { deleteActionTrigger?() }
					)
						.foregroundColor(Color.red)
				} // end of Section 2
			} // end of if ...
			
		} // end of Form
	}
}

