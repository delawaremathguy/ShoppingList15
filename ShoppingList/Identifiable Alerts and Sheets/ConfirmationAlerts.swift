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
