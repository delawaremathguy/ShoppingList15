//
//  Date+Extensions.swift
//  ShoppingList
//
//  Created by Jerry on 11/30/20.
//  Copyright © 2020 Jerry. All rights reserved.
//

import Foundation

extension Date {
	
	func dateText(style: DateFormatter.Style)-> String {
		// appeal to some nice formatting help
		let dateFormatter = DateFormatter()
		dateFormatter.doesRelativeDateFormatting = true
		dateFormatter.timeStyle = .none // just show date without specific time
		dateFormatter.dateStyle = style
		dateFormatter.locale = Locale.autoupdatingCurrent  // Locale(identifier: "en_US")
		return dateFormatter.string(from: self)
	}
}
