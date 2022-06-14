//
//  DataManager.swift
//  ShoppingList
//
//  Created by Jerry on 5/10/22.
//  Copyright © 2022 Jerry. All rights reserved.
//

import CoreData
import Foundation
import SwiftUI

/* Discussion
 
 this implementation of a DataManager (DM) started off as a trial balloon, based on an issue
 opened by @santi-g-s (Santiago Garcia Santos) of how one might go about adding
 XCTesting to a project such as this.  (the major impediment to easily adding testing
 was the app's use of a global singleton.)

the DataManagerClass now becomes the base-level data model for SL15.
   - it owns the Core Data stack (the stack is no longer in a global singleton)
 -  it acts as a centralized replacement of  multiple, distributed @FetchRequests by
      using NSFetchResultsControllers instead for Items and Locations
 - it vends an array of Items and and an array of Locations
 - it handles all requests to add and delete Core Data objects
 - it handles all other data requests involving Items and Locations that go beyond
       simple reading of Item and Location property values.
 
you will see that what were class functions originally defined on Item and Location
 are here; and you'll also see that all the "fronting" variables i use on Item
 and Location are now read-only -- SwiftUI views no longer have authority to
 write to Items and Locations, but instead must go through this DM to make
 those changes.
 
 for the future: one far-flung thought i'll look at is that the DM will not vend any
 actual Core Data objects, but instead will vend structs that are representations
 of those objects.  if that idea works, then SwiftUI would suddenly be
 very happy, since everything the views see would be structs and not (class) objects.

 */

class DataManager: NSObject, ObservableObject {
	
	// MARK: - Properties and Initialization
	
		// our private hook into Core Data
	private var managedObjectContext: NSManagedObjectContext
	
		// we use NSFetchedResultsControllers in place of distributed @FetchRequests
		// to keep track of Items and Locations
	private let itemsFRC: NSFetchedResultsController<Item>
	private let locationsFRC: NSFetchedResultsController<Location>

		// we vend @Published arrays of Items and Locations to clients, which
		// are updated internally by the itemsFRC and the locationsFRC in response
		// to controllerDidChangeContent() firing (we are an NSFetchedResultsControllerDelegate)
	@Published var items = [Item]()
	@Published var locations = [Location]()
	
		// we'll return the unknownLocation through a computed variable, with a private
		// reference to the unknownLocation, so we can lazily instantiate it ... we'll
		// come back later to see if this is sensible (there are possible cloud issues, anyway).
	private var unknownLocation_: Location?
	var unknownLocation: Location {
		if let location = unknownLocation_ {
			return location
		}
		unknownLocation_ = createUnknownLocation()
		return unknownLocation_!
	}
	
	override init() {
			// set up Core Data (we own it)
		let persistentStore = PersistentStore()
		managedObjectContext = persistentStore.context
		
			// create NSFetchedResultsControllers here for Items and Locations
		let fetchRequest1: NSFetchRequest<Item> = Item.fetchRequest()
		fetchRequest1.sortDescriptors = [NSSortDescriptor(key: "name_", ascending: true)]
		itemsFRC = NSFetchedResultsController(fetchRequest: fetchRequest1,
															 managedObjectContext: managedObjectContext,
															 sectionNameKeyPath: nil, cacheName: nil)
		
		let fetchRequest2: NSFetchRequest<Location> = Location.fetchRequest()
		fetchRequest2.sortDescriptors = [NSSortDescriptor(key: "visitationOrder_", ascending: true)]
		locationsFRC = NSFetchedResultsController(fetchRequest: fetchRequest2,
															 managedObjectContext: managedObjectContext,
															 sectionNameKeyPath: nil, cacheName: nil)
	
			// finish our initialization as an NSObject
		super.init()
		
			// hook ourself in as the delegate of each of these FRCs and do a first fetch to populate
			// the two @Published arrays we vend
		itemsFRC.delegate = self
		try? itemsFRC.performFetch()
		self.items = itemsFRC.fetchedObjects ?? []
		
		locationsFRC.delegate = self
		try? locationsFRC.performFetch()
		self.locations = locationsFRC.fetchedObjects ?? []
		
	}
	
	func saveData() {
		if managedObjectContext.hasChanges {
			do {
				try managedObjectContext.save()
			} catch let error as NSError {
				NSLog("Unresolved error saving context: \(error), \(error.userInfo)")
			}
		}
	}

		// MARK: - Location Handling
	
