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
   - it owns the Core Data stack (the stack is no longer a global singleton)
 -  it acts as a centralized replacement of multiple, distributed @FetchRequests by
      using NSFetchResultsControllers instead for Items and Locations
 - it vends an array of _struct_ representations of Items and an array of Locations
 - it handles all requests to add and delete Core Data objects
 - it handles all other data requests involving Items and Locations that go beyond
       simple reading of Item and Location property values.
 
you will see that what were class functions originally defined on Item and Location
 are here; and you'll also see that all the "fronting" variables i use on Item
 and Location are now read-only -- SwiftUI views no longer have authority to
 write to Items and Locations, but instead must go through this DM to make
 those changes.
 
 ** UPDATED 12 July: SwiftUI Views never see Items, only their _struct_
 ** representations.  the same will be for Locations real soon.
 
 */

class DataManager: NSObject, ObservableObject {
	
	// MARK: - Properties and Initialization
	
		// our private hook into Core Data
	private var managedObjectContext: NSManagedObjectContext
	
		// we use NSFetchedResultsControllers in place of distributed @FetchRequests
		// to keep track of Items and Locations
	private let itemsFRC: NSFetchedResultsController<Item>
	private let locationsFRC: NSFetchedResultsController<Location>

		// we maintain arrays of Items and Locations, that are updated internally by the
		// itemsFRC and the locationsFRC in response to controllerDidChangeContent()
		// firing (we are an NSFetchedResultsControllerDelegate)
	
		// (a) the list of items (the actual Core Data objects) is now private, and should
		// only be used on the data-processing, business side of the app.  to keep SwiftUI
		// happy, we vend struct representations of these objects with the data needed for
		// the UI.  the UI-facing array is reconstructed whenever the FRCs fire, so the
		// second should always be a true representation of the first.
	private var items = [Item]()
	@Published var itemStructs = [ItemStruct]()

		// (b) for now, we make Core Data Location objects available to everyone, although
		// the hope is that this will soon follow the route of the distinction between the
		// array of Items above and their UI-facing, struct representations.
	private var locations = [Location]()
	@Published var locationStructs = [LocationStruct]()
	
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
		
		itemStructs = items.map { ItemStruct(from: $0) }
		locationStructs = locations.map { LocationStruct(from: $0) }
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
	
