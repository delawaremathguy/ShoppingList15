//
//  DataManager-ItemStruct.swift
//  ShoppingList
//
//  Created by Jerry on 7/10/22.
//  Copyright © 2022 Jerry. All rights reserved.
//

import SwiftUI

// this is a struct representation of the data describing an Item that can be
// handed out to the ShoppingListView and the PurchasedItemView so that
// we do not expose real core data objects and their dependencies to associated
// Locations to these views.
struct ItemStruct: Identifiable, Hashable {
	
	// the id will be the same as the id of any corresponding Item that
	// backs this data in Core Data (so we can find it later)
	let id: UUID
	
		// generic fields copied from Item objects in core data
	var name: String
	var isAvailable: Bool
	var onList: Bool
	var quantity: Int
	var dateLastPurchased: Date
	
		// fields copied from the Item's associated Location, including
		// the location's UUID, so we can find it later
	var locationID: UUID
	var locationName: String
	var visitationOrder: Int
	var color: Color
	
		// computed variable
	var hasBeenPurchased: Bool { dateLastPurchased > Date(timeIntervalSinceReferenceDate: 1) }


	init(from item: Item) {
		id = item.id!
		name = item.name
		isAvailable = item.isAvailable
		onList = item.onList
		quantity = item.quantity
		dateLastPurchased = item.dateLastPurchased
		
			// fields copied from the Item's associated Location
		let location = item.location
		locationID = location.id!
		locationName = location.name
		visitationOrder = location.visitationOrder
		color = location.color
	}
	
	init(initialItemName: String? = nil, location: Location) {
		id = UUID()
		if let name = initialItemName, name.count > 0 {
			self.name = name
		} else {
			name = "New Item"
		}
		isAvailable = true
		onList = true
		quantity = 1
		dateLastPurchased = Date(timeIntervalSinceReferenceDate: 1)
		
			// fields copied from the specified associated Location
		locationID = location.id!
		locationName = location.name
		visitationOrder = location.visitationOrder
		color = location.color

	}
}
