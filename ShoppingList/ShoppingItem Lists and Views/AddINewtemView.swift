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
	@Environment(\.dismiss) var dismiss: DismissAction
	
		// this editableItemData struct contains all of the fields for a new Item that are
		// needed from the User
	@State private var editableItemData: EditableItemData
	
		// custom init here to set up a tentative Item to add
	init(initialItemName: String? = nil, location: Location? = nil) {
			// create working, editable Item data for a new Item, with the given suggested
			// initial name and location
		let initialValue = EditableItemData(initialItemName: initialItemName, location: location)
		_editableItemData = State(initialValue: initialValue)
	}
	
	var body: some View {
		EditableItemDataView(editableItemData: $editableItemData, deleteActionTrigger: nil)
			.navigationBarTitle("Add New Item", displayMode: .inline)
			.navigationBarBackButtonHidden(true)
			.toolbar {
				ToolbarItem(placement: .cancellationAction) { cancelButton() }
				ToolbarItem(placement: .confirmationAction) { saveButton() }
			}
	}
	
		// the cancel button just dismisses ourself
	func cancelButton() -> some View {
		Button { dismiss() } label: { Text("Cancel") }
	}
	
		// the save button
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


