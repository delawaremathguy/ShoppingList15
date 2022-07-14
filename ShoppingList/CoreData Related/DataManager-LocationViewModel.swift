//
//  DataManager-LocationViewModel.swift
//  ShoppingList
//
//  Created by Jerry on 5/12/22.
//  Copyright © 2022 Jerry. All rights reserved.
//

import Foundation
import SwiftUI

	// **** see the more lengthy discussion over in DataManager-ItemViewModel.swift
	// as to why we are using a class that's an ObservableObject.
	// of course, now that i have properly called this a "view model," it's obvious why
	// we're a class that's an ObservableObject

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
		dataManager?.updateData(using: draft)
		dataManager?.saveData()
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
	
}
