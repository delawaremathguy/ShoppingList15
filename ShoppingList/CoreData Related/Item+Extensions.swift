//
//  Item+Extensions.swift
//  ShoppingList
//
//  Created by Jerry on 4/23/20.
//  Copyright © 2020 Jerry. All rights reserved.
//

import Foundation
import CoreData
import UIKit

extension Item {
	
	/* Discussion
	
	update 25 December: better reorganization and removal of previous misconceptions!
	
	(1) Fronting of Core Data Attributes
	
	Notice that all except one of the Core Data attributes on an Item in the
	CD model appear with an underscore (_) at the end of their name.
	(the only exception is "id" because tweaking that name is a problem due to
	conformance to Identifiable.)
	
	my general theory of the case is that no one outside of this class (and its Core
	Data based brethren, like Location+Extensions.swift and PersistentStore.swift) should really
	be touching these attributes directly -- and certainly no SwiftUI views should
	ever touch these attributes directly.
	
	therefore, i choose to "front" each of them in this file, as well as perhaps provide
	other computed properties of interest.
	
	doing so helps smooth out the awkwardness of nil-coalescing (we don't want SwiftUI views
	continually writing item.name ?? "Unknown" all over the place); and in the case of an
	item's quantity, "fronting" its quantity_ attribute smooths the transition from
	Int32 to Int.  indeed, in SwiftUI views, these Core Data objects should
	appear just as objects, without any knowledge that they come from Core Data.
	
	we do allow SwiftUI views to write to these fronted properties; and because we front them,
	we can appropriately act on the Core Data side, sometimes performing only a simple Int --> Int32
	conversion.  similarly, if we move an item off the shopping list, we can take the opportunity
	then to timestamp the item as purchased.
	
	(2) Computed Properties Based on Relationships
	
	the situation for SwiftUI becomes more complicated when one CD object has a computed property
	based on something that's not a direct attribute of the object.  examples:
	
		-- an Item has a `locationName` computed property = the name of its associated Location
	
		-- a Location has an `itemCount` computed property = the count of its associated Items.
	
	for example, if a view holds on to (is a subscriber of) an Item as an @ObservedObject, and if
	we change the name of its associated Location, the view will not see this change because it
	is subscribed to changes on the Item (not the Location).
	
	assuming the view displays the name of the associated location using the item's locationName,
	we must have the location tell all of its items that the locationName computed property is now
	invalid and some views may need to be updated, in order to keep such a view in-sync.  thus
	the location must execute
	
		items.forEach({ $0.objectWillChange.send() })
	
	the same holds true for a view that holds on to (is a subscriber of) a Location as an @ObservedObject.
	if that view displays the number of items for the location, based on the computed property
	`itemCount`, then when an Item is edited to change its location, the item must tell both its previous
	and new locations about the change by executing objectWillChange.send() for those locations:
	
		(see the computed var location: Location setter below)
	
	as a result, you may see some code below (and also in Location+Extensions.swift) where, when
	a SwiftUI view writes to one of the fronted properties of the Item, we also execute
	location_?.objectWillChange.send().
	
	(3) @ObservedObject References to Items
	
	only the SelectableItemRowView has an @ObservedObject reference to an Item, and in development,
	this view (or whatever this view was during development) had a serious problem:
	
		if a SwiftUI view holds an Item as an @ObservedObject and that object is deleted while the
		view is still alive, the view is then holding on to a zombie object.  (Core Data does not immediately
		save out its data to disk and update its in-memory object graph for a deletion.)  depending on how
		view code accesses that object, your program may crash.

	when you front all your Core Data attributes as i do below, the problem above seems to disappear, for
	the most part, but i think it's really still there.  it's possible that iOS 14.2 and later have done
	something about this ...
		
	anyway, it's something to think about.  in this app, if you show a list of items on the shopping list,
	navigate to an item's detail view, and press "Delete this Item," the row view for the item in the shopping
	list is still alive and has a dead reference to the item.  SwiftUI may try to use that; and if you had
	to reference that item, you should expect that every attribute will be 0 (e.g., nil for a Date, 0 for an
	Integer 32, and nil for every optional attribute).
	
	*/
	
	// MARK: - Computed Properties
	
	// the date last purchased.  this fronts a Core Data optional attribute
	// when no date is available, we'll set the date to ReferenceDate, for purposes of
	// always having one for comparisons ("today" versus "earlier")
	var dateLastPurchased: Date { dateLastPurchased_ ?? Date(timeIntervalSinceReferenceDate: 1) }
	
	var hasBeenPurchased: Bool { dateLastPurchased_ != nil }
	
