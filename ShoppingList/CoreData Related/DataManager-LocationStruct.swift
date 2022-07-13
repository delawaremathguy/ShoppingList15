//
//  DataManager-LocationStruct.swift
//  ShoppingList
//
//  Created by Jerry on 7/12/22.
//  Copyright © 2022 Jerry. All rights reserved.
//

import SwiftUI

struct LocationStruct: Identifiable {
	
	let id: UUID
	
	var color: Color
	var isExistingLocation: Bool
	var isUnknownLocation: Bool
	var itemCount: Int
	var name: String
	var visitationOrder: Int
	
	init(from location: Location) {
		
		id = location.id!
		
		color = location.color
		isExistingLocation = true
		isUnknownLocation = location.isUnknownLocation
		itemCount = location.itemCount
		name = location.name
		visitationOrder = location.visitationOrder
	}
	
	init(from locationStruct: LocationStruct? = nil) {
		if let locationStruct = locationStruct {
			self = locationStruct
		} else {
			id = UUID()
			
			color = .green
			isExistingLocation = false
			isUnknownLocation = false
			itemCount = 0
			name = "New Location"
			visitationOrder = 50
		}
	}
	
}
