//
//  Sequence+Extensions.swift
//  ShoppingList
//
//  Created by Jerry on 6/4/20.
//  Copyright © 2020 Jerry. All rights reserved.
//

import Foundation

extension Sequence {
	
	// counts the number of elements that satisfy a given boolean condition.  this
	// was originally included in Swift 5.0, but was later withdrawn "for performance
	// reasons," so i will keep it here until/if it comes back into the language
	func count(where selector: (Element) -> Bool) -> Int {
		reduce(0) { (sum, Element) -> Int in
			return selector(Element) ? sum + 1 : sum
		}
	}
}
