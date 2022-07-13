//
//  DataManager-LocationViewModel.swift
//  ShoppingList
//
//  Created by Jerry on 5/12/22.
//  Copyright © 2022 Jerry. All rights reserved.
//

import Foundation
import SwiftUI

	// **** see the more lengthy discussion over in DataManager-draftItem.swift as to why we are
	// using a class that's an ObservableObject.

class LocationViewModel: ObservableObject {
	var id: UUID? = nil
		// all of the values here provide suitable defaults for a new Location
	@Published var name: String = ""
	@Published var visitationOrder: Int = 50
	@Published var color: Color = .green	// we keep a Color; a location has RGB-A components
	
		// this init copies all the editable data from an incoming Location (one known to exist)
	fileprivate init(dataManager: DataManager, location: Location? = nil) {
		if let location = location {
			id = location.id!
			name = location.name
			visitationOrder = Int(location.visitationOrder)
			color = location.color // Color(location.uiColor)
		} else {
			// all fields have defaults that are correct for a new Location
		}
	}
	
		// to do a save/commit of an LocationViewModel, it must have a non-empty name
	var canBeSaved: Bool { name.count > 0 }
}

extension DataManager {
	
	// ask the DM to provide a LocationViewModel object, based on either a known location
	// or a default LocationViewModel of unknown
	func locationViewModel(location: Location? = nil) -> LocationViewModel {
		return LocationViewModel(dataManager: self, location: location)
	}
	
	func updateAndSave(using locationViewModel: LocationViewModel) {
			// if the incoming location data represents an existing Location, this is just
			// a straight update.  otherwise, we must create the new Location here and add it
			// before updating it with the new values
		if let id = locationViewModel.id,
			 let location = locations.first(where: { $0.id == id }) {
			update(location: location, from: locationViewModel)
		} else {
			let newLocation = addNewLocation()
			update(location: newLocation, from: locationViewModel)
		}
		saveData()
	}
	
	private func update(location: Location, from locationViewModel: LocationViewModel) {
		
			// let all associated Items know they are effectively being changed
		location.items.forEach({ $0.objectWillChange.send() })
		
			// we then make these changes directly in Core Data
		location.name_ = locationViewModel.name
		location.visitationOrder_ = Int32(locationViewModel.visitationOrder)
		if let components = locationViewModel.color.cgColor?.components {
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
