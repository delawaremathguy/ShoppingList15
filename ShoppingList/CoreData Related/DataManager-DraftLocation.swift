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
	@Published var locationName: String = ""
	@Published var visitationOrder: Int = 50
	@Published var color: Color = .green	// we keep a Color; a location has RGB-A components
	
	// this will have a hook back to the dataManager that created it.  yeah, it's a syntactical
	// nightmare, but we want this to go back to the data source to be able to determine
	// whether the Location we started with still exists ...
	private weak var dataManager: DataManager?
	
		// this copies all the editable data from an incoming Location
		// updated 17-Apr to copy the id (obvious regression issue)
		// and also updated to allow nil argument ...
	fileprivate init(location: Location, dataManager: DataManager) {
		id = location.id!
		locationName = location.name
		visitationOrder = Int(location.visitationOrder)
		color = Color(location.uiColor)
		associatedLocation = location
		self.dataManager = dataManager
	}
	
		// to do a save/commit of an Item, it must have a non-empty name
	var canBeSaved: Bool { locationName.count > 0 }
	
		 // useful to know if this is associated with an existing Location
			 var representsExistingLocation: Bool { dataManager?.object(withID: id) != nil }
	
		// useful to know the associated location (which we'll force unwrap, so
		// be sure you check representsExistingLocation first (!)
	
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
