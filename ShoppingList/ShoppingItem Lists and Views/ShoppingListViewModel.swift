//
//  ShoppingListViewModel.swift
//  ShoppingList
//
//  Created by Jerry on 7/29/20.
//  Copyright © 2020 Jerry. All rights reserved.
//

import Foundation

// a ShoppingListViewModel object manages an ordered list of ShoppingItems
// that appear in the ShoppingListTabView, PurchasedTabView, or in a
// AddorModifyLocationView subview.  it provides only information about the
// items and their order, and responds to various notifications that
// arrive that could affect the list or changes to the items within that list
// (i.e., insertions, deletions, and updates to items that affect order).
class ShoppingListViewModel: ObservableObject {
		
	// since we're really wrapping three different types of ShoppingListViewModel here
	// all together, it's useful to define the types for clarity, and record which one
	// we are when we are created
	enum ViewModelUsageType {
		case shoppingList 		// drives ShoppingListTabView
		case purchasedItemShoppingList 		// drives PurchasedTabView
		//case locationSpecificShoppingList(Location?)	// drives LocationsTabView with associated location data
	}
	var usageType: ViewModelUsageType
		
	// the items on our list.  whenever we modify this list, any View that knows about
	// us will get the message to update
	@Published var items = [ShoppingItem]()
	
	// have we ever been loaded or not?  once is enough, thank you.  the reason
	// is that we will see notifications for all creations, deletions, and updates
	// for the items we manage, so we can make appropriate modifications to the items
	// array without having to go back to Core Data and refetch.  this saves some time.
	private var dataHasBeenLoaded = false
		
	// quick accessors as computed properties
	var itemCount: Int { items.count }
	var hasUnavailableItems: Bool { items.count(where: { !$0.isAvailable }) > 0 }
	
	// MARK: - Initialization and Startup
	
	// init can be one of three different types. for a location-specific model, the
	// type will have associated data of the location we're attached to
	init(type: ViewModelUsageType) {
		usageType = type
		// sign us up for ShoppingItem and Location change operations.  note that Location changes
		// matter because the order of the items will change if a Location is deleted or have
		// its visitationOrder modified
		NotificationCenter.default.addObserver(self, selector: #selector(shoppingItemAdded),
																					 name: .shoppingItemAdded, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(shoppingItemEdited),
																					 name: .shoppingItemEdited, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(shoppingItemWillBeDeleted),
																					 name: .shoppingItemWillBeDeleted, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(locationEdited),
																					 name: .locationEdited, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(locationWillBeDeleted),
																					 name: .locationWillBeDeleted, object: nil)
	}
	
	// call this loadItems once the object has been created, before using it. in usage,
	// i have called this in .onAppear().  but because .onAppear() can be called
	// multiple times on the same View, i have the dataHasBeenLoaded variable so
	// that we're not constantly reloading the items array.  after all, we see
	// all changes to items come through us, no matter whether we are associated with
	// a View that is on- or off-screen, so we claim that we're always in the
	// right state once loaded.
	func loadItems() {
		if !dataHasBeenLoaded {
			switch usageType {
				case .shoppingList:
					items = ShoppingItem.currentShoppingList(onList: true)
				case .purchasedItemShoppingList:
					items = ShoppingItem.currentShoppingList(onList: false)
//				case .locationSpecificShoppingList(let location):
//					if let locationItems = location!.items as? Set<ShoppingItem> {
//						items = Array(locationItems)
//				}
			}
			print("shopping list loaded. \(items.count) items.")
			sortItems()
			dataHasBeenLoaded = true
		}
	}

	
	// MARK: - Responses to Notifications from Items
	
	// ALL OF THESE FUNCTIONS RESPOND TO NOTIFICATIONS that are posted when ShoppingItems
	// and Locations have been created, edited, or deleted.  Each must determine whether
	// the event affects the items array in any way that affects the View associated
	// with us.
	
	// also of note: both ShoppingItem and Location are Core Data objects, so we could
	// sign up for the NSManagedObjectContextObjectsDidChange notification, instead of
	// building our own notification system.  but (a) i have not used any of that in a
	// previous project; and (b) even if i had, i'll leave this here because some may
	// have their own, non-Core Data objects where you will find this internally-posted
	// notification technique useful.
	
	@objc func shoppingItemAdded(_ notification: Notification) {
		// the notification has a reference to a ShoppingItem that has been added.
		// if we're interested in it, now's the time to add it to the items array.
		guard let item = notification.object as? ShoppingItem else { return }
		if !items.contains(item) && isOurKind(item: item) {
			addToItems(item: item)
		}
	}

