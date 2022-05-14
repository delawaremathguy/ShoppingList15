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

extension Location: Comparable {
	
	// add Comparable conformance: sort by visitation order
	public static func < (lhs: Location, rhs: Location) -> Bool {
		lhs.visitationOrder_ < rhs.visitationOrder_
	}
	
	// MARK: - Computed properties
	
	// ** please see the associated discussion over in Item+Extensions.swift **
	
		// name: fronts Core Data attribute name_ that is optional
		// if you change an location's name, its associated items may want to
		// know that some of their computed locationName properties have been invalidated
	var name: String {
		get { name_ ?? "Unknown Name" }
		set {
			name_ = newValue
			items.forEach({ $0.objectWillChange.send() })
		}
	}
	
	// visitationOrder: fronts Core Data attribute visitationOrder_ that is Int32
	// if you change an location's visitationOrder, its associated items may want to
	// know that some of their computed visitationOrder property has been invalidated
	var visitationOrder: Int {
		get { Int(visitationOrder_) }
		set {
			visitationOrder_ = Int32(newValue)
			items.forEach({ $0.objectWillChange.send() })
		}
	}
	
	// items: fronts Core Data attribute items_ that is an NSSet, and turns it into
	// a Swift array
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
	// if you change a location's uiColor, its associated items will want to
	// know that their uiColor computed properties have been invalidated.
	// note: we're using CGFloat <--> Double implicit conversion below.
	var uiColor: UIColor {
		get {
			UIColor(red: red_, green: green_, blue: blue_, alpha: opacity_)
		}
		set {
			if let components = newValue.cgColor.components {
				items.forEach({ $0.objectWillChange.send() })
				red_ = components[0]
				green_ = components[1]
				blue_ = components[2]
				opacity_ = components[3]
			}
		}
	}

	
	// MARK: - Object Methods
	
	func updateValues(from draftLocation: DraftLocation) {
		
		// we first make these changes directly in Core Data
		name_ = draftLocation.name
		visitationOrder_ = Int32(draftLocation.visitationOrder)
		if let components = draftLocation.color.cgColor?.components {
			red_ = Double(components[0])
			green_ = Double(components[1])
			blue_ = Double(components[2])
			opacity_ = Double(components[3])
		} else {
			red_ = 0.0
			green_ = 1.0
			blue_ = 0.0
			opacity_ = 0.5
		}
		
		// one more thing: items associated with this location may want to know about
		// (some of) these changes.  reason: items rely on knowing some computed
		// properties such as uiColor, locationName, and visitationOrder.
		// usually, what i would do is this, to be sure that anyone who is
		// observing an Item as an @ObservedObject knows about the Location update:
		
		items.forEach({ $0.objectWillChange.send() })
	}
	
} // end of extension Location
