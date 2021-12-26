	//
	//  ModifyExistingItemView.swift
	//  ShoppingList
	//
	//  Created by Jerry on 12/8/21.
	//  Copyright © 2021 Jerry. All rights reserved.
	//

import SwiftUI

	// the ModifyExistingItemView is opened via a navigation link from the ShoppingListView and the
	// PurchasedItemTabView to do as it says: edit an existing shopping item.  this will be an "almost live edit,"
	// in the sense that when the user touches the <Back button, we update the values of the Item with the edited values.
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
		
	// i am a surprised that i have to keep a reference to the item (turns out, it does not need
	// to be an @ObservedObject reference) and reload the editableItemData in each .onAppear.
	// it turns out that @State values (and @StateObject objects) are apparently created lazily
	// by SwiftUI, and those values are actually discarded when no longer needed by SwiftUI --
	// even though the View struct itself has not been discarded.  so when the @State values are
	// again needed, they are restored to their initial value based on when the view struct was created,
	// and not the value they had when the @State value was discarded.
	//
	// in other words, the lifecycle of @State and @StateObject values is not the same as the
	// lifecycle of the View struct that defines them.  could this simply be a SwiftUI bug?
	//
	// but then, of course, this seems not to be needed over in ModifyExistingLocationView,
	// so it's unclear to me what's happening (!)
	private var item: Item
		// an editable copy of the Item's data
	@State private var editableItemData: EditableItemData
	
		// custom init here to set up editableData state, a struct
	init(editableItem: Item) {
		self.item = editableItem
		_editableItemData = State(initialValue: EditableItemData(item: editableItem))
	}
	
		// alert trigger item to confirm deletion of an Item
	@State private var confirmDeleteItemAlert: IdentifiableAlertItem?
	
	var body: some View {
		
			// the trailing closure provides the EditableItemDataView with what to do after the user has
			// opted to delete the item, namely "trigger an alert whose destructive action is to delete the
			// Item, and whose destructive completion is to dismiss this view,"
			// so we "go back" up the navigation stack
		EditableItemDataView(editableItemData: $editableItemData) {
			confirmDeleteItemAlert = ConfirmDeleteItemAlert(item: editableItemData.associatedItem) {
				dismiss()
			}
		}
		.navigationBarTitle(Text("Modify Item"), displayMode: .inline)
		.alert(item: $confirmDeleteItemAlert) { item in item.alert() }
		// this onAppear seems to be critical for correct operation ... i will revisit this.
		.onAppear {
			// reload @State variable
			editableItemData = EditableItemData(item: item)
		}
		.onDisappear {
				// we were doing a pseudo-live edit, so update on the way out, unless we opted to delete the associated item
			if editableItemData.representsExistingItem {
				Item.update(using: editableItemData)
			}
		}
	}
	
}

