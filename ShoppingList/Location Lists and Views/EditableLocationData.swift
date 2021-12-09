//
//  EditableLocationData.swift
//  ShoppingList
//
//  Created by Jerry on 8/1/20.
//  Copyright © 2020 Jerry. All rights reserved.
//

import Foundation
import SwiftUI

struct EditableLocationData {
	// the id of the Location, if any, associated with this data collection
	// (nil if data for a new item that does not yet exist)
	var id: UUID? = nil
	// all of the values here provide suitable defaults for a new Location
	var locationName: String = ""
	var visitationOrder: Int = 50
	var color: Color = .green	// we keep a Color; a location has RGB-A components
	
	// this copies all the editable data from an incoming Location
	// updated 17-Apr to copy the id (obvious regression issue)
	// and also updated to allow nil argument ...
	init(location: Location?) {
		if let location = location {
			id = location.id!
			locationName = location.name
			visitationOrder = Int(location.visitationOrder)
			color = Color(location.uiColor)
		}
	}
	
	// to do a save/commit of an Item, it must have a non-empty name
	var canBeSaved: Bool { locationName.count > 0 }
	
	// useful to know if this is associated with an existing Location
	var representsExistingLocation: Bool { id != nil && Location.object(withID: id!) != nil }
	// useful to know the associated location (which we'll force unwrap, so
	// be sure you check representsExistingLocation first (!)
	var associatedLocation: Location { Location.object(withID: id!)! }
	
}

