	//
	//  AddNewItemView.swift
	//  ShoppingList
	//
	//  Created by Jerry on 12/8/21.
	//  Copyright © 2021 Jerry. All rights reserved.
	//

import SwiftUI

struct AddNewItemView: View {
		// we need this so we can dismiss ourself -- we are presented as a .sheet()
	@Environment(\.presentationMode) var presentationMode
	
		// addItemToShoppingList just means that by default, a new item will be added to
		// the shopping list, and so this is initialized to true.
		// however, if inserting a new item from the Purchased item list, perhaps
		// you might want the new item to go to the Purchased item list (?)
	var addItemToShoppingList: Bool = true
	
		// we need all locations so we can populate the Picker.  it may be curious that i
		// use a @FetchRequest here; the problem is that if this Add/ModifyItem view is open
		// to add a new item, then we tab over to the Locations tab to add a new location,
		// we have to be sure the Picker's list of locations is updated.
	@FetchRequest(fetchRequest: Location.allLocationsFR())
	private var locations: FetchedResults<Location>
	
	@ObservedObject var editableItem: Item
	
		// custom init here to set up a tentative Item to add
	init(initialItemName: String? = nil, location: Location? = nil) {
		editableItem = Item.addNewItem()
			// need to fill in details for the new Item
		if let location = location {
			editableItem.location = location
		} else {
			editableItem.location = Location.unknownLocation()
		}
	}
	
	var body: some View {
		
			// show the Form, noting that we cannot delete this Item
		EditableItemView(editableItem: editableItem, itemExists: false)
			.navigationBarTitle("Add New Item", displayMode: .inline)
			.navigationBarBackButtonHidden(true)
			.toolbar {
				ToolbarItem(placement: .cancellationAction) { cancelButton() }
				ToolbarItem(placement: .confirmationAction) { saveButton() }
			}
	}
	
		// the cancel button
	func cancelButton() -> some View {
		Button("Cancel") {
			presentationMode.wrappedValue.dismiss()
		}
	}
	
		// the save button
	func saveButton() -> some View {
		Button("Save") {
			commitDataEntry()
		}
		.disabled(!editableItem.canBeSaved)
	}
	
		// called when you tap the Save button.
	func commitDataEntry() {
		presentationMode.wrappedValue.dismiss()
	}
	
}


