//
//  Location+Extensions.swift
//  ShoppingList
//
//  Created by Jerry on 5/6/20.
//  Copyright © 2020 Jerry. All rights reserved.
//

import CoreData
import SwiftUI
//import UIKit

// constants
let kUnknownLocationName = "Unknown Location"
let kUnknownLocationVisitationOrder: Int32 = INT32_MAX

extension Location {
		
	// ** please see the associated discussion over in Item+Extensions.swift **
	
		// MARK: - Fronting Properties (Read-only)
	
		// name: fronts Core Data attribute name_ that is optional
	var name: String { name_ ?? "Location Name" }
	
		// visitationOrder: fronts Core Data attribute visitationOrder_ that is Int32
	var visitationOrder: Int { Int(visitationOrder_) }
	
		// items: fronts Core Data attribute items_ that is an NSSet, and turns it into
		// a Swift set so we can use them easily
	var items: Set<Item> {
		items_ as? Set<Item> ?? []
	}

		// itemCount: computed property from Core Data items_
	var itemCount: Int { items_?.count ?? 0 }
	
		// simplified test of "is the unknown location"
	var isUnknownLocation: Bool { visitationOrder_ == kUnknownLocationVisitationOrder }
	
		// hey, this is SwiftUI ... just define a Color!
	var color: Color { Color(.sRGB, red: red_, green: green_, blue: blue_, opacity: opacity_) }
	
} // end of extension Location
