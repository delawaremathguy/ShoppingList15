	//
	//  ModifyExistingItemView.swift
	//  ShoppingList
	//
	//  Created by Jerry on 12/8/21.
	//  Copyright © 2021 Jerry. All rights reserved.
	//

import SwiftUI

	// the ModifyExistingItemView is opened via a navigation link from the ShoppingListView and the
	// PurchasedItemTabView o do as it says: edit an existing shopping item.  this will be a "live edit,"
	// in the sense that when the user touches the <Back button, we update the values of the
	// Item with the edited values.
	// the strategy is simple:
	//
	// -- create an editable representation of values for the item (a struct)
	// -- the body shows a Form in which the user can edit the default data
	// -- we update the Item's values from the editable representation when the View goes away
	//
	// one quick thing: this View will also display a confirmation alert if the user wants to delete the Item,
	// and if they agree, then we must be sure not to try to update the Item on the way out (!)
	//
struct ModifyExistingItemView: View {
	
	@Environment(\.dismiss) private var dismiss: DismissAction
	
	@State private var editableItemData: EditableItemData
	
		// custom init here to set up editableData state, a struct
	init(editableItem: Item) {
		_editableItemData = State(initialValue: EditableItemData(item: editableItem))
	}
	
		// alert trigger item to confirm deletion of an Item
	@State private var confirmDeleteItemAlert: ConfirmDeleteItemAlert?
		// if we really do go ahead and delete the Item, then we want the destructive action
		// (delete) to be recorded so that we don't try  to update the item (that we just deleted)
		// on the way out of this view in .onDisappear
	@State private var itemWasDeleted: Bool = false

	var body: some View {
		
		// the trailing closure provides the EditableItemDataView with what to do
		// after the user has deleted the item, namely dismiss and be sure not to
		// do the usual "live update" when we go away
		EditableItemDataView(editableItemData: $editableItemData) {
			confirmDeleteItemAlert = ConfirmDeleteItemAlert(item: editableItemData.associatedItem) {
				itemWasDeleted = true
				dismiss()
			}
		}
			.navigationBarTitle(Text("Modify Item"), displayMode: .inline)
			.onDisappear {
				// we were doing a pseudo-live edit, so update on the way out, unless
				// we opted to delete the associated item
				if !itemWasDeleted {
					Item.update(using: editableItemData)
					PersistentStore.shared.saveContext()
				}
			}
			.alert(item: $confirmDeleteItemAlert) { item in item.alert() }
	}
	
}

