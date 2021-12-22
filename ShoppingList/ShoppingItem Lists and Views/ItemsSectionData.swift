//
//	  SectionData.swift
//	  ShoppingList
//
//	  Created by Jerry on 2/7/21.
//	  Copyright © 2021 Jerry. All rights reserved.
	

import Foundation

//	 MARK: - A Generic Sectioning of Items

/* in a sectioned data display, one consisting of a list of sections, and with each section being itself a list,
 you usually work with a structure that looks like this:
	
	 List {
	   ForEach(sections) { section in
	     Section(header: Text("title for this section")) {
		     ForEach(section.items) { item in
	          display the item for this row in this section
	       }
	     }
	   }
	 }
	
	 so the notion of this ItemsSectionData struct is that we use it to say what to draw in each section:
	
	 -- its title and
	 -- an array of items to show in the section
	
	 to use the generic display structure, just organize your data as a [SectionData] and
	 "plug it in" to the structure above.
	
one thing that's specific to this app ... i've added an index value for each section's data, to indicate whether
 it's section 1, or 2, or ...  there's no real need to do this in general, but i have placed two buttons on the first
 section in the ShoppingListView and the PurchasedItemsView to choose between one section for all items,
 or multiple sections.  so the header for the first section must recognize "i am the first section."  it's a little cheesey ...
 
 */
struct ItemsSectionData: Identifiable, Hashable {
	var id: Int { hashValue }  // so, this will work with ForEach, as if using id: \.self 
	let index: Int  // 1 for section 1, 2 for section 2, ...
	let title: String
	let items: [Item]
}

