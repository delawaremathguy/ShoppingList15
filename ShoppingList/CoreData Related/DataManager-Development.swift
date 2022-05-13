//
//  DataManager-Development.swift
//  ShoppingList
//
//  Created by Jerry on 5/11/22.
//  Copyright © 2022 Jerry. All rights reserved.
//

import Foundation

extension DataManager {
	
	func populateDatabaseFromJSON() {
			// it sure is easy to do this with HWS's Bundle extension (!)
		let codableLocations: [LocationCodableProxy] = Bundle.main.decode(from: kLocationsFilename)
		let newLocations = insertNewLocations(from: codableLocations)
		let codableItems: [ItemCodableProxy] = Bundle.main.decode(from: kItemsFilename)
		insertNewItems(from: codableItems, using: newLocations)
		saveData()
	}
	
	func insertNewItems(from codableItems: [ItemCodableProxy], using newLocations: [Location]) {
		
		// the newLocations list has all the locations added from JSON (which do not have an
		// unknown location).  it could be possible we already have these loaded and we could
		// wind up duplicating stuff, but hey ... this is hacked development code.
		// on the other hand, it's important to use the locations we found in JSON in order to
		// link them up with items because if we really have not loaded the data before, the
		// dataManager's @Published locations array will not have been updated before we
		// then load all the items.  this is just a timing thing with the NSFetchedResultsControllers
		// not having had time to trigger and be processed.
		
			// get all Locations that are not the unknown location
			// group by name for lookup below when adding an item to a location
		//let locations = Location.allLocations(userLocationsOnly: true)
		let name2Location = Dictionary(grouping: newLocations, by: { $0.name })
		
		for codableItem in codableItems {
				//		let newItem = Item.addNewItem() // new UUID is created here
			let newItem = addNewItem() // new UUID is created here
			newItem.name_ = codableItem.name
			newItem.quantity_ = Int32(codableItem.quantity)
			newItem.onList_ = codableItem.onList
			newItem.isAvailable_ = codableItem.isAvailable
			newItem.dateLastPurchased_ = nil // never purchased
			
				// look up matching location by name
				// anything that doesn't match goes to the unknown location.
			if let location = name2Location[codableItem.locationName]?.first {
				newItem.location = location
			} else {
				newItem.location = unknownLocation // if necessary, this creates the Unknown Location
			}
			
		}
	}
	
		// used to insert data from JSON files in the app bundle
	func insertNewLocations(from codableLocations: [LocationCodableProxy]) -> [Location] {
		var newLocations = [Location]()
		for codableLocation in codableLocations {
			let newLocation = addNewLocation() // new UUID created here
			newLocation.name = codableLocation.name
			newLocation.visitationOrder = codableLocation.visitationOrder
			newLocation.red_ = codableLocation.red
			newLocation.green_ = codableLocation.green
			newLocation.blue_ = codableLocation.blue
			newLocation.opacity_ = codableLocation.opacity
			newLocations.append(newLocation)
		}
		return newLocations
	}
	
}
	
		// MARK: - Useful Extensions re: CodableStructRepresentable
	
	extension Location: CodableStructRepresentable {
		var codableProxy: some Encodable & Decodable {
			return LocationCodableProxy(from: self)
		}
	}
	
	extension Item: CodableStructRepresentable {
		var codableProxy: some Encodable & Decodable {
			return ItemCodableProxy(from: self)
		}
	}

	
