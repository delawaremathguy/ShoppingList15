	//
	//  ModifyExistingItemView.swift
	//  ShoppingList
	//
	//  Created by Jerry on 12/8/21.
	//  Copyright © 2021 Jerry. All rights reserved.
	//

import SwiftUI

struct ModifyExistingItemView: View {
	
	@Environment(\.dismiss) private var dismiss: DismissAction
	
	@State private var editableItemData: EditableItemData
	
		// custom init here to set up editableData state
	init(editableItem: Item) {
		_editableItemData = State(initialValue: EditableItemData(item: editableItem))
	}
	
		// alert to confirm deletion of an Item
	@State private var confirmDeleteItemAlert: ConfirmDeleteItemAlert?
		// if we really do go ahead and delete the Item, then we want the destructive action
		// (delete) to be recorded so that we don't try  to update the item (that we just deleted)
		// on the way out of this view in .onDisappear
	@State private var itemWasDeleted: Bool = false

	var body: some View {
		
		EditableItemDataView(editableItemData: $editableItemData) {
			confirmDeleteItemAlert = ConfirmDeleteItemAlert(item: editableItemData.associatedItem) {
				itemWasDeleted = true
				dismiss()
			}
		}
			.navigationBarTitle(Text("Modify Item"), displayMode: .inline)
			.onDisappear {
				if !itemWasDeleted && editableItemData.canBeSaved {
					Item.update(using: editableItemData)
					PersistentStore.shared.saveContext()
				}
			}
			.alert(item: $confirmDeleteItemAlert) { item in item.alert() }

	}
	
	

}

