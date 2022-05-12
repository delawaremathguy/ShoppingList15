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

// NOTE: UNDER CONSTRUCTION.  this is mostly a trial balloon, based on an
// issue opened by @santi-g-s (Santiago Garcia Santos) of how one might go about
// adding XCTesting to a project such as this.  the major impediment to easily
// adding testing is the app's use of a global singleton.
//
// as of now, this will be a stand-alone file and nothing in the project uses this code.
// i really just want to see what i might be getting myself into.

// 	the DataManagerClass is the base-level data model for SL15.
//   - it owns the Core Data stack (the stack is no longer in a global singleton)
// -  it acts as a centralized replacement of using @FetchRequests by
//      using NSFetchResultsControllers instead
// - it vends an array of Items and and an array of Locations
// - it handles requests to add and delete Core Data objects
// - it handles other "ad-hoc" data requests (although this is a little less
//      well-defined area of responsibility, since views can make changes to
//      the objects vended on their own in many cases)


class DataManager: NSObject, ObservableObject {
	
	// our hook into Core Data
	//private
	var managedObjectContext: NSManagedObjectContext
	
		// NSFetchedResultsControllers to use in place of distributed @FetchRequests
	private let itemsFRC: NSFetchedResultsController<Item>
	private let locationsFRC: NSFetchedResultsController<Location>

	// what we vend to the outside: arrays of Items and Locations
	@Published var items = [Item]()
	@Published var locations = [Location]()
	// we'll return the unknownLocation through a function, just so we can
	// lazily instantiate it ... and then i'll come back and fix this later
	private var unknownLocation_: Location?
	var unknownLocation: Location {
		if let location = unknownLocation_ {
			return location
		}
		let newLocation = addNewLocation()
		newLocation.name_ = kUnknownLocationName
		newLocation.red_ = 0.5
		newLocation.green_ = 0.5
		newLocation.blue_ = 0.5
		newLocation.opacity_ = 0.5
		newLocation.visitationOrder_ = kUnknownLocationVisitationOrder
		unknownLocation_ = newLocation
		return newLocation
	}
	
	// now, what we vend to specific views:
	//  -- for the ShoppingListView
	var itemsOnList: [Item] { items.filter({ $0.onList }) }
	//  -- for the PurchasedItemsView
	var itemsOffList: [Item] { items.filter({ !$0.onList }) }
	
	override init() {
			// set up Core Data
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
	
	// MARK: - Item Handling
		
		// idea: move all class functions off Item since they refer to the singleton PersistentStore.shared
	
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
	
//		// updates data for an Item that the user has directed from an Add or Modify View.
//		// if the incoming data is not associated with an item, we need to create it first
//	func updateAndSave(using draftItem: DraftItem) {
//			// if we can find an Item with the right id, use it, else create one
//		if let id = draftItem.id,
//			 let item = items.first(where: { $0.id == id }) {
//			item.updateValues(from: draftItem)
//		} else {
//			let newItem = addNewItem()
//			newItem.updateValues(from: draftItem)
//		}
//		saveData()
//	}
	
	func delete(item: Item) {
		item.location.objectWillChange.send()
		managedObjectContext.delete(item)
		saveData()
	}
	
	func moveAllItemsOffShoppingList() {
		for item in items where item.onList {
			item.onList_ = false
		}
	}
	
		// MARK: - Location Handling
	
		// idea: move all class functions off Location since they refer to the singleton PersistentStore.shared
	
	func addNewLocation() -> Location {
		let newLocation = Location(context: managedObjectContext)
		newLocation.id = UUID()
		// default values here ?
		return newLocation
	}
	
		// parameters for the Unknown Location.  this is called only if we try to fetch the
		// unknown location and it is not present.
	private func createUnknownLocation() {
		unknownLocation_ = addNewLocation()
		unknownLocation_?.name_ = kUnknownLocationName
		unknownLocation_?.red_ = 0.5
		unknownLocation_?.green_ = 0.5
		unknownLocation_?.blue_ = 0.5
		unknownLocation_?.opacity_ = 0.5
		unknownLocation_?.visitationOrder_ = kUnknownLocationVisitationOrder
	}
	
//	func findCreateUnknownLocation() -> Location {
//		
//		if let location = unknownLocation_ {
//			return location
//		}
//			// we only keep one "UnknownLocation" in the data store.  you can find it because its
//			// visitationOrder is the largest 32-bit integer. to make the app work, however, we need this
//			// default location to exist!
//			//
//			// so if we ever need to get the unknown location from the database, we will fetch it;
//			// and if it's not there, we will create it then.
//		let fetchRequest: NSFetchRequest<Location> = Location.fetchRequest()
//		fetchRequest.predicate = NSPredicate(format: "visitationOrder_ == %d", kUnknownLocationVisitationOrder)
//		do {
//			let locations = try managedObjectContext.fetch(fetchRequest)
//			if locations.count >= 1 { // there should be no more than one
//				unknownLocation_ = locations[0]
//				return locations[0]
//			}
//		} catch let error as NSError {
//			fatalError("Error fetching unknown location: \(error.localizedDescription), \(error.userInfo)")
//		}
//	}
	
	func delete(location: Location) {
			// you cannot delete the unknownLocation
		guard !location.isUnknownLocation else { return }
		
			// get a list of all items for this location so we can work with them
		let itemsAtThisLocation = location.items
		
			// reset location associated with each of these to the unknownLocation
			// (which in turn, removes the current association with location). additionally,
			// this could affect each item's computed properties
		itemsAtThisLocation.forEach({ $0.location = unknownLocation })
		
			// now finish the deletion and save
		managedObjectContext.delete(location)
		saveData()
	}
	
	func updateAndSave(using draftLocation: DraftLocation) {
			// if the incoming location data represents an existing Location, this is just
			// a straight update.  otherwise, we must create the new Location here and add it
			// before updating it with the new values
		if let id = draftLocation.id,
			 let location = locations.first(where: { $0.id == id }) {
			location.updateValues(from: draftLocation)
		} else {
			let newLocation = addNewLocation()
			newLocation.updateValues(from: draftLocation)
		}
		saveData()
	}
	
	func object(withID id: UUID?) -> NSManagedObject? {
		guard let id = id else { return nil }
		return NSManagedObject.object(id: id, context: managedObjectContext)
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

}

extension DataManager: NSFetchedResultsControllerDelegate {
	
		// we listen for changes to Items and Locations here.
		// it's a simple way to mimic what a @FetchRequest would do in SwiftUI for one of these objects
	func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
		if let newItems = controller.fetchedObjects as? [Item] {
			self.items = newItems
		} else if let newLocations = controller.fetchedObjects as? [Location] {
			self.locations = newLocations
		}
	}

}
