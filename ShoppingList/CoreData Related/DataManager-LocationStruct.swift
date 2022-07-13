//
//  DataManager-LocationStruct.swift
//  ShoppingList
//
//  Created by Jerry on 7/12/22.
//  Copyright © 2022 Jerry. All rights reserved.
//

import SwiftUI

struct LocationStruct {
	
	let id: UUID
	
	var color: Color
	var isUnknownLocation: Bool
	var itemCount: Int
	var name: String
	var visitationOrder: Int
	
	init(from location: Location) {
		
		id = location.id!
		
		color = location.color
		isUnknownLocation = location.isUnknownLocation
		itemCount = location.itemCount
		name = location.name
		visitationOrder = location.visitationOrder
	}
	
}