		// create and parameters for the Unknown Location.  this is called only if we try to fetch the
		// unknown location and it is not present.
	private func createUnknownLocation() -> Location {
		let unknownLocation = Location(context: managedObjectContext)
		unknownLocation.id = UUID()
		unknownLocation.name_ = kUnknownLocationName
		unknownLocation.red_ = 0.5
		unknownLocation.green_ = 0.5
		unknownLocation.blue_ = 0.5
		unknownLocation.opacity_ = 0.5
		unknownLocation.visitationOrder_ = kUnknownLocationVisitationOrder
		return unknownLocation
	}
	
	func assertUnknownLocationExists() {
		if unknownLocation_ != nil {
			return
		}
			// if unknownLocation_ not yet established, look among locations for it
		else if let location = locations.first(where: { $0.isUnknownLocation }) {
			unknownLocation_ = location
		}
			// otherwise, add the UL now
		else {
			unknownLocation_ = createUnknownLocation()
		}
	}
	
	func addNewLocation() -> Location {
		let newLocation = Location(context: managedObjectContext)
		newLocation.id = UUID()
		return newLocation
	}
	
		// deletes a Location.  an incoming nil is allowed to provide for syntactic
		// convenience at the call site.
	func delete(location: Location?) {
			// you cannot delete a nil or the unknown Location
		guard let location = location, !location.isUnknownLocation else {
			return
		}
		
			// get a list of all items for this location so we can work with them
		let itemsAtThisLocation = location.items
		
			// reset location associated with each of these to the unknownLocation
			// (which in turn, removes the current association with location). additionally,
			// this will affect each item's computed properties, so let each know they
			// are effectively "about to change"
		itemsAtThisLocation.forEach {
			$0.objectWillChange.send()
			$0.location_ = unknownLocation
		}
		
			// now finish the deletion and save
		managedObjectContext.delete(location)
		saveData()
	}
	
		// note: i'd really like to put this in DataManager-DraftLocation.swift, but i
		// need the managedObjectContext, which is private
	func location(associatedWith draftLocation: DraftLocation) -> Location? {
		guard let id = draftLocation.id else { return nil }
		return Location.object(id: id, context: managedObjectContext)
	}
	
	func locationCount() -> Int {
		Location.count(context: managedObjectContext)
	}
	
		// MARK: - Item Handling
	
		// creates a new Item with default values, associated with the unknownLocation
	func addNewItem() -> Item {
		let newItem = Item(context: managedObjectContext)
		newItem.name_ = ""
		newItem.quantity_ = 1
		newItem.isAvailable_ = true
		newItem.onList_ = true
		newItem.id = UUID()
		newItem.location_ = unknownLocation
		return newItem
	}
	
		// deletes an Item.  an incoming nil is allowed to provide for syntactic
		// convenience at the call site.
	func delete(item: Item?) {
		guard let item = item else { return }
		item.location.objectWillChange.send()
		managedObjectContext.delete(item)
		saveData()
	}
	
		// moves all items of the shopping list
	func moveAllItemsOffShoppingList() {
		for item in items where item.onList {
			item.onList_ = false
		}
	}
	
	func toggleAvailableStatus(item: Item) {
		item.isAvailable_.toggle()
	}
	
	func toggleOnListStatus(item: Item) {
		if item.onList_ {
			item.onList_ = false
			item.dateLastPurchased_ = Date.now
		} else {
			item.onList_ = true
		}
	}
	
	func markAsAvailable(items: [Item]) {
		items.forEach { $0.isAvailable_ = true }
	}

		// note: i'd really like to put this in DataManager-DraftItem.swift, but i
		// need the managedObjectContext, which is private
	func item(associatedWith draftItem: DraftItem) -> Item? {
		guard let id = draftItem.id else { return nil }
		return Item.object(id: id, context: managedObjectContext)
	}
	
	func itemCount() -> Int {
		Item.count(context: managedObjectContext)
	}
	
}

	// MARK: - FetchedResults Handling

extension DataManager: NSFetchedResultsControllerDelegate {
	
		// we listen for changes to Items and Locations here.
		// it's a simple way to mimic what a @FetchRequest would do in SwiftUI for one of these objects.
		// note: this is most likely the spot where we can identify any cloud latency problem of having
		//created an Unknown Location on device and then finding we already had one in the cloud.
	func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
		if let newItems = controller.fetchedObjects as? [Item] {
			self.items = newItems
		} else if let newLocations = controller.fetchedObjects as? [Location] {
			self.locations = newLocations
		}
	}

}
