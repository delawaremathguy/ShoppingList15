//
//  DataManager-draftItem.swift
//  ShoppingList
//
//  Created by Jerry on 5/12/22.
//  Copyright © 2022 Jerry. All rights reserved.
//

import Foundation

	// this gives me a way to collect all the data for an Item that i might want to edit
	// (or even just display).  it defaults to having values appropriate for a new item upon
	// creation, and can be initialized from a Item.  this is something
	// i can then hand off to an edit view.  at some point, that edit view will
	// want to update an Item with this data, so see the class function
	// Item.update(using draftItem: DraftItem)

	// ADDED 2 FEB 2022: this is now a class object that conforms to ObservableObject, with
	// five of its properties marked @Published (these are exactly the properties that can be edited
	// in the DraftItemView).  both the AddNewItemView and the ModifyExistingDataView
	// will create these as a @StateObject.  it turns out that @State (for a struct) and @StateObject
	// (for a class) do not exactly have the same behaviour, despite my naive belief that they did.
	// making this change solves an updating problem discovered while editing Items, where
	// some changes would "not seem to stick" across multiple edits.

class DraftItem: ObservableObject {
	
		// the id of the Item, if any, associated with this data collection
		// (nil if data for a new item that does not yet exist)
	var id: UUID? = nil
		// all of the values here provide suitable defaults for a new item
	@Published var name: String = "New Item"
	@Published var quantity: Int = 1
	@Published var location: Location
	@Published var onList: Bool = true
	@Published var isAvailable: Bool = true
	var dateText = "" // for display only, not actually editable
	
		// this copies all the editable data from an incoming Item.  this looks fairly
		// benign, but its in the lines below that crashes did/could occur in earlier versions
		// because of the main, underlying problem: if an item is deleted somewhere outside
		// a view showing a list of items, the list view may wind up calling this with an item
		// that's a zombie: the data behind it has been deleted, but it could still be present
		// as a fault in Core Data.  i still don't quite get this -- it has to do
		// with how SwiftUI updates views.
	fileprivate init(item: Item) {
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
	
		// init that sets a location and optionally a name
	fileprivate init(initialItemName: String? = nil, location: Location) {
		if let initialItemName = initialItemName, initialItemName.count > 0 {
			name = initialItemName
		}
		self.location = location
	}
	
		// to do a save/update using a DraftItem, it must have a non-empty name
	var canBeSaved: Bool { name.count > 0 }
		// we also want to know if this DraftItem is attached to a real Item that
		// exists, or is data that will be used to create a new Item
//	var representsExistingItem: Bool { dataManager?.item(withID: id) != nil }
//		// useful to know the associated Item (which we'll force unwrap, so
//		// be sure you check representsExistingItem first (!))
//	var associatedItem: Item { dataManager!.item(withID: id)! }
}

extension DataManager {
	
		// provides a working DraftItem from an existing Item ... it just copies fields
		// from the Item to the DraftItem
	func draftItem(item: Item) -> DraftItem {
		DraftItem(item: item)
	}
	
		// this is called to create a new DraftItem with a suggested initialName is available
		// (this happens in the PurchasedItemsView when a search term is still available to
		// use as a suggested name).
	func draftItem(initialItemName: String?) -> DraftItem {
		return DraftItem(initialItemName: initialItemName, location: unknownLocation)
	}
	
		// this is called to create a new DraftItem at a known location
		// (this happens in the ModifyExistingLocationView)
	func draftItem(location: Location) -> DraftItem {
		DraftItem(location: location)
	}
	
	
		// updates data for an Item that the user has directed from an Add or Modify View.
		// if the incoming data is not associated with an item, we need to create it first
	func updateAndSave(using draftItem: DraftItem) {
			// if we can find an Item with the right id, use it, else create one
		if let id = draftItem.id,
			 let item = items.first(where: { $0.id == id }) {
			item.updateValues(from: draftItem)
		} else {
			let newItem = addNewItem()
			newItem.updateValues(from: draftItem)
		}
		saveData()
	}

}
