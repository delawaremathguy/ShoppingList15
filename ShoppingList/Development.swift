//
//  Development.swift
//  ShoppingList
//
//  Created by Jerry on 5/14/20.
//  Copyright © 2020 Jerry. All rights reserved.
//

import Foundation
import CoreData
import UIKit

// what i previously called a "Dev Tools" tab -- now incorporated into the
// Preferences tab -- so that if you want to use this as a real app (device or simulator),
// access to all the debugging stuff can be displayed or not by setting this global
// variable `kShowDevTools`. for now, we'll show this on the simulator and not on a device.

#if targetEnvironment(simulator)
	let kShowDevTools = true
#else
	let kShowDevTools = false
#endif

// one of the things that has changed from release to release of XCode 12/iOS 14 is when
// the view modifiers .onAppear and .onDisappear are called.  so throughout the app, you
// find .onAppear and .onDisappear modifiers that print out when these actually do
// something by calling back to these two little functions.  you can turn this logging
// off by just commenting out the print statement (or deleting their calling from code).
func logAppear(title: String) {
	print(title + " Appears")
}
func logDisappear(title: String) {
	print(title + " Disappears")
}


// i used these constants and functions below during development to import and
// export Items and Locations via JSON.
// these are the filenames for JSON output when dumped from the simulator
// and also the filenames in the bundle used to load sample data.
let kJSONDumpDirectory = "/Users/USE_YOUR_OWN_MAC_USERNAME_HERE_HERE/Desktop/"	// dumps to the Desktop: Adjust for your Username!
let kItemsFilename = "items.json"
let kLocationsFilename = "locations.json"

// to write stuff out -- a list of Items and a list of Locations --
// the code is essentially the same except for the typing of the objects
// in the list.  so we use the power of generics:  we introduce
// (1) a protocol that demands that something be able to produce a simple
// Codable (struct) representation of itself -- a proxy as it were.
protocol CodableStructRepresentable {
	associatedtype DataType: Codable
	var codableProxy: DataType { get }
}

// and (2), knowing that Item and Location are NSManagedObjects, and we
// don't want to write our own custom encoder (eventually we will), we extend each to
// be able to produce a simple, Codable struct proxy holding only what we want to write out
// (ItemCodable and LocationCodable structs, respectively)
func writeAsJSON<T>(items: [T], to filename: String) where T: CodableStructRepresentable {
	let codableItems = items.map() { $0.codableProxy }
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

func populateDatabaseFromJSON() {
	// it sure is easy to do this with HWS's Bundle extension (!)
	let codableLocations: [LocationCodableProxy] = Bundle.main.decode(from: kLocationsFilename)
	insertNewLocations(from: codableLocations)
	let codableItems: [ItemCodableProxy] = Bundle.main.decode(from: kItemsFilename)
	insertNewItems(from: codableItems)
	PersistentStore.shared.saveContext()
}

func insertNewItems(from codableItems: [ItemCodableProxy]) {
	
	// get all Locations that are not the unknown location
	// group by name for lookup below when adding an item to a location
	let locations = Location.allLocations(userLocationsOnly: true)
	let name2Location = Dictionary(grouping: locations, by: { $0.name })
	
	for codableItem in codableItems {
		let newItem = Item.addNewItem() // new UUID is created here
		newItem.name = codableItem.name
		newItem.quantity = codableItem.quantity
		newItem.onList = codableItem.onList
		newItem.isAvailable_ = codableItem.isAvailable
		newItem.dateLastPurchased_ = nil // never purchased
		
		// look up matching location by name
		// anything that doesn't match goes to the unknown location.
		if let location = name2Location[codableItem.locationName]?.first {
			newItem.location = location
		} else {
			newItem.location = Location.unknownLocation() // if necessary, this creates the Unknown Location
		}
		
	}
}

// used to insert data from JSON files in the app bundle
func insertNewLocations(from codableLocations: [LocationCodableProxy]) {
	for codableLocation in codableLocations {
		let newLocation = Location.addNewLocation() // new UUID created here
		newLocation.name = codableLocation.name
		newLocation.visitationOrder = codableLocation.visitationOrder
		newLocation.red_ = codableLocation.red
		newLocation.green_ = codableLocation.green
		newLocation.blue_ = codableLocation.blue
		newLocation.opacity_ = codableLocation.opacity
	}
}

// MARK: - USeful Extensions re: CodableStructRepresentable

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



