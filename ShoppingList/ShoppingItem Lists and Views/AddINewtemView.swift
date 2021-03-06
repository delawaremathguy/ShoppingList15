	//
	//  AddNewItemView.swift
	//  ShoppingList
	//
	//  Created by Jerry on 12/8/21.
	//  Copyright © 2021 Jerry. All rights reserved.
	//

import SwiftUI

	// the AddNewItemView is opened via a sheet from either the ShoppingListView and the
	// PurchasedItemTabView, within a NavigationView, to do as it says: add a new shopping item.
	// the strategy is simple:
	//
	// -- create a default set of values for a new shopping item (an ObservableObject)
	// -- the body shows a Form in which the user can edit the default data
	// -- we supply buttons in the navigation bar to create a new item from the edited data
	//      and to dismiss (which can also be accomplished just by pulling down on the sheet,
	//      although we might want to add .interactiveDismissDisabled() to the sheet so
	//      no data will be discarded unless the user touches the Cancel button.
	//
struct AddNewItemView: View {
	
		// a dismiss action.  we're a View presented using .sheet(item:) that was triggered by setting a
		// @State variable to something non-nil, so we need to be given a way to dismiss ourself (which
		// normally is setting that value to nil, but one that must be supplied as a dismiss function
		// by the caller).
	private var dismiss: () -> Void
	
		// this draftItem object contains all of the fields for a new Item that are needed from the User
	@StateObject private var draftItem: DraftItem
	
		// custom init here to set up a data for an Item to be added having default values
	init(initialItemName: String? = nil, location: Location? = nil, dismiss: @escaping () -> Void) {
			// create working, editable data for a new Item, with the given suggested initial name and location
		let initialValue = DraftItem(initialItemName: initialItemName, location: location)
		_draftItem = StateObject(wrappedValue: initialValue)
			// and stash away the dismiss function
		self.dismiss = dismiss
	}
	
		// the body is pretty short -- just call up a Form, adding a Cancel and Save button
	var body: some View {
		NavigationView {
			DraftItemView(draftItem: draftItem)
				.navigationBarTitle("Add New Item", displayMode: .inline)
				.toolbar {
					ToolbarItem(placement: .cancellationAction, content: cancelButton)
					ToolbarItem(placement: .confirmationAction, content: saveButton)
				}
		}
	}
	
		// the cancel button just dismisses ourself
	func cancelButton() -> some View {
		Button {
			dismiss()
		} label: {
			Text("Cancel")
		}
	}
	
		// the save button saves the new item to the persistent store and dismisses ourself
	func saveButton() -> some View {
		Button {
			Item.updateAndSave(using: draftItem)
			dismiss()
		} label: {
			Text("Save")
		}
		.disabled(!draftItem.canBeSaved)
	}
	
}


