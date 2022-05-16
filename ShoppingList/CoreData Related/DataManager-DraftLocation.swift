//
//  DataManager-DraftLocation.swift
//  ShoppingList
//
//  Created by Jerry on 5/12/22.
//  Copyright © 2022 Jerry. All rights reserved.
//

import Foundation
import SwiftUI

	// **** see the more lengthy discussion over in DataManager-draftItem.swift as to why we are
	// using a class that's an ObservableObject.

class DraftLocation: ObservableObject {
	var id: UUID? = nil
	var associatedLocation: Location
		// all of the values here provide suitable defaults for a new Location
	@Published var name: String = ""
	@Published var visitationOrder: Int = 50
	@Published var color: Color = .green	// we keep a Color; a location has RGB-A components
	
		// this init copies all the editable data from an incoming Location (one known to exist)
	fileprivate init(location: Location, dataManager: DataManager) {
		id = location.id!
		name = location.name
		visitationOrder = Int(location.visitationOrder)
		color = Color(location.uiColor)
		associatedLocation = location
	}
	
		// to do a save/commit of an DraftLocation, it must have a non-empty name
	var canBeSaved: Bool { name.count > 0 }
}

extension DataManager {
	
	// ask the DM to provide a DraftLocation object, based on either a known location
	// or a default DraftLocation of unknown
	func draftLocation(location: Location? = nil) -> DraftLocation {
		if let location = location {
			return DraftLocation(location: location, dataManager: self)
		}
		return DraftLocation(location: unknownLocation, dataManager: self)
	}
	
	func updateAndSave(using draftLocation: DraftLocation) {
			// if the incoming location data represents an existing Location, this is just
			// a straight update.  otherwise, we must create the new Location here and add it
			// before updating it with the new values
		if let id = draftLocation.id,
			 let location = locations.first(where: { $0.id == id }) {
			update(location: location, from: draftLocation)
		} else {
			let newLocation = addNewLocation()
			update(location: newLocation, from: draftLocation)
		}
		saveData()
	}
	
	private func update(location: Location, from draftLocation: DraftLocation) {
		
			// let all associated Items know they are effectively being changed
		items.forEach({ $0.objectWillChange.send() })
		
			// we first make these changes directly in Core Data
		location.name_ = draftLocation.name
		location.visitationOrder_ = Int32(draftLocation.visitationOrder)
		if let components = draftLocation.color.cgColor?.components {
			location.red_ = Double(components[0])
			location.green_ = Double(components[1])
			location.blue_ = Double(components[2])
			location.opacity_ = Double(components[3])
		} else {
			location.red_ = 0.0
			location.green_ = 1.0
			location.blue_ = 0.0
			location.opacity_ = 0.5
		}
		
	}

}
