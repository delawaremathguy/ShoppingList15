//
//  Location+Extensions.swift
//  ShoppingList
//
//  Created by Jerry on 5/6/20.
//  Copyright © 2020 Jerry. All rights reserved.
//

import UIKit
import CoreData

// constants
let kUnknownLocationName = "Unknown Location"
let kUnknownLocationVisitationOrder: Int32 = INT32_MAX

extension Location {
		
	// ** please see the associated discussion over in Item+Extensions.swift **
	
		// MARK: - Fronting Properties (Read-only)
	
		// name: fronts Core Data attribute name_ that is optional
		// if you change an location's name, its associated items may want to
		// know that some of their computed locationName properties have been invalidated
	var name: String { name_ ?? "Unknown Name" }
	
		// visitationOrder: fronts Core Data attribute visitationOrder_ that is Int32
	var visitationOrder: Int { Int(visitationOrder_) }
	
		// items: fronts Core Data attribute items_ that is an NSSet, and turns it into
		// a Swift array so we can use them easily
	var items: [Item] {
		if let items = items_ as? Set<Item> {
			return items.sorted(by: \.name)
		}
		return []
	}
	
		// itemCount: computed property from Core Data items_
	var itemCount: Int { items_?.count ?? 0 }
	
		// simplified test of "is the unknown location"
	var isUnknownLocation: Bool { visitationOrder_ == kUnknownLocationVisitationOrder }
	
		// this collects the four uiColor components into a single uiColor.
	var uiColor: UIColor { UIColor(red: red_, green: green_, blue: blue_, alpha: opacity_) }
	
} // end of extension Location
