//
//  ConfirmationAlerts.swift
//  ShoppingList
//
//  Created by Jerry on 12/16/20.
//  Copyright © 2020 Jerry. All rights reserved.

import SwiftUI

// i collect all the confirmation alerts here in one file.  there are three of them, although
// two of them are used in different places throughout the app; that's why they are all
// here and not distributed in different Views.
//
// please be sure to read through the file ConfirmationAlertProtocol.swift that describes
// how to set up alerts.


// MARK: - Confirm DELETE ITEM Alert

struct ConfirmDeleteItemAlert: ConfirmationAlertProtocol {
	var id = UUID()
	
	var item: Item
	
	var title: String { "Delete \'\(item.name)\'?" }
	
	var message: String {
		"Are you sure you want to delete the Item named \'\(item.name)\'? This action cannot be undone"
	}
	
	func destructiveAction() {
		Item.delete(item)
	}
	
	var destructiveCompletion: (() -> Void)?
	var nonDestructiveCompletion: (() -> Void)?
	
	init(item: Item, destructiveCompletion: (() -> Void)? = nil) {
		self.item = item
		self.destructiveCompletion = destructiveCompletion
	}
}

// MARK: - Confirm MOVE ALL ITEMS OF LIST Alert

struct ConfirmMoveAllItemsOffShoppingListAlert: ConfirmationAlertProtocol {
	var id = UUID()
	
	var title: String { "Move All Items Off-List" }
	
	var message: String { "" }
	
	func destructiveAction() {
		Item.moveAllItemsOffShoppingList()
	}
	
	var destructiveCompletion: (() -> Void)?
	var nonDestructiveCompletion: (() -> Void)?
}

// MARK: - Confirm DELETE LOCATION Alert

struct ConfirmDeleteLocationAlert: ConfirmationAlertProtocol {
	var id = UUID()
	
	var location: Location
	
	var title: String { "Delete \'\(location.name)\'?" }
	
	var message: String {
		"Are you sure you want to delete the Location named \'\(location.name)\'? All items at this location will be moved to the Unknown Location.  This action cannot be undone."
	}
	
	func destructiveAction() {
		Location.delete(location)
	}
	
	var destructiveCompletion: (() -> Void)?
	var nonDestructiveCompletion: (() -> Void)?
	
	init(location: Location, destructiveCompletion: (() -> Void)? = nil) {
		self.location = location
		self.destructiveCompletion = destructiveCompletion
	}
	
}