	// the name.  this fronts a Core Data optional attribute
	var name: String {
		get { name_ ?? "Not Available" }
		set { name_ = newValue }
	}
	
	// whether the item is available.  this fronts a Core Data boolean
	var isAvailable: Bool { isAvailable_ }
	
	// whether the item is on the list.  this fronts a Core Data boolean,
	// but when changed from true to false, it signals a purchase, so update
	// the lastDatePurchased
	var onList: Bool { 
		get { onList_ }
		set {
			onList_ = newValue
			if !onList_ { // just moved off list, so record date
				dateLastPurchased_ = Date()
			}
		}
	}
	
	// quantity of the item.   this fronts a Core Data optional attribute
	// but we need to do an Int <--> Int32 conversion
	var quantity: Int {
		get { Int(quantity_) }
		set { quantity_ = Int32(newValue) }
	}
	
	// an item's associated location.  this fronts a Core Data optional attribute.
	// if you change an item's location, the old and the new Location may want to
	// know that some of their computed properties could be invalidated
	var location: Location {
		get { location_! }
		set {
			location_?.objectWillChange.send()
			location_ = newValue
			location_?.objectWillChange.send()
		}
	}
	
	// the name of its associated location
	var locationName: String { location_?.name_ ?? "Not Available" }
	
	// the color = the color of its associated location
	var uiColor: UIColor {
		location_?.uiColor ?? UIColor(displayP3Red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
	}
	
	var canBeSaved: Bool { true }
	
	
	// MARK: - Useful Fetch Requests
	
	class func allItemsFR(at location: Location) -> NSFetchRequest<Item> {
		let request: NSFetchRequest<Item> = Item.fetchRequest()
		request.sortDescriptors = [NSSortDescriptor(key: "name_", ascending: true)]
		request.predicate = NSPredicate(format: "location_ == %@", location)
		return request
	}
	
	class func allItemsFR(onList: Bool) -> NSFetchRequest<Item> {
		let request: NSFetchRequest<Item> = Item.fetchRequest()
		request.predicate = NSPredicate(format: "onList_ == %d", onList)
		request.sortDescriptors = [NSSortDescriptor(key: "name_", ascending: true)]
		return request
	}

	// MARK: - Class functions for CRUD operations
	
	// this whole bunch of static functions lets me do a simple fetch and
	// CRUD operations.
	
	class func count() -> Int {
		return count(context: PersistentStore.shared.context)
	}

	class func allItems() -> [Item] {
		return allObjects(context: PersistentStore.shared.context) as! [Item]
	}
	
	class func object(withID id: UUID) -> Item? {
		return object(id: id, context: PersistentStore.shared.context) as Item?
	}
	
	// addNewItem is the user-facing add of a new entity.  since these are
	// Identifiable objects, this makes sure we give the entity a unique id, then
	// hand it back so the user can fill in what's important to them.
	class func addNewItem() -> Item {
		let context = PersistentStore.shared.context
		let newItem = Item(context: context)
		newItem.id = UUID()
		return newItem
	}
	
	// updates data for an Item that the user has directed from an Add or Modify View.
	// if the incoming data is not associated with an item, we need to create it first
	class func update(using editableData: EditableItemData) {
		
		// if we can find an Item with the right id, use it, else create one
		if let id = editableData.id,
			let item = Item.object(id: id, context: PersistentStore.shared.context) {
		//if let item = allItems().first(where: { $0.id == editableData.id }) {
			item.updateValues(from: editableData)
		} else {
			let newItem = Item.addNewItem()
			newItem.updateValues(from: editableData)
		}
	}

	class func delete(_ item: Item) {
		// remove the reference to this item from its associated location
		// by resetting its (real, Core Data) location to nil
		item.location_ = nil
		// now delete and save
		let context = item.managedObjectContext
		context?.delete(item)
		try? context?.save()
	}
	
	class func moveAllItemsOffShoppingList() {
		for item in allItems() where item.onList {
			item.onList_ = false
		}
	}
	
	// MARK: - Object Methods
	
	// toggles the availability flag for an item
	func toggleAvailableStatus() {
		isAvailable_ = !isAvailable_
	}

	// changes onList flag for an item
	func toggleOnListStatus() {
		onList = !onList
	}

	func markAvailable() {
		isAvailable_ = true
	}
	
	private func updateValues(from editableData: EditableItemData) {
		name_ = editableData.name
		quantity_ = Int32(editableData.quantity)
		onList_ = editableData.onList
		isAvailable_ = editableData.isAvailable
		location = editableData.location
	}
	
}

