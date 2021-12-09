//
//  ShoppingListDisplay.swift
//  ShoppingList
//
//  Created by Jerry on 11/30/20.
//  Copyright © 2020 Jerry. All rights reserved.
//

import Foundation
import SwiftUI

// MARK: - ShoppingListView

// THIS FILE OBSOLETED.  THERE WERE SOME CHANGES IN THE XCODE 12.4 AND IOS 14.4
// SDK THAT MADE THIS NOT WORK; AND, UPON REVIEW, I'M NOT SURE WHY IT EVEN DID
// WORK.

// this is a subview of the ShoppingListTabView and shows itemsToBePurchased
// as either a single section or as multiple sections, one section for each Location.
// it uses a somewhat intricate, but standard,Form/ForEach/Section/ForEach construct
// to present the list in sections and requires some preliminary work to perform the
// sectioning.
//
// each item that appears has a NavigationLink to a detail view and a contextMenu
// associated with it; actions from the contextMenu may require bringing up an alert,
// but we will not do that here in this view.  we will simply set @Binding variables
// from the parent view appropriately and let the parent deal with it (e.g., because
// the parent uses the same structure to present an alert already to move all items
// of the list).
struct ShoppingListViewObsoleted: View {
	
	// this is the @FetchRequest that ties this view to CoreData Items.
	// comment: this is driven by Locations that have items on the list, so any
	// changes to a Location (especially visitation order) will trigger an update;
	// and since each of the rows tracks its Item as an @ObservedObject, the row
	// display will update for changes to Items.
	@FetchRequest(fetchRequest: Location.fetchAllLocations(onList: true))
	private var locationsWithItemsOnList: FetchedResults<Location>

	// display format: one big section of Items, or sectioned by Location?
	// (not sure we need a Binding here ... we only read the value)
	@Binding var multiSectionDisplay: Bool
		
	// state variable to control triggering confirmation of a delete, which is
	// one of three context menu actions that can be applied to an item
	@Binding var confirmationAlert: ConfirmationAlert
	
	// this is a temporary holding array for items being moved to the other list.  it's a
	// @State variable, so if any SelectableItemRowView or a context menu adds an Item
	// to this array, we will get some redrawing + animation; and we'll also have queued
	// the actual execution of the move to the purchased list to follow after the animation
	// completes -- and that deletion will again change this array and redraw.
	@State private var itemsChecked = [Item]()
	
	var body: some View {
		Form {
			ForEach(sectionData()) { section in
				Section(header: Text(section.title).sectionHeader()) {
					// display items in this location
					ForEach(section.items) { item in
						// display a single row here for 'item'
						NavigationLink(destination: AddorModifyItemView(editableItem: item)) {
							SelectableItemRowView(item: item,
																		selected: itemsChecked.contains(item),
																		sfSymbolName: "purchased",
																		respondToTapOnSelector:  { handleItemTapped(item) })
								.contextMenu {
									itemContextMenu(item: item, deletionTrigger: {
										confirmationAlert.trigger(type: .deleteItem(item))
									})
								} // end of contextMenu
						} // end of NavigationLink
					} // end of ForEach
				} // end of Section
			} // end of ForEach
		}  // end of Form
	} // end of body: some View
	
	// the purpose of this function is to break out the itemsToBePurchased by section,
	// according to whether the list is displayed as a single section or in multiple
	// sections (one for each Location that contains shopping items on the list)
	func sectionData() -> [SectionData] {
		
		// the first case: one section with a title and all the items.  collect all items on list
		// across these locations (they will be alphabetized within each location, and the
		// @FetchRequest returns the locations in visitation order
		if !multiSectionDisplay {
			var itemsToBePurchased = [Item]()
			for location in locationsWithItemsOnList {
				itemsToBePurchased += location.items.filter({ $0.onList }).sorted(by: { $0.name < $1.name })
			}
			return [SectionData(title: "Items Remaining: \(itemsToBePurchased.count)", items: itemsToBePurchased)]
		}
		
		// otherwise, one section for each location
		var completedSectionData = [SectionData]()
		for location in locationsWithItemsOnList {
			let itemsOnList = location.items.filter({ $0.onList }).sorted(by: { $0.name < $1.name })
			completedSectionData.append(SectionData(title: location.name, items: itemsOnList))
		}
		return completedSectionData
	}
	
	func handleItemTapped(_ item: Item) {
		if !itemsChecked.contains(item) {
			// put the item into our list of what's about to be removed, and because
			// itemsChecked is a @State variable, we will see a momentary
			// animation showing the change.
			itemsChecked.append(item)
			// and we queue the actual removal long enough to allow animation to finish
			DispatchQueue.main.asyncAfter(deadline: .now() + 0.40) {
				item.toggleOnListStatus()
				itemsChecked.removeAll(where: { $0 == item })
			}
		}
	}
	
}
