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
	// when the user taps the Back button, we'll use our own Back button.  (we don't really need
	// this ... we could just handle the update in an .onDisappear modifier as we do over in
	// ModifyExistingLocationView.  you decide!  the downside of handling this in .onAppear is
	// that we'll return to the previous screen on the navigation stack, see the old presentation, and
	// then see it update for the edit.  doing it with a custom back button gets the change made before
	// we see the parent in the navigation stack.)
	//
	// the strategy is simple:
	//
	// -- create an editable representation of values for the item (a StateObject)
	// -- the body shows a Form in which the user can edit the data
	// -- we update the Item's values from the editable representation when going back.
	//
	// one quick thing: this View will also display a confirmation alert if the user wants to delete the Item,
	// and if the user agrees, then we must be sure not to update the Item on the way out (!)
	//
struct ModifyExistingItemView: View {
	
	@Environment(\.dismiss) private var dismiss: DismissAction
	
		// an editable copy of the Item's data -- a "draft."  it's important that this be a
		// @StateObject, because it is treated somewhat differently than @State.
		//
		// my observations/guesses:
		//
		// -- the lifecycle of a @StateObject (meaning, when is there an object in the heap that stores
		//     the dynamic value of the variable) is not the same as that of the underlying View struct
		//     where it is defined.  it is created lazily by SwiftUI and stored in the heap when the View will
		//     actually be coming to the screen (which means that SwiftUI has retained a reference to the
		//     Item that was passed in), and destroyed when SwiftUI is finished with the View onscreen.  SwiftUI
		//     may or may not destroy the View struct when the @StateObject is destroyed; and if it does not
		//     destroy the View struct, the @StateObject will be restored lazily in the future by keeping a (secret?)
		//     reference to the Item ... whose values may have changed since the last time this View was coming
		//     on-screen.  therefore, the @StateObject represents the current state of the Item when the View
		//     comes on screen.
		//
		// -- you can say almost exactly the same about an @State struct, but with one major exception:
		//     the View (i believe) stores a copy of the @State struct value when it is initialized.
		//     when the View will be coming to the screen, space is allocated in the heap and initialized from the
		//     stored copy of the initial struct and everything proceeds as you would sort of expect.
		//     should a View leave the visual hierarchy, the heap space for the @State value(s) is released, and should
		//     SwiftUI want to bring that View back into the visual hierarchy, the value of the @State struct will be
		//     restored from the copy of the @State struct it stashed away when it is initialized ... which is not the
		//     same value as a @State struct initialized from the Item when the View comes on screen.
		//
		// the mysteries of SwiftUI do indeed continue for me, even as we're now in version 3.
		//
	@StateObject private var draftItem: DraftItem
	
		// custom init here to set up the DraftItem object.  in this case, we must pass the
		// dataManager in directly (and not rely on it being in the environment) because
		// we're inside the init() that runs first before everything else is available.
	
	private var dataManager: DataManager
	
	init(item: Item, dataManager: DataManager) {
		self.dataManager = dataManager
		_draftItem = StateObject(wrappedValue: dataManager.draftItem(item: item))
	}
	
		// alert trigger to confirm deletion of an Item
	@State private var confirmDeleteAlertShowing = false
	
	var body: some View {
		DraftItemView(draftItem: draftItem)
			.navigationBarTitle(Text("Modify Item"), displayMode: .inline)
			.navigationBarBackButtonHidden(true)
			.toolbar {
				ToolbarItem(placement: .navigationBarLeading, content: customBackButton)
			}		
	} // end of var body: some View
	
	func customBackButton() -> some View {
		Button {
			// check that we did not delete the object in the parent view !!
			if dataManager.item(associatedWith: draftItem) != nil {
				dataManager.updateAndSave(using: draftItem)
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