	func delete(locationStruct: LocationStruct) {
		if let location = Location.object(id: locationStruct.id, context: managedObjectContext) {
			delete(location: location)
		}
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
	
		// note: i'd really like to put this in DataManager-LocationViewModel.swift, but i
		// need the managedObjectContext, which is private
	func location(associatedWith viewModel: LocationViewModel) -> Location? {
			Location.object(id: viewModel.draft.id, context: managedObjectContext)
	}
	
	func location(withID id: UUID) -> Location? {
		Location.object(id: id, context: managedObjectContext)
	}
	
	func location(associatedWith itemStruct: ItemStruct) -> Location? {
		Location.object(id: itemStruct.locationID, context: managedObjectContext)
	}
		
		// MARK: - Item Handling
	
		// creates a new Item with default values, associated with the unknownLocation
	func addNewItem() -> Item {
		let newItem = Item(context: managedObjectContext)
		newItem.name_ = "New Item"
		newItem.quantity_ = 1
		newItem.isAvailable_ = true
		newItem.onList_ = true
		newItem.id = UUID()
		newItem.location_ = unknownLocation
		return newItem
	}
	
		// deletes an Item.  an incoming nil is allowed to provide for syntactic
		// convenience at the call site.
	func delete(itemStruct: ItemStruct?) {
		guard let item = itemStruct,
					let referencedItem = Item.object(id: item.id, context: managedObjectContext) else {
			return
		}
				//item.location.objectWillChange.send()
		managedObjectContext.delete(referencedItem)
		saveData()
	}
	
	func delete(item: Item) {
			// this Item is going away, so we will let its associated Location know ...
			// however, we will probably rebuild the locationStructs array anyway
			// and this may not be needed.
		item.location_?.objectWillChange.send()
		managedObjectContext.delete(item)
		saveData()
	}
	
		// moves all items of the shopping list
	func moveAllItemsOffShoppingList() {
		for item in items where item.onList_ {
			item.onList_ = false
		}
	}
	
	func toggleAvailableStatus(itemStruct: ItemStruct) {
		if let referencedItem = Item.object(id: itemStruct.id, context: managedObjectContext) {
			referencedItem.isAvailable_.toggle()
		}
	}
	
	func toggleOnListStatus(item: ItemStruct) {
		guard let referencedItem = Item.object(id: item.id, context: managedObjectContext) else {
			return
		}
		if referencedItem.onList_ {
			referencedItem.onList_ = false
			referencedItem.dateLastPurchased_ = Date.now
		} else {
			referencedItem.onList_ = true
		}
	}
	
	func markAsAvailable(items: [ItemStruct]) {
		for item in items {
			// find the Item we reference
			if let referencedItem = Item.object(id: item.id, context: managedObjectContext) {
				referencedItem.isAvailable_ = true
			}
		}
	}
	
	func item(withID id: UUID) -> Item? {
		Item.object(id: id, context: managedObjectContext)
	}
	
	// MARK: - Updating Items and Locations
	
	func updateData(using draft: LocationStruct) {
		
		// first, identify  case of existing or new
		var locationToUpdate: Location
		if let location = locations.first(where: { $0.id == draft.id }) {
			locationToUpdate = location
		} else {
			locationToUpdate = Location(context: managedObjectContext)
		}
		
			// directly update fields of the location in core data
		locationToUpdate.id = draft.id
		locationToUpdate.name_ = draft.name
		locationToUpdate.visitationOrder_ = Int32(draft.visitationOrder)
		if let components = draft.color.cgColor?.components {
			locationToUpdate.red_ = Double(components[0])
			locationToUpdate.green_ = Double(components[1])
			locationToUpdate.blue_ = Double(components[2])
			locationToUpdate.opacity_ = Double(components[3])
		} else {
			locationToUpdate.red_ = 0.0
			locationToUpdate.green_ = 1.0
			locationToUpdate.blue_ = 0.0
			locationToUpdate.opacity_ = 0.5
		}
	}
		
		// updates data for an Item that the user has directed from an Add or Modify View.
		// if the incoming data is not associated with an item, we need to create it first
	func updateData(using draft: ItemStruct) { //}, location: Location) {
		
		// first get the location associated with this draft.  if we can't find one, it's
		// not exactly clear what we're doing.
		guard let location = location(withID: draft.locationID) else {
			return
		}
			// first, figure out what it is that we're updating: and existing item, or
			// must we create a new one?
		var itemToUpdate: Item
		if let item = items.first(where: { $0.id == draft.id }) {
			itemToUpdate = item
		} else {
			itemToUpdate = addNewItem()
		}
		
		itemToUpdate.name_ = draft.name
		itemToUpdate.quantity_ = Int32(draft.quantity)
		itemToUpdate.onList_ = draft.onList
		itemToUpdate.isAvailable_ = draft.isAvailable
		
			// re-associate this item to the right location.
			// note to self: ordinarily, this is where we would worry about sending a message
			// to all items associated with the new location and all with whatever might have
			// been the item's previous location_ that they have changed ... but the DM's
			// fetchedResultsController will trigger because of this updateAndSave action
			// and the whole structure of the DM's itemStructs and locationStructs will be
			// rewritten anyway.
		itemToUpdate.location_ = location

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
			items = newItems
		} else if let newLocations = controller.fetchedObjects as? [Location] {
			locations = newLocations
		}
		
			// this has to be done in both cases, although if we just changed some locations,
			// we'd only change those items that were affected ?
		itemStructs = items.map { ItemStruct(from: $0) }
		locationStructs = locations.map { LocationStruct(from: $0) }
	}

}
