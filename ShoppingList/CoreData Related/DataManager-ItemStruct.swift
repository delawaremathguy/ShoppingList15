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
	// this type of struct is also used by an EditViewModel when editing an item (well,
	// editing an ItemStruct representation of an Item), although the last three properties
	// associated with its location (name, color, visitationOrder) have no use in this case.
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
		// the location's UUID, so we can find that Location later
	var locationID: UUID
	var locationName: String
	var visitationOrder: Int
	var color: Color
	
		// computed variable
	var hasBeenPurchased: Bool { dateLastPurchased > Date(timeIntervalSinceReferenceDate: 0) }

		// initialization used by DataManager to turn a real Item from code data into
		// a struct it can then vend to SwiftUI views.
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
		
		// initialization used by an ItemViewModel to create a draft ItemStruct
		// with default, working values with a known location.
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
		dateLastPurchased = Date(timeIntervalSinceReferenceDate: 0)
		
			// fields copied from the specified associated Location
		locationID = location.id!
		locationName = location.name
		visitationOrder = location.visitationOrder
		color = location.color
	}
}
