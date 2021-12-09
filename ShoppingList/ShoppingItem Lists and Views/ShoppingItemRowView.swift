//
//  ShoppingItemRowView.swift
//  ShoppingList
//
//  Created by Jerry on 5/14/20.
//  Copyright © 2020 Jerry. All rights reserved.
//

import SwiftUI

// a ShoppingItemRowView does not have any object references itself; rather,

struct ShoppingItemRowData {
	var isAvailable: Bool = true
	var name: String = ""
	var locationName: String = ""
	var quantity: Int32 = 0
	var showLocation: Bool = true	// whether this is a two-line display, with location as secondary line
	var uiColor = UIColor()
	
	init(item: ShoppingItem, showLocation: Bool = true) {
		// note on init: because objects come out of Core Data, there have been times in development
		// where the List code seems to say that a Core Data item that's been/is being deleted is still
		// sort of there: it shows up as an item with item.isDeleted = false, but item.isFault = true
		// and that means that it cannot find its optional name string, or its location.  so the
		// code below just protects against that in case it ever shows up again -- although i have not
		// seen this with XCode 11.6/iOS 13.6 anytime recently.
		
		// nevertheless, even if it's not happening anymore, you should know that the funny thing is,
		// it almost never happened except for when the very last item remaining in the ShoppingList
		// is deleted; and in some cases, because of the nil-coalescing code below, you could actually
		// see the name of the item being changed to "Item being deleted" before it disappeared.
		// again, in XCode 11.6, i have not seen this; but the underlying problem seems to remain
		// in XCode 12 beta4, despite the fact that i have removed all use of @FetchRequest coding
		// and implemented my own viewModels as a replacement.  i think it's all about timing of
		// when SwiftUI and Core Data do their things; and it's clear that XCode 12 beta4 and
		// SwiftUI 2 handles the timing correctly
		// of when Views are created and destroyed much differently than XCode 11.6 and SwiftUI 1 did.
		
		// so the nil-coalescing below is built-in protection for any such case.  it appears you
		// really do need this protection in XCode 12 beta 4.  bottom line: i am not going to
		// fight with this anymore -- i'll just go with the flow for now.
		isAvailable = item.isAvailable
		name = item.name
		locationName = item.location?.name ?? "Some Location"
		quantity = item.quantity
		self.showLocation = showLocation
		uiColor = item.backgroundColor
	}
	
	init() { } // syntax necessity, although all values are reasonable setd
	
}

// shows one line in a list for a shopping item.  pass in the data to be shown.
struct ShoppingItemRowView: View {
	
	var itemData: ShoppingItemRowData
	
	var body: some View {
		HStack {
			// color bar at left (new in this code)
			Color(itemData.uiColor)
				.frame(width: 10, height: 36)
			
			VStack(alignment: .leading) {
				
				if itemData.isAvailable {
					Text(itemData.name)
				} else {
					Text(itemData.name)
						.italic()
						.foregroundColor(Color(.systemGray3))
						.strikethrough()
				}
				
				if itemData.showLocation {
					Text(itemData.locationName)
						.font(.caption)
						.foregroundColor(.secondary)
				}
			}
			
			Spacer()
			
			Text("\(itemData.quantity)")
				.font(.headline)
				.foregroundColor(Color.blue)
			
		} // end of HStack
	}

}

