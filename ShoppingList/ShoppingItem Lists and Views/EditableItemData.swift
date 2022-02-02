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

// ADDED 2 FEB 2022: this is now a class object that conforms to ObservableObject, with
// five of its properties marked @Published (these are exactly the properties that can be edited
// in the EditableItemDataView).  both the AddNewItemView and the ModifyExistingDataView
// will create these as a @StateObject.  it turns out that @State (for a struct) and @StateObject
// (for a class) do not exactly have the same behaviour, despite my naive belief that they did.
// making this change solves an updating problem discovered while editing Items, where
// some changes would "not seem to stick" across multiple edits.

class EditableItemData: ObservableObject {
		
	// the id of the Item, if any, associated with this data collection
	// (nil if data for a new item that does not yet exist)
	var id: UUID? = nil
	// all of the values here provide suitable defaults for a new item
	@Published var name: String = ""
	@Published var quantity: Int = 1
	@Published var location = Location.unknownLocation()
	@Published var onList: Bool = true
	@Published var isAvailable = true
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
			dateText = item.dateLastPurchased.formatted(date: .long, time: .omitted)
		} else {
			dateText = "(Never)"
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
	
	// to do a save/update of an Item, it must have a non-empty name
	var canBeSaved: Bool { name.count > 0 }
	// we also want to know if this itemData is attached to a real Item that
	// exists, or is data that will be used to create a new Item
	var representsExistingItem: Bool { id != nil && Item.object(withID: id!) != nil }
	// useful to know the associated Item (which we'll force unwrap, so
	// be sure you check representsExistingItem first (!)
	var associatedItem: Item { Item.object(withID: id!)! }
}
