	//
	//  AddNewItemView.swift
	//  ShoppingList
	//
	//  Created by Jerry on 12/8/21.
	//  Copyright © 2021 Jerry. All rights reserved.
	//

import SwiftUI

	// the AddNewItemView is opened via a sheet from either the ShoppingListView or the
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
	
	private var dataManager: DataManager
	
		// a dismiss action.  we're a View presented using .sheet(item:) that was triggered by setting a
		// @State variable to something non-nil, so we need to be given a way to dismiss ourself (which
		// normally is setting that value to nil, but one that must be supplied as a dismiss function
		// by the caller).
	private var dismiss: () -> Void
	
		// this itemViewModel object contains a draft for a new Item, containing the data  that are
		// needed from the User to create a new Item.
	@StateObject private var itemViewModel: ItemViewModel
	
		// there are two custom initializers here, because there are three instances of
		// opening this view in a sheet.
		//
		// Case 1: if opened from the ShoppingListView (initialItemName == nil) and
		// PurchasedItemsView (an initialName may/may not be supplied).
		// NOTE TO SELF: because we use the searchable modifier in PurchasedItemsView,
		// we'll never have a non-nil initialItemName: because when the search bar is
		// active, it removes the + in the navbar to add a new item (!)
	
	init(dataManager: DataManager, initialItemName: String? = nil, dismiss: @escaping () -> Void) {
		self.dataManager = dataManager
		let initialObjectValue = dataManager.draftItem(initialItemName: initialItemName)
		_itemViewModel = StateObject(wrappedValue: initialObjectValue)
			// and stash away the dismiss function
		self.dismiss = dismiss
	}
	
		// Case 2: if opened from the DraftLocationView, where we know we have a real
		// location associated with the draftLocation.
	init(dataManager: DataManager, draftLocation: DraftLocation, dismiss: @escaping () -> Void) {
		self.dataManager = dataManager
		let initialObjectValue = dataManager.draftItem(location: dataManager.location(associatedWith: draftLocation)!)
		_itemViewModel = StateObject(wrappedValue: initialObjectValue)
		self.dismiss = dismiss
	}

		// the body is pretty short -- just call up a Form, adding a Cancel and Save button
	var body: some View {
		NavigationView {
			ItemEditView(viewModel: itemViewModel)
				.navigationBarTitle("Add New Item", displayMode: .inline)
				.toolbar {
					ToolbarItem(placement: .cancellationAction, content: cancelButton)
					ToolbarItem(placement: .confirmationAction, content: saveButton)
				}
		}
	}
	
		// the cancel button just dismisses us
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
			dataManager.updateAndSave(using: itemViewModel)
			dismiss()
		} label: {
			Text("Save")
		}
		.disabled(!itemViewModel.canBeSaved)
	}
	
}


