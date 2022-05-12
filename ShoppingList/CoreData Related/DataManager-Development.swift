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
		insertNewLocations(from: codableLocations)
		let codableItems: [ItemCodableProxy] = Bundle.main.decode(from: kItemsFilename)
		insertNewItems(from: codableItems)
		saveData()
	}
	
	func insertNewItems(from codableItems: [ItemCodableProxy]) {
		
			// get all Locations that are not the unknown location
			// group by name for lookup below when adding an item to a location
		//let locations = Location.allLocations(userLocationsOnly: true)
		let name2Location = Dictionary(grouping: locations, by: { $0.name })
		
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
	func insertNewLocations(from codableLocations: [LocationCodableProxy]) {
		for codableLocation in codableLocations {
			let newLocation = addNewLocation() // new UUID created here
			newLocation.name = codableLocation.name
			newLocation.visitationOrder = codableLocation.visitationOrder
			newLocation.red_ = codableLocation.red
			newLocation.green_ = codableLocation.green
			newLocation.blue_ = codableLocation.blue
			newLocation.opacity_ = codableLocation.opacity
		}
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

	
