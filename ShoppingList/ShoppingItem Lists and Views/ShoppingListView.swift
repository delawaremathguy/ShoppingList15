//
//  ShoppingListView.swift
//  ShoppingList
//
//  Created by Jerry on 4/22/20.
//  Copyright © 2020 Jerry. All rights reserved.
//

import ActivityView
import MessageUI
import SwiftUI

struct ShoppingListView: View {
		
	// this is the @FetchRequest that ties this view to CoreData Items
	@FetchRequest(fetchRequest: Item.allItemsFR(onList: true))
	private var items: FetchedResults<Item>

	// alert to move all items off the shopping list, and it is also used to trigger an
	// alert to delete an item in the shopping list
	@State private var identifiableAlertItem: IdentifiableAlertItem?
	
	// sheet used to add a new item
	@State private var identifiableSheetItem: IdentifiableSheetItem?
	
	// local state for are we a multi-section display or not.  the default here is false,
	// but an eager developer could easily store this default value in UserDefaults (?)
	@State var multiSectionDisplay: Bool = false
		
	// trigger to bring up a share sheet (see the ActivityView package)
	@State private var activityItem: ActivityItem?
	
	// we use an init, just to track when this view is initialized.  it can be removed (!)
	init() {
		print("ShoppingListView initialized")
	}
	
	var body: some View {
			VStack(spacing: 0) {
				
				Rectangle()
					.frame(height: 1)
				
/* ---------
we display either a "List is Empty" view, a single-section shopping list view
or multi-section shopping list view.  the list display has some complexity to it because
of the sectioning, so we push it off to a specialized View.
---------- */

				if items.count == 0 {
					EmptyListView(listName: "Shopping")
				} else {
					ItemListView(sections: sectionData(),
											 sfSymbolName: "purchased",
											 identifiableAlertItem: $identifiableAlertItem,
											 multiSectionDisplay: $multiSectionDisplay)
				}
				
/* ---------
and for non-empty lists, we have a few buttons at the end for bulk operations
---------- */

				if items.count > 0 {
					Divider()
					
					ShoppingListBottomButtons(itemsToBePurchased: items) {
						identifiableAlertItem = ConfirmMoveAllItemsOffShoppingListAlert()
					}
				} //end of if items.count > 0

				Divider()

			} // end of VStack
			.navigationBarTitle("Shopping List")
			.toolbar {
				ToolbarItem(placement: .navigationBarTrailing, content: trailingButtons)
			}
		.alert(item: $identifiableAlertItem) { item in item.alert() }
		.sheet(item: $identifiableSheetItem) { item in item.content() }

		.onAppear {
			logAppear(title: "ShoppingListView")
		}
		.onDisappear {
			logDisappear(title: "ShoppingListView")
			PersistentStore.shared.saveContext()
		}
		
	} // end of body: some View
	
	func sectionData() -> [ItemsSectionData] {
		
			// the easy case: if this is not a multi-section list, there will be one section with a title
			// and an array of all the items
		if !multiSectionDisplay {
				// if you want to change the sorting when this is a single section to "by name"
				// then comment out the .sorted() qualifier -- itemsToBePurchased is already sorted by name
			let sortedItems = items
				.sorted(by: { $0.location.visitationOrder < $1.location.visitationOrder })
			return [ItemsSectionData(index: 1, title: "Items Remaining: \(items.count)", items: sortedItems)
			]
		}
		
			// otherwise, one section for each location, please.  break the data out by location first
		let dictionaryByLocation = Dictionary(grouping: items, by: { $0.location })
			// then reassemble the sections by sorted keys of this dictionary
		var completedSectionData = [ItemsSectionData]()
		var index = 1
		for key in dictionaryByLocation.keys.sorted() {
			completedSectionData.append(ItemsSectionData(index: index, title: key.name, items: dictionaryByLocation[key]!))
			index += 1
		}
		return completedSectionData
	}
	
	// MARK: - ToolbarItems
	
	func trailingButtons() -> some View {
		HStack(spacing: 12) {
			Button {
				// setting the activityItem triggers the ActivityViewController
				// to share a text representation of the shopping list (see ActivityView package)
				activityItem = ActivityItem(items: shareContent())
			} label: {
				Image(systemName: "square.and.arrow.up")
			}
				// this is where the share sheet is controlled (see ActivityView package)
			.activitySheet($activityItem)
			.disabled(items.count == 0)

			NavBarImageButton("plus") {
				identifiableSheetItem = AddNewItemSheetItem() { identifiableSheetItem = nil }
			}
		}
	}
	
	// MARK: - Sharing support
	
	func shareContent() -> String {
		
		// we share a straight-forward text description of the shopping list, broken out by location.
		var message = "Items on your Shopping List: \n"
		
			// pull out Locations appearing in the shopping list as a dictionary, keyed by location
			// and write the shareContent message = one big string
		let dictionary = Dictionary(grouping: items, by: { $0.location })
		for key in dictionary.keys.sorted() {
			let items = dictionary[key]!
			message += "\n\(key.name), \(items.count) item(s)\n\n"
			for item in items {
				message += "  \(item.name)\n"
			}
		}
		
		return message
	}

} // end of ShoppingListView


struct ShoppingListBottomButtons: View {
	
		// incoming list of items to be purchased
	var itemsToBePurchased: FetchedResults<Item>
		// incoming function: what to do when the user wants to move all items of the shopping list
	var moveAllItemsOffShoppingList: () -> ()
		// determines whether to show the "Mark All Available" button
	var showMarkAllAvailable: Bool { !itemsToBePurchased.allSatisfy({ $0.isAvailable }) }
	
	var body: some View {
		
		HStack {
			Spacer()
			
			Button {
				moveAllItemsOffShoppingList()
			} label: {
				Text("Move All Off List")
			}
			
			if showMarkAllAvailable {
				Spacer()
				
				Button {
					itemsToBePurchased.forEach { $0.markAvailable() }
				} label: {
					Text("Mark All Available")
				}
			}
			
			Spacer()
		}
		.padding(.vertical, 6)
		.animation(.easeInOut(duration: 0.4), value: showMarkAllAvailable)

	}
	
} // end of ShoppingListBottomButtons
