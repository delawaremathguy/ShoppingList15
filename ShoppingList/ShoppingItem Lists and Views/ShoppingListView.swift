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
	
		// MARK: - Incoming Data Source
	
	@EnvironmentObject private var dataManager: DataManager
	
	// MARK: - @State Values
	
		// sheet used to add a new item
	@State private var isAddNewItemSheetShowing = false
	
		// local state for are we a multi-section display or not.  the default here is false,
		// but an eager developer could easily store this default value in UserDefaults (?)
	@State var multiSectionDisplay: Bool = false
	
		// trigger to bring up a share sheet (see the ActivityView package)
	@State private var activityItem: ActivityItem?
	
		// MARK: - Computed Variables

	var itemStructs: [ItemStruct] { dataManager.itemStructs.filter({ $0.onList }) }
		
	// we use an init, just to track when this view is initialized.  it can be removed (!)
//	init() {
//		print("ShoppingListView initialized")
//	}

		// MARK: - Body
	
	var body: some View {
		VStack(spacing: 0) {
				
			Rectangle()
				.frame(height: 1)
				
/* ---------
we display either a "List is Empty" view, a single-section shopping list view
or multi-section shopping list view.  the list display has some complexity to it because
of the sectioning, so we push it off to a specialized View.
---------- */

			if itemStructs.count == 0 {
				EmptyListView(listName: "Shopping")
			} else {
				ItemListView(sections: sectionData(),
										 sfSymbolName: "purchased",
										 multiSectionDisplay: $multiSectionDisplay)
			}
				
/* ---------
and for non-empty lists, we have a few buttons at the end for bulk operations
---------- */

			if itemStructs.count > 0 {
				Divider()
				ShoppingListBottomButtons(itemsToBePurchased: itemStructs)
			}
			
			Divider()
			
		} // end of VStack
		.navigationBarTitle("Shopping List")
		.toolbar {
			ToolbarItem(placement: .primaryAction, content: trailingButtons)
		}
		.sheet(isPresented: $isAddNewItemSheetShowing) {
			AddNewItemView(dataManager: dataManager) {
				isAddNewItemSheetShowing = false
			}
		}
		
		.onDisappear {
			dataManager.saveData()
		}
		
	} // end of body: some View
	
	// MARK: - Support Functions
	
	func sectionData() -> [ItemsSectionData] {
		
			// the easy case: if this is not a multi-section list, there will be one section with a title
			// and an array of all the items
		if !multiSectionDisplay {
				// if you want to change the sorting when this is a single section to "by name"
				// then comment out the .sorted() qualifier -- itemsToBePurchased is already sorted by name
			let sortedItems = itemStructs
				.sorted(by: \.visitationOrder)
			return [ItemsSectionData(index: 1,
															 title: "Items Remaining: \(itemStructs.count)",
															 items: sortedItems)]
		}
		
			// otherwise, we want one section for each location, according to visitation order
		let dictionaryByVisitationOder =
			Dictionary(grouping: itemStructs, by: { $0.visitationOrder })
		
			// then reassemble the sections by sorted keys of this dictionary
		var completedSectionData = [ItemsSectionData]()
		var index = 1
		for key in dictionaryByVisitationOder.keys.sorted() {
			let keyItems = dictionaryByVisitationOder[key]!
			let title = keyItems.first!.locationName
			completedSectionData.append(ItemsSectionData(index: index, title: title, items: keyItems))
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
			.disabled(itemStructs.count == 0)

			SystemImageButton("plus") {
				isAddNewItemSheetShowing = true
			}
		}
	}
	
	// MARK: - Sharing support
	
	func shareContent() -> String {
		
		// we share a straight-forward text description of the shopping list, broken out by location.
		var message = "Items on your Shopping List: \n"
		
			// pull out Locations appearing in the shopping list as a dictionary, keyed by location
			// and write the shareContent message = one big string
		let sortedItems = itemStructs.sorted(by: \.visitationOrder)
		let dictionary = Dictionary(grouping: sortedItems, by: { $0.locationName })
		for key in dictionary.keys {
			let items = dictionary[key]!
			message += "\n\(key), \(items.count) item(s)\n\n"
			for item in items {
				message += "  \(item.name)\n"
			}
		}
		
		return message
	}

} // end of ShoppingListView


