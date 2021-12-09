//
//  View+Extensions.swift
//  ShoppingList
//
//  Created by Jerry on 12/10/20.
//  Copyright © 2020 Jerry. All rights reserved.
//

import Foundation
import SwiftUI

// define a sectionHeader View modifier (to avoid iOS 14 ALL-CAPS style)
struct SectionHeader: ViewModifier {
	func body(content: Content) -> some View {
		content
			.textCase(.none)
	}
}

extension View {
	func sectionHeader() -> some View {
		modifier(SectionHeader())
	}
}
