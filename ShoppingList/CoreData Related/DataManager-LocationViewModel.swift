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
	
	@Published var draft: LocationStruct
	
	private weak var dataManager: DataManager?
	
		// this init copies all the editable data from an incoming locationStruct (one known to exist)
	fileprivate init(locationStruct: LocationStruct?, dataManager: DataManager) {
		self.dataManager = dataManager
		if let locationStruct = locationStruct {
			draft = locationStruct
		} else {
			draft = LocationStruct()
		}
	}
	
		// to do a save/commit of an LocationViewModel, it must have a non-empty name
	var canBeSaved: Bool { draft.name.count > 0 }
	
	func updateAndSave() {
		dataManager?.updateAndSave(using: self)
	}
}

extension DataManager {
	
	// ask the DM to provide a LocationViewModel object, based on either a known location
	// in ModifyExistingLocationView or a default LocationViewModel for a new location
	// to be created in AddNewLocationView.
	func locationViewModel(locationStruct: LocationStruct? = nil) -> LocationViewModel {
		let viewModel = LocationViewModel(locationStruct: locationStruct, dataManager: self)
		return viewModel
	}
	
//	func updateAndSave(using locationViewModel: LocationViewModel) {
			// if the incoming location data represents an existing Location, this is just
			// a straight update.  otherwise, we must create the new Location here and add it
			// before updating it with the new values
		#warning("fix this")
//		if let id = locationViewModel.id,
//			 let location = locations.first(where: { $0.id == id }) {
//			update(location: location, from: locationViewModel)
//		} else {
//			let newLocation = addNewLocation()
//			update(location: newLocation, from: locationViewModel)
//		}
//		saveData()
//	}
	
//	private func update(location: Location, from locationViewModel: LocationViewModel) {
//		
//			// let all associated Items know they are effectively being changed
//		location.items.forEach({ $0.objectWillChange.send() })
//		
//			// we then make these changes directly in Core Data
//		let draft = locationViewModel.draft
//		location.name_ = draft.name
//		location.visitationOrder_ = Int32(draft.visitationOrder)
//		if let components = draft.color.cgColor?.components {
//			location.red_ = Double(components[0])
//			location.green_ = Double(components[1])
//			location.blue_ = Double(components[2])
//			location.opacity_ = Double(components[3])
//		} else {
//			location.red_ = 0.0
//			location.green_ = 1.0
//			location.blue_ = 0.0
//			location.opacity_ = 0.5
//		}
//		
//	}

}
