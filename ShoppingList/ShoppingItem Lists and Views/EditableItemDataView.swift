	//
	//  EditableItemView.swift
	//  ShoppingList
	//
	//  Created by Jerry on 12/8/21.
	//  Copyright © 2021 Jerry. All rights reserved.
	//

import SwiftUI

struct EditableItemDataView: View {
	
		// incoming parameters
		// -- the item we're editing (this is a live edit)
		// -- whether the item can be deleted (true if the item exists, false if we're adding a new item)
		//	@ObservedObject var editableItem: Item
	@Binding var editableItemData: EditableItemData
	private var deleteActionTrigger: (() -> ())?
	private var itemExists: Bool
	
		// we need all locations so we can populate the Picker.  it may be curious that i
		// use a @FetchRequest here; the problem is that if this Add/ModifyItem view is open
		// to add a new item, then we tab over to the Locations tab to add a new location,
		// we have to be sure the Picker's list of locations is updated.
	@FetchRequest(fetchRequest: Location.allLocationsFR())
	private var locations: FetchedResults<Location>
	
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
				
				// comment on this one: changing this from either the shopping list or the purchased list
				// on a live edit with an existing item will pop you back in the navigation, because this
				// is a live edit and this will change the basic content of those lists ... that may not be
				// what we want ... so how to watch for this?  we might treat this one as a local variable
				// and only make this change once we leave??  perhaps this should be hidden in these
				// cases??
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

