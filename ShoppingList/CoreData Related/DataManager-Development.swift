//
//  DataManager-Development.swift
//  ShoppingList
//
//  Created by Jerry on 5/11/22.
//  Copyright © 2022 Jerry. All rights reserved.
//

import Foundation

	// i used these constants and functions below during development to import and
	// export Items and Locations via JSON.  these are the filenames for JSON output
	// when dumped from the simulator and also the filenames in the bundle used to load sample data.
let kJSONDumpDirectory = "/Users/YOUR USERNAME HERE/Desktop/"	// dumps to the Desktop: Adjust for your Username!
let kItemsFilename = "items.json"
let kLocationsFilename = "locations.json"

	// to write stuff out -- a list of Items and a list of Locations --
	// the code is the same except for the typing of the objects
	// in the list.  so we use the power of generics:  we introduce
	// a protocol that demands that something be able to produce a simple
	// Codable (struct) representation of itself -- a proxy as it were.
protocol CodableStructRepresentable {
	associatedtype DataType: Codable
	var codableProxy: DataType { get }
}

	// we extend each of Item and Location to conform to this
	// CodableStructRepresentable protocol so that we can use
	// generic code to write them out.
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

extension DataManager {
	
	// MARK: - Data EXPORT
	
		// knowing that Item and Location are NSManagedObjects, and that we
		// don't want to write our own custom encoder (eventually we might),
	func writeAsJSON<T>(items: [T], to filename: String) where T: CodableStructRepresentable {
		let codableItems = items.map(\.codableProxy)
		let encoder = JSONEncoder()
		encoder.outputFormatting = .prettyPrinted
		var data = Data()
		do {
			data = try encoder.encode(codableItems)
		} catch let error as NSError {
			print("Error converting items to JSON: \(error.localizedDescription), \(error.userInfo)")
			return
		}
		
			// if in simulator, dump to files somewhere on your Mac (check definition above)
			// and otherwise if on device (or if file dump doesn't work) simply print to the console.
#if targetEnvironment(simulator)
		let filepath = kJSONDumpDirectory + filename
		do {
			try data.write(to: URL(fileURLWithPath: filepath))
			print("List of items dumped as JSON to " + filename)
		} catch let error as NSError {
			print("Could not write to desktop file: \(error.localizedDescription), \(error.userInfo)")
			print(String(data: data, encoding: .utf8)!)
		}
#else
		print(String(data: data, encoding: .utf8)!)
#endif
		
	}

	func exportDataToJSON() {
		writeAsJSON(items: items, to: kItemsFilename)
		writeAsJSON(items: locations.filter({ !$0.isUnknownLocation }), to: kLocationsFilename)
	}
	
	// MARK: - Data IMPORT
	
	func populateDatabaseFromJSON() {
			// it sure is easy to do this with HWS's Bundle extension (!)
		let codableLocations: [LocationCodableProxy] = Bundle.main.decode(from: kLocationsFilename)
		let newLocations = insertNewLocations(from: codableLocations)
		let codableItems: [ItemCodableProxy] = Bundle.main.decode(from: kItemsFilename)
		insertNewItems(from: codableItems, using: newLocations)
		saveData()
	}
	
	func insertNewItems(from codableItems: [ItemCodableProxy], using newLocations: [Location]) {
		
		// the newLocations list has all the locations added from JSON (which do not include an
		// unknown location).  it could be possible we already have these loaded already and we could
		// wind up duplicating stuff, but hey ... this is hacked development code.
		// on the other hand, it's important to use the locations we found in JSON in order to
		// link them up with items because if we really have not loaded the data before, the
		// dataManager's @Published locations array will not have been updated before we
		// then load all the items.  (this is just a timing thing with the NSFetchedResultsControllers
		// not having had time to trigger and be processed.)
		
		let name2Location = Dictionary(grouping: newLocations, by: { $0.name }).mapValues({ $0.first! })
		
		for codableItem in codableItems {
			let newItem = addNewItem() // new UUID is created here
			newItem.name_ = codableItem.name
			newItem.quantity_ = Int32(codableItem.quantity)
			newItem.onList_ = codableItem.onList
			newItem.isAvailable_ = codableItem.isAvailable
			newItem.dateLastPurchased_ = nil // never purchased
			
				// look up matching location by name
				// anything that doesn't match goes to the unknown location.
			if let location = name2Location[codableItem.locationName] {
				newItem.location_ = location
			} else {
				newItem.location_ = unknownLocation // if necessary, this creates the Unknown Location
			}
			
		}
	}
	
		// used to insert data from JSON files in the app bundle.  note that we did not put
		// the unknownLocation into the JSON
	func insertNewLocations(from codableLocations: [LocationCodableProxy]) -> [Location] {
		var newLocations = [Location]()
		for codableLocation in codableLocations {
			let newLocation = addNewLocation() // new UUID created here
			newLocation.name_ = codableLocation.name
			newLocation.visitationOrder_ = Int32(codableLocation.visitationOrder)
			newLocation.red_ = codableLocation.red
			newLocation.green_ = codableLocation.green
			newLocation.blue_ = codableLocation.blue
			newLocation.opacity_ = codableLocation.opacity
			newLocations.append(newLocation)
		}
		return newLocations
	}
	
}
	
	
