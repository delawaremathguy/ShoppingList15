//
//  ConfirmationAlerts.swift
//  ShoppingList
//
//  Created by Jerry on 12/16/20.
//  Copyright © 2020 Jerry. All rights reserved.

import SwiftUI

	// i collect all the confirmation alerts here in one file.  there are three of them, although
	// two of them are used in different places throughout the app; that's in part why they are all
	// here (not distributed in different Views), and in part because it's easy to find them all
	// here and use any one to quickly copy-paste in a new one you might wish to create.
	//
	// please be sure to read through the file IdentifiableAlertItem.swift that describes
	// how to set up alerts.

// MARK: - Confirm DELETE ITEM Alert

class ConfirmDeleteItemAlert: IdentifiableAlertItem {
	
	// to function, we just need to know what item we're talking about, and how to do
	// the deletion as the destructive action.
	init(item: Item, dataManager: DataManager, destructiveCompletion: (() -> Void)? = nil) {
		super.init()
		// now update appropriate messages and actions
		self.title = "Delete \'\(item.name)\'?"
		self.message = "Are you sure you want to delete the Item named \'\(item.name)\'? This action cannot be undone."
		self.destructiveAction = {
			dataManager.delete(item: item)
			dataManager.saveData()
		}
		self.destructiveCompletion = destructiveCompletion
	}
	
}

// MARK: - Confirm MOVE ALL ITEMS OF LIST Alert

class ConfirmMoveAllItemsOffShoppingListAlert: IdentifiableAlertItem {
	
	init(destructiveAction: @escaping () -> ()) {
		super.init()
		title = "Move All Items Off-List"
		self.destructiveAction = destructiveAction
	}
	
}

// MARK: - Confirm DELETE LOCATION Alert

// *** see the comments over in AlertModel.swift about a possible replacement
// for this alert in particular, and possibly replacing the two alerts above using
// the same strategy ***

//class ConfirmDeleteLocationAlert: IdentifiableAlertItem {
//
//	init(location: Location, destructiveCompletion: (() -> Void)? = nil) {
//		super.init()
//		title = "Delete \'\(location.name)\'?"
//		message = "Are you sure you want to delete the Location named \'\(location.name)\'? All items at this location will be moved to the Unknown Location.  This action cannot be undone."
//		destructiveAction = { Location.delete(location) }
//		self.destructiveCompletion = destructiveCompletion
//	}
//
//}
