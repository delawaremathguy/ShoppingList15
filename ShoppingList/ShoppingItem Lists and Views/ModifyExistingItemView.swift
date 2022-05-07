	//
	//  ModifyExistingItemView.swift
	//  ShoppingList
	//
	//  Created by Jerry on 12/8/21.
	//  Copyright © 2021 Jerry. All rights reserved.
	//

import SwiftUI

	// the ModifyExistingItemView is opened via a navigation link from the ShoppingListView
	// or the PurchasedItemTabView to do as it says: edit an existing shopping item.
	//
	// this will be an "almost live edit," in the sense that when the user touches the <Back button,
	// we update the values of the Item with the edited values.  however, because we have to intercept
	// when the user taps the Back button, we'll use our own Back button.  (maybe there's an
	// easier way to intercept tapping the Back button, but i don't have it here right now.)
	//
	// the strategy is simple:
	//
	// -- create an editable representation of values for the item (an ObservableObject)
	// -- the body shows a Form in which the user can edit the default data
	// -- we update the Item's values from the editable representation when going back.
	//
	// one quick thing: this View will also display a confirmation alert if the user wants to delete the Item,
	// and if the user agrees, then we must be sure not to update the Item on the way out (!)
	//
struct ModifyExistingItemView: View {
	
	@Environment(\.dismiss) private var dismiss: DismissAction
	
		// an editable copy of the Item's data.  it's important that this be a @StateObject, because
		// it is treated somewhat differently than @State.
		//
		// my observations/guesses:
		//
		// -- the lifecycle of a @StateObject is not the same as that of the underlying View struct
		//     where it is defined.  it is created lazily by SwiftUI and stored in the heap when the View will
		//     actually be coming to the screen (which means that SwiftUI has retained a reference to the
		//     Item that was passed in), and destroyed when SwiftUI is finished with the View onscreen.  SwiftUI
		//     or may not destroy the View struct when the @StateObject is destroyed; and if it does not
		//     destroy the View struct, the @StateObject will be restored lazily in the future by keeping a (secret)
		//     reference to the Item ... whose values may have changed since the last time this View was coming
		//     on-screen.  therefore, the @StateObject represents the current state of the Item when the View
		//     comes on screen.
		//
		// -- you can say almost exactly the same about an @State struct, but with one major exception:
		//     the View (i believe) stores a copy of the @State struct value when it is initialized.
		//     when the View will be coming to the screen, space is allocated in the heap and initialized from the stored
		//     copy of the initial struct and everything proceeds as you would sort of expect.
		//     should a View leave the visual hierarchy, the heap space for the @State value(s) is released, and should
		//     SwiftUI want to bring that View back into the visual hierarchy, the value of the @State struct will be
		//     restored from the copy of the @State struct it stashed away when it is initialized ... which is not the
		//     same value as a @State struct initialized from the Item when the View comes on screen.
		//
		// the mysteries of SwiftUI do indeed continue for me, even as we're now in version 3.
		//
	@StateObject private var draftItem: DraftItem
	
		// custom init here to set up editableData object
	init(item: Item) {
		_draftItem = StateObject(wrappedValue: DraftItem(item: item))
	}
	
		// alert trigger item to confirm deletion of an Item
	@State private var confirmDeleteItemAlert: IdentifiableAlertItem?
	@State private var confirmDeleteAlertShowing = false
	
	var body: some View {
		
			// the trailing closure provides the DraftItemView with what to do after the user has
			// opted to delete the item, namely "trigger an alert whose destructive action is to delete the
			// Item, and whose destructive completion is to dismiss this view,"
			// so we "go back" up the navigation stack
		DraftItemView(draftItem: draftItem) {
			confirmDeleteItemAlert = ConfirmDeleteItemAlert(item: draftItem.associatedItem) {
				dismiss()
			}
		}
		.navigationBarTitle(Text("Modify Item"), displayMode: .inline)
		.navigationBarBackButtonHidden(true)
		.toolbar {
			ToolbarItem(placement: .navigationBarLeading, content: customBackButton)
		}
		.alert(item: $confirmDeleteItemAlert) { item in item.alert() }
		
	} // end of var body: some View
	
	func customBackButton() -> some View {
		Button {
			if draftItem.representsExistingItem {
				Item.updateAndSave(using: draftItem)
			}
			dismiss()
		} label: {
			HStack(spacing: 5) {
				Image(systemName: "chevron.left")
				Text("Back")
			}
		}
	}
	
}

