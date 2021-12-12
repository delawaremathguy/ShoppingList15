//
//  SectionData.swift
//  ShoppingList
//
//  Created by Jerry on 2/7/21.
//  Copyright © 2021 Jerry. All rights reserved.
//

import Foundation

// MARK: - A Generic Sectioning of Items

// in a sectioned data display, one consisting of a list of sections, and with each section
// being itself a list, you usually work with a structure that looks like this:
//
// List {
//   ForEach(sections) { section in
//     Section(header: Text("title for this section")) {
//	     ForEach(section.items) { item in
//         // display the item for this row in this section
//       }
//     }
//   }
// }
//
// so the notion of this ItemsSectionData struct is that we use it to say what to draw in each
// section:
//
// -- its title and
// -- an array of items to show in the section
//
// to use the generic display structure, just organize your data as a [SectionData] and
// "plug it in" to the structure above.
//
struct ItemsSectionData: Identifiable, Hashable {
	var id: Int { hashValue } // so, this is like id: \.self for SwiftUI
	let title: String
	let items: [Item]
}

