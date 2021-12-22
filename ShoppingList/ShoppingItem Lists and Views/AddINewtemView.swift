	//
	//  AddNewItemView.swift
	//  ShoppingList
	//
	//  Created by Jerry on 12/8/21.
	//  Copyright © 2021 Jerry. All rights reserved.
	//

import SwiftUI

// the AddNewItemView is opened via a sheet from both the ShoppingListView and the
// PurchasedItemTabView, within a NavigationView, to do as it says: add a new shopping item.
// the strategy is simple:
//
// -- create a default set of values for a new shopping item (a struct)
// -- the body shows a Form in which the user can edit the default data
// -- we supply buttons in the navigation bar to create a new item from the edited data
//      and to dismiss (which can also be accomplished just by pulling down on the sheet)
//
struct AddNewItemView: View {
	
		// a dismiss action.  we're a View presented using .sheet(item:) that was triggered by setting a
		// variable, so we need to be given a way to dismiss ourself (which normally is setting that
		// trigger to nil
	private var dismiss: () -> Void
	
		// this editableItemData struct contains all of the fields for a new Item that are needed from the User
	@State private var editableItemData: EditableItemData
	
		// custom init here to set up a tentative Item to add
	init(initialItemName: String? = nil, location: Location? = nil, dismiss: @escaping () -> Void) {
			// create working, editable Item data for a new Item, with the given suggested initial name and location
		let initialValue = EditableItemData(initialItemName: initialItemName, location: location)
		_editableItemData = State(initialValue: initialValue)
		// and stash away a dismiss function
		self.dismiss = dismiss
	}
	
	// the body is pretty short -- just call up a Form, adding a Cancel and Save button
	var body: some View {
		EditableItemDataView(editableItemData: $editableItemData, deleteActionTrigger: nil)
			.navigationBarTitle("Add New Item", displayMode: .inline)
			.toolbar {
				ToolbarItem(placement: .cancellationAction) { cancelButton() }
				ToolbarItem(placement: .confirmationAction) { saveButton() }
			}
	}
	
		// the cancel button just dismisses ourself
	func cancelButton() -> some View {
		Button { dismiss() } label: { Text("Cancel") }
	}
	
		// the save button saves the new item to the persistent store and dismisses ourself
	func saveButton() -> some View {
		Button {
			Item.update(using: editableItemData)
			dismiss()
		} label: {
			Text("Save")
		}
		.disabled(!editableItemData.canBeSaved)
	}
	
}


