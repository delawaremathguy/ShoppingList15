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
	// reasons," but i will keep it here until/if it comes back into the language.
	func count(where selector: (Element) -> Bool) -> Int {
		reduce(0) { (sum, Element) -> Int in
			return selector(Element) ? sum + 1 : sum
		}
	}
	
	// these two useful things come from John Sundell that let's us do some things
	// based on keypaths.
	//    https://www.swiftbysundell.com/articles/the-power-of-key-paths-in-swift/
	// i use the .sorted(by:) keypath approach in Location+Extensions.swift and ShoppingListView.swift.
	// i use the map syntax in Development.swift.
	
	func map<T>(_ keyPath: KeyPath<Element, T>) -> [T] {
		return map { $0[keyPath: keyPath] }
	}
	
	func sorted<T: Comparable>(by keyPath: KeyPath<Element, T>) -> [Element] {
		return sorted { a, b in
			return a[keyPath: keyPath] < b[keyPath: keyPath]
		}
	}
}
