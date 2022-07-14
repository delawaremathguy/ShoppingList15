//
//  DataManager-draftItem.swift
//  ShoppingList
//
//  Created by Jerry on 5/12/22.
//  Copyright © 2022 Jerry. All rights reserved.
//

import SwiftUI

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
	// backing Item (if there is one) until the user accepts the edits.  i originally got this "draft"
	// notion from Stanford's CS193p course
	// https://cs193p.sites.stanford.edu
	// and this "view-model idea" is one that i saw mentioned in a recent Stewart Lynch video
	// named "Dual Purpose Form and FocusState in SwiftUI"
	// https://www.youtube.com/watch?v=VEHn4WanW5g

	// of interest: it turns out that @State (for a struct) and @StateObject (for a class) do not
	// exactly have the same behaviour, despite my naive belief that they did.
	// my explanation of the difference appears below.

	// UPDATED JULY 2022
	// for truth in advertising, "DraftItem" has become "ItemViewModel," because it really
	// does act as a view model for the Add/Modify Item views (specifically for the ItemEditView
	// subview).  this is more in keeping with Stewart Lynch's video mentioned above, but also in
	// response to some sample code written by Santiago Garcia Santos.
	//
	// of course, now that i have properly called this a "view model," it's obvious why
	// we're a class that's an ObservableObject

class ItemViewModel: ObservableObject {
	
		// an updated strategy (thank you Santiago!): we don't spell out all the fields
		// individually, but we'll make use of a simple copy of the ItemStruct that we want
		// to use for editing purposes.
	@Published var draft: ItemStruct
	
		// it's also convenient to have a real Location reference for the ItemStruct
		// that we are editing, as well as the Item, if it's available.  a late addition:
		// a weak reference back to the DM that created this ItemViewModel.
	var associatedLocation: Location {
		dataManager!.location(associatedWith: draft)!
	}
	
	var associatedItem: Item? {
		dataManager?.item(withID: draft.id)
	}
	private weak var dataManager: DataManager?
	
		// useful computed property
	var dateText: String {
		if draft.hasBeenPurchased {
			return draft.dateLastPurchased.formatted(date: .long, time: .omitted)
		} else {
			return "(Never)"
		}
	}
	
	fileprivate init(itemStruct: ItemStruct, item: Item?,
									 location: Location, dataManager: DataManager) {
		draft = itemStruct
		self.dataManager = dataManager
	}
	
		// init that sets a location and optionally a name for what will be a new Item.
	fileprivate init(initialItemName: String? = nil,
									 location: Location, dataManager: DataManager) {
		draft = ItemStruct(initialItemName: initialItemName, location: location)
		self.dataManager = dataManager
	}
	
		// to do a save/update using a DraftItem, it must have a non-empty name
	var canBeSaved: Bool { draft.name.count > 0 }
	
	func updateAndSave() {
		dataManager?.updateData(using: draft)
		dataManager?.saveData()
	}
	
	func deleteItem() {
		guard let item = associatedItem else { return }
		dataManager?.delete(item: item)
//		associatedItem = nil
	}
}

extension DataManager {
	
		// the next three functions produce ItemViewModels for item editing views.  the DM is then, essentially,
		// a ItemViewModel factory.  this could change in the future, but i like it for now, just so all the
		// ItemViewModel code generally resides in one place under control of the DM.
	
		// provides a working ItemViewModel from an existing ItemStruct ... it just copies data
		// from the Item to an ItemViewModel, while taking the liberty right now to identify
		// the location associated with the Item.
	func draftItem(itemStruct: ItemStruct) -> ItemViewModel {
		let item = item(withID: itemStruct.id)
		let location = location(associatedWith: itemStruct) ?? unknownLocation
		return ItemViewModel(itemStruct: itemStruct, item: item, location: location, dataManager: self)
	}
	
		// this is called to create a new DraftItem with a suggested initialName is available
		// (this happens in the PurchasedItemsView when a search term is still available to
		// use as a suggested name).
	func draftItem(initialItemName: String?) -> ItemViewModel {
		ItemViewModel(initialItemName: initialItemName, location: unknownLocation, dataManager: self)
	}
	
		// this is called to create a new, default ItemViewModel at a known location
		// (this happens in the ModifyExistingLocationView)
	func draftItem(location: Location) -> ItemViewModel {
		ItemViewModel(location: location, dataManager: self)
	}

}


/*
 
ADDED 24 May, 2022
 
 why i use a class object and not a struct here.
 
when editing Items, i discovered that some edits would "not seem to stick" across
 multiple edits ... cases where i go to the edit screen, make some changes, go back
 to a List view (where the edits appear correctly), then come back right away to the edit
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
 
 so now you go back to the ShoppingListView and it looks right, but you decide
 to re-edit the Item you just edited to change something else.
 
unless SwiftUI has done some serious memory cleaning ... maybe you scrolled
 around some or moved to a different tab ... it's likely that the ModifyExistingDataView
 struct has not been released and is still held by SwiftUI, even though it's
 not visible on-screen.  so to bring the edit screen back to life, that copy of
 the DraftItem we put aside when the ModifyExistingDataView was initialized
 is still there and is now used once more to instantiated an in-heap version of the data
 to be used as a @State variable.
 
 but the problem is that the @State variable is being initialized using the
 original values from the first time we edited the Item.
 
 in other words, the in-heap data supporting editing of the @State variable
 does not persist across the appear/disappear/re-appear cycle of the
 ModifyExistingDataView.
 
 however, making a DraftItem a class object means that ModifyExistingDataView
 is using a @StateObject and this lives in the heap exactly as long as the
 ModifyExistingDataView struct is alive, so if the ModifyExistingDataView struct is
 still in memory, so is the @StateObject and the values you changed the last time
 the view was on screen are exactly as you changed them previously.

 so, the internal mysteries of SwiftUI continue to amaze ... but if you think this
 through, it makes perfect sense.  SwiftUI determines when view structs are created
 and destroyed ... when i was using @State, i was assuming that the view struct was
 released when the modify view went off-screen and was being recreated when it
 came on screen; but using @StateObject guarantees the view struct and the
 @StateObject in the heap have consistent lifetimes.
 
 */
