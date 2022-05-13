//
//  DataManager-DraftLocation.swift
//  ShoppingList
//
//  Created by Jerry on 5/12/22.
//  Copyright © 2022 Jerry. All rights reserved.
//

import Foundation
import SwiftUI

	// **** see the more lengthy discussion over in DraftItem.swift as to why we are
	// using a class that's an ObservableObject.

class DraftLocation: ObservableObject {
	var id: UUID? = nil
	var associatedLocation: Location
		// all of the values here provide suitable defaults for a new Location
	@Published var name: String = ""
	@Published var visitationOrder: Int = 50
	@Published var color: Color = .green	// we keep a Color; a location has RGB-A components
	
		// this init copies all the editable data from an incoming Location
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
}
