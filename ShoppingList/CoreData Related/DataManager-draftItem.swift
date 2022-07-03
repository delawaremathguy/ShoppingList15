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
	// creation, and can be initialized from an existing Item.  this is something
	// i can then hand off to an edit view.  at some point, that edit view will
	// want to update an Item with this data, so see the function updateAndSave below.

	// UPDATED 24 MAY 2022: DraftItem was originally to be a struct, but is instead
	// a class object that conforms to ObservableObject, with five of its properties marked
	// @Published (these are exactly the properties that can be edited
	// in the DraftItemView).  both the AddNewItemView and the ModifyExistingDataView
	// will create these as a @StateObject.

	// in effect, DraftItem becomes a view model for the DraftItemView, where one can
	// edit properties of an Item, without actually committing those edits to the
	// backing Item (if there is one) until the user accepts the edits.  this is an idea that
	// i have seen in a recent Stewart Lynch video named "Dual Purpose Form and FocusState in SwiftUI"
	// https://www.youtube.com/watch?v=VEHn4WanW5g

	// of interest: it turns out that @State (for a struct) and @StateObject (for a class) do not
	// exactly have the same behaviour, despite my naive belief that they did.
	// my explanation of the difference appears below.

class DraftItem: ObservableObject {
	
		// the id of the Item, if any, associated with this data collection
		// (nil if data for a new item that does not yet exist)
	var id: UUID? = nil
		// all of the values here provide suitable defaults for a new item
	@Published var name: String = ""
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
}

extension DataManager {
	
		// the next three functions produce DraftItems for views.  the DM is then, essentially,
		// a DraftItem factory.  this could change in the future, but i like it for now, just so all the
		// DraftItem code generally resides in one place under control of the DM.
	
		// provides a working DraftItem from an existing Item ... it just copies fields
		// from the Item to the DraftItem.
	func draftItem(item: Item) -> DraftItem {
		DraftItem(item: item)
	}
	
		// this is called to create a new DraftItem with a suggested initialName is available
		// (this happens in the PurchasedItemsView when a search term is still available to
		// use as a suggested name).
	func draftItem(initialItemName: String?) -> DraftItem {
		DraftItem(initialItemName: initialItemName, location: unknownLocation)
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
			update(item: item, from: draftItem)
		} else {
			let newItem = addNewItem()
			update(item: newItem, from: draftItem)
		}
		saveData()
	}
	
	private func update(item: Item, from draftItem: DraftItem) {
		item.name_ = draftItem.name
		item.quantity_ = Int32(draftItem.quantity)
		item.onList_ = draftItem.onList
		item.isAvailable_ = draftItem.isAvailable
		item.location_ = draftItem.location
	}

}


/*
 
ADDED 24 May, 2022
 
 why i use a class object and not a struct here.
 
when editing Items, i discovered that some edits would "not seem to stick" across
 multiple edits ... cases where i go to the edit screen, make some changes, go back
 to a List view (where the edits appear correctly), then come back to the edit
 screen, and i would not find the updated Item values from the first edit, but
 the original values prior to the first edit.
 
my diagnosis is the following:
 
when SwiftUI brings a list of Items on screen in the ShoppingListView, it
probably has already created the ModifyExistingItemView structs for the
 rows in the list.  (i say probably ... it has created only enough for each of the row
 views on-screen and a few off-screen.)
 
 if DraftItem were a struct, it would be "created" for each of those row
 views in the sense that SwiftUI would put aside a copy of the DraftItem
 struct as it stands when the ModifyExistingDataView is initialized.
 
 when the ModifyExistingDataView comes on-screen, it is only then that
 a copy of the initialized DraftItem struct would be moved into the heap
 so that it could be edited as a @State variable.
 
 as you edit, the values in the in-heap @State variable are modified, and when
the ModifyExistingDataView goes off-screen, the values in the in-heap
 @State DraftItem variable are moved to the Item as an update (so, the Item
 is now as you expect), but more importantly, the in-heap  @State DraftItem
 variable is released.
 
 so now you go back to the ShoppingListView looks right, but you decide
 to re-edit the Item you just edited to change something else.
 
unless SwiftUI has done some serious memory cleaning,  it's likely that
 the ModifyExistingDataView struct is still held by SwiftUI, even though it's
 not visible on-screen.  so to bring the edit screen back to life, that copy of
 the DraftItem we put aside when the ModifyExistingDataView was initialized
 is still there and is not used to instantiated an in-heap version of the data
 to be used as a @State variable.
 
 but the problem is that the @State variable is being initialized using the
 original values from the first time we edited the Item.
 
 in other words, the in-heap data supporting editing of the @State variable
 does not persist across the appear/disappear/re-appear cycle of the
 ModifyExistingDataView.
 
 however, making a DraftItem a class object means that ModifyExistingDataView
 is using a @StateObject and it's initialized value is apparently being persisted
 across the appear/disappear/re-appear cycle of the ModifyExistingDataView,
 probably because it's already in the heap.

 so, the internal mysteries of SwiftUI continue to amaze ...
 
 */