	@objc func shoppingItemEdited(_ notification: Notification) {
		// the notification has a reference to a ShoppingItem that has been added.
		// if we're interested in it, modify and/or sort the items array in response.
		guard let item = notification.object as? ShoppingItem else { return }
		// the logic here is simple:
		// -- did the edit kick the item off our list? if yes, remove it
		// -- did the edit put the item on our list? if so, add it
		// -- if it's on the list, sort the items (the edit may have changed the sorting order)
		// -- otherwise, we don't care
		if items.contains(item) && !isOurKind(item: item) {
			items.removeAll(where: { $0 == item })
		} else if !items.contains(item) && isOurKind(item: item) {
			addToItems(item: item)
		} else if items.contains(item) {
			sortItems()  // an edit may have compromised the sort order
		}
	}
	
	@objc func shoppingItemWillBeDeleted(_ notification: Notification) {
		// the notification has a reference to the ShoppingItem that will be deleted.
		// if we're holding on to it, now's the time to remove it from the items array.
		guard let item = notification.object as? ShoppingItem else { return }
		items.removeAll(where: { $0 == item })
	}
	
	@objc func locationEdited(_ notification: Notification) {
		// the notification has a reference to the Location that was edited.  we need
		// to see this notification: if the location's visitationOrder has been changed, that
		// (may) require a new sort of the items if any item is associated with this Location.
		guard let location = notification.object as? Location else { return }
		switch usageType {
			case .shoppingList:
				// if any item is associated ... a sort may be necessary
				if !items.allSatisfy({ $0.location! == location }) {
					sortItems()
			}
			case .purchasedItemShoppingList: //, .locationSpecificShoppingList(_):
				// nothing to do here; purchased items are sorted alphabetically
				// as is a list of items associated with an AddOrModifyLocationView
				break
		}
	}
		
	@objc func locationWillBeDeleted(_ notification: Notification) {
		// the notification has a reference to the Location that will be deleted.  we need
		// to see this notification: deleting a location has moved all items at that
		// location into the Unknown Location and thus will probably
		// require a new sort of the items if any item is affected by the change.
		guard let location = notification.object as? Location else { return }
		if !items.allSatisfy({ $0.location! == location }) {
			sortItems()
		}
	}
	
	// MARK: - Private Utility Functions
	
	// says whether a shopping item is of interest to us.
	private func isOurKind(item: ShoppingItem) -> Bool {
		switch usageType {
			case .shoppingList:
				return item.onList == true
			case .purchasedItemShoppingList:
				return item.onList == false
//			case .locationSpecificShoppingList(let location):
//				return item.location == location! // this must be not nil
		}
	}
		
	// we keep the items array sorted at all times.  whenever the content of the items array
	// changes, be sure we call sortItems(), which will trigger an objectWillChange.send().
	private func sortItems() {
		switch usageType {
			case .shoppingList: // , .multiSectionShoppingList:
				items.sort(by: { $0.name < $1.name })
				items.sort(by: { $0.location!.visitationOrder < $1.location!.visitationOrder })
			case .purchasedItemShoppingList: //, .locationSpecificShoppingList:
				items.sort(by: { $0.name < $1.name })
		}
	}
	
	// simple utility to add an item (that we know should be on our list and is
	// not there right now; and please sort after appending)
	private func addToItems(item: ShoppingItem) {
		items.append(item)
		sortItems()
	}

	// MARK: - Functions for Multi-section Display
	
	// provides a list of locations currently represented by objects in the items
	// array, sorted by visitation order, to drive the sectioning of the list
	func locationsForItems() -> [Location] {
		// get all the locations associated with our items
		let allLocations = items.map({ $0.location! })
		// then turn these into a Set (which causes all duplicates to be removed)
		// and sort by visitationOrder (which gives an array)
		return Set(allLocations).sorted(by: <)
	}
	
	// returns the items at a location to drive listing items in each section
	func items(at location: Location) -> [ShoppingItem] {
		return items.filter({ $0.location! == location }).sorted(by: { $0.name < $1.name }) 
	}

	// MARK: - Functions for Purchased Items Tab
	
	func hasItemsForToday(containing searchText: String) -> Bool {
		!items.allSatisfy(
			{ $0.dateLastPurchased < Calendar.current.startOfDay(for: Date()) || !searchText.appearsIn($0.name) })
	}
	
	func itemsPurchasedTodayCount(containing searchText: String) -> Int {
		items.count(where: { $0.dateLastPurchased >= Calendar.current.startOfDay(for: Date()) && searchText.appearsIn($0.name) })
	}
	
	func itemsPurchasedEarlierCount(containing searchText: String) -> Int {
		items.count - itemsPurchasedTodayCount(containing: searchText)
	}
	
	func itemsForToday(containing searchText: String) -> [ShoppingItem] {
		let itemsForToday = items.filter({ $0.dateLastPurchased >= Calendar.current.startOfDay(for: Date()) })
		return itemsForToday.filter({ searchText.appearsIn($0.name) })
	}
	
	func itemsEarlierThanToday(containing searchText: String) -> [ShoppingItem] {
		let itemsBeforeToday = items.filter({ $0.dateLastPurchased < Calendar.current.startOfDay(for: Date()) })
		return itemsBeforeToday.filter({ searchText.appearsIn($0.name) })	}

}
