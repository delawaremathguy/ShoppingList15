//
//  EditableItemData.swift
//  ShoppingList
//
//  Created by Jerry on 6/28/20.
//  Copyright © 2020 Jerry. All rights reserved.
//

import Foundation

// this gives me a way to collect all the data for an Item that i might want to edit
// (or even just display).  it defaults to having values appropriate for a new item upon
// creation, and can be initialized from a Item.  this is something
// i can then hand off to an edit view.  at some point, that edit view will
// want to update an Item with this data, so see the class function
// Item.update(using editableData: EditableItemData)

struct EditableItemData {
	// the id of the Item, if any, associated with this data collection
	// (nil if data for a new item that does not yet exist)
	var id: UUID? = nil
	// all of the values here provide suitable defaults for a new item
	var name: String = ""
	var quantity: Int = 1
	var location = Location.unknownLocation()
	var onList: Bool = true
	var isAvailable = true
	var dateText = "" // for display only, not actually editable
	
	// this copies all the editable data from an incoming Item.  this looks fairly
	// benign, but its in the lines below that crashes did/could occur in earlier versions
	// because of the main, underlying problem: if an item is deleted somewhere outside
	// a view showing a list of items, the list view may wind up calling this with an item
	// that's a zombie: the data behind it has been deleted, but it could still be present
	// as a fault in Core Data.  i still don't quite get this -- it's something to do
	// with how SwiftUI updates views and its interaction with a @FetchRequest.  this is the
	// one, remaining issue with SwiftUI i hope to understand real soon.
	init(item: Item) {
		id = item.id
		name = item.name
		quantity = Int(item.quantity)
		location = item.location
		onList = item.onList
		isAvailable = item.isAvailable
		if item.hasBeenPurchased {
			dateText = item.dateLastPurchased.dateText(style: .medium)
		}
	}
	
	init(initialItemName: String?, location: Location? = nil) {
		if let name = initialItemName, name.count > 0 {
			self.name = name
		}
		if let location = location {
			self.location = location
		}
	}
	
	// to do a save/commit of an Item, it must have a non-empty name
	var canBeSaved: Bool { name.count > 0 }
	// we also want to know if this itemData is attached to a real Item that
	// exists, or is data that will be used to create a new Item
	var representsExistingItem: Bool { id != nil }
	// useful to know the associated Item (which we'll force unwrap, so
	// be sure you check representsExistingItem first (!)
	var associatedItem: Item { Item.object(withID: id!)! }
}
