//
//  SelectableItemRowView.swift
//  ShoppingList
//
//  Created by Jerry on 11/28/20.
//  Copyright © 2020 Jerry. All rights reserved.
//

import Foundation
import SwiftUI

// MARK: - SelectableItemRowView

struct SelectableItemRowView: View {
	
	// incoming are an item, whether that item is selected or not, what symbol
	// to use for animation, and what to do when the selector is tapped.  we treat
	// the item as an @ObservedObject: we want to get redrawn if any property changes.
	
	@ObservedObject var item: Item
	var selected: Bool
	var sfSymbolName: String
	var respondToTapOnSelector: () -> ()
	
	var body: some View {
		HStack {
			
			// --- build the little circle to tap on the left
			ZStack {
				// not sure if i want to have at least a visible circle here at the bottom or not.  for
				// some color choices (e.g., Dairy = white) nothing appears to be shown as tappable
//				Circle()
//					.stroke(Color(.systemGray6))
//					.frame(width: 28.5, height: 28.5)
				if selected {
					Image(systemName: "circle.fill")
						.foregroundColor(.blue)
						.font(.title)
				}
				Image(systemName: "circle")
					.foregroundColor(Color(item.uiColor))
					.font(.title)
				if selected {
					Image(systemName: sfSymbolName)
						.foregroundColor(.white)
						.font(.subheadline)
				}
			} // end of ZStack
			.animation(Animation.easeInOut(duration: 0.5))
			.frame(width: 24, height: 24)
			.onTapGesture { respondToTapOnSelector() }
			
			// color bar is next
			Color(item.uiColor)
				.frame(width: 10, height: 36)
			
			// name and location
			VStack(alignment: .leading) {
				
				if item.isAvailable {
					Text(item.name)
				} else {
					Text(item.name)
						.italic()
						.strikethrough()
				}
				
				Text(item.locationName)
					.font(.caption)
					.foregroundColor(.secondary)
			}
			
			Spacer()
			
			// quantity at the right
			Text("\(item.quantity)")
				.font(.headline)
				.foregroundColor(Color.blue)
			
		} // end of HStack
	}
}


// MARK: - SelectableItemRowData Definition

/*-- IGNORE -------------------------------------------------------------------------
//struct SelectableItemRowData {
//	let name: String
//	let quantity: Int
//	let isAvailable: Bool
//	let uiColor: UIColor
//	let locationName: String
//
//	init(item: Item) {
//		name = item.name
//		quantity = item.quantity
//		isAvailable = item.isAvailable
//		uiColor = item.uiColor
//		locationName = item.locationName
//	}
//}

// Commentary: there are three approaches to moving data from an item in the
// shopping list or the purchased list into theSelectableItemRowView for display.
//
// 1. pass the Item as an @ObservedObject
// 2. pass the item and copy the necessary data from the item into local variables
// 3. pass the item's data
//
// it seems that the "right approach" should be #1, hold on to the item as an @Observed
// obect.  this is a problem should the item be deleted: because Item comes from
// Core Data, when it is deleted it does not go away immediately, but instead
// becomes an in-memory blob of zeroed-out data for which .isDeleted = false
// and .isFault = true.  and even despite calling processPendingEvents to try to
// clean up Core Data after a deletion, this View is still out there somewhere in
// SwiftUI, holding a reference to that item.  consequently, trying to use
// item.name_! results in a force-unwrap of a nil.
//
// you can gloss over this part by instead using item.name which is nil-coalesced,
// to at least give you something; but if you are using your own, non-Core Data object,
// i don't know what would happen -- so this would be just a bandaid to make SwiftUI and
// Core Data play nice together on deletions.
//
// so i tried #2: pass the item & copy the data to local variables.  now, even though we
// might have a reference to a deleted CD object, we captured its data when instantiated
// and use that data to drive the view.  that means you would create this view with
// something like "SelectableItemRowView(item: item, ...", but now the problem is that the
// parent view will not refresh this view when the parent redraws, because it looks like
// this will be the same view as before.  (that's my best guess)
//
// in short: if you "pass" an object reference to a View, you own that view and not
// SwiftUI; SwiftUI will hold on to this view as long as it holds on to the parent
// view.  adding @ObservedObject allows you to listen for changes and
// redraw as needed (SwiftUI will not do it for you)
//
// option #3 works: create this view with
// "SelectableItemRowView(rowData: SelectableItemRowData(item: item), ..." -- apparently
// this is enough to make SwiftUI see this as a pure struct without object references
// and therefore freely destroys and later recreates this view (and indeed all row views)
// when the parent's @FetchRequest gets triggered by an item's change.
// it works.

//var rowData: SelectableItemRowData

// this init need not appear -- it was used for testing purposes, but if you are
// interested in partially understanding my explanation above (assuming it's on the mark),
// un-comment this init and you'll see how often these row views are created and later
// re-created after having been destroyed.
//
// my suggested test: with an item appearing on the shopping list, go over to the
// Locations tab, select the location where the item is listed, tap on the item in the
// list of items at that location, change the item's quantity and flip the isAvailable switch,
// tap save, and watch the output!  go back to the shopping list: the item is properly
// updated because the whole view was recreated from scratch.
//	init(rowData: SelectableItemRowData, selected: Bool,
//			 sfSymbolName: String, respondToTapOnSelector: @escaping () -> Void) {
//		// copy item data to local variables
//		self.rowData = rowData
//		self.selected = selected
//		self.sfSymbolName = sfSymbolName
//		self.respondToTapOnSelector = respondToTapOnSelector
//
//		print("SelectableItemRowView instantiated for \(rowData.name)")
//	}


-- IGNORE -------------------------------------------------------------------------*/

