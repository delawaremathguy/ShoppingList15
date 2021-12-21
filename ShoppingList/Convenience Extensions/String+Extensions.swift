//
//  String+Extensions.swift
//  ShoppingList
//
//  Created by Jerry on 11/18/20.
//  Copyright © 2020 Jerry. All rights reserved.
//

import Foundation

extension String {
	
	// this is useful in asking whether the searchText of the PurchasedItemsView
	// appears in item names; it makes things more straightforward at the call site.
	func appearsIn(_ str: String) -> Bool {
		let cleanedSearchText = self.trimmingCharacters(in: .whitespacesAndNewlines)
		if cleanedSearchText.isEmpty {
			return true
		}
		return str.localizedCaseInsensitiveContains(cleanedSearchText)
	}
}
