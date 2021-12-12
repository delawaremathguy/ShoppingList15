//
//  ShoppingListDisplay.swift
//  ShoppingList
//
//  Created by Jerry on 2/7/21.
//  Copyright © 2021 Jerry. All rights reserved.
//

import Foundation
import SwiftUI

// MARK: - ShoppingListDisplay

// this is a subview of the ShoppingListView and shows itemsToBePurchased
// as either a single section or as multiple sections, one section for each Location.
// it uses a somewhat intricate, but standard,Form/ForEach/Section/ForEach construct
// to present the list in sections and requires some preliminary work to perform the
// sectioning.
//
// each item that appears has a NavigationLink to a detail view and has a contextMenu
// associated with it; actions from the contextMenu may require bringing up an alert,
// but we will not do that here in this view.  we will simply set @Binding variables
// from the parent view appropriately and let the parent deal with it (e.g., because
// the parent uses the same structure to present an alert already to move all items
// off the list).
struct ShoppingListDisplay: View {
	
	// this really should not need to be here, but when we put up a confirmation alert to
	// delete an item, SwiftUI complains if we proceed to delete the item because we never
	// really let it know we were going to make changes to a managed object context
	// that it does not know about.
	@Environment(\.managedObjectContext) var moc

	
	// this is the incoming @FetchRequest from ShoppingListView
	var itemsToBePurchased: FetchedResults<Item>
	
	// display format: one big section of Items, or sectioned by Location?
	// (not sure we need a Binding here ... we only read the value)
	@Binding var multiSectionDisplay: Bool
	
	// state variable to control triggering confirmation of a delete, which is
	// one of three context menu actions that can be applied to an item
	@State var confirmDeleteItemAlert: IdentifiableAlertItem?
	
	// this is a temporary holding array for items being moved to the other list.  it's a
	// @State variable, so if any SelectableItemRowView or a context menu adds an Item
	// to this array, we will get some redrawing + animation; and we'll also have queued
	// the actual execution of the move to the purchased list to follow after the animation
	// completes -- and that deletion will again change this array and redraw.
	@State private var itemsChecked = [Item]()
	
	var body: some View {
		List {
			ForEach(sectionData()) { section in
				Section(header: Text(section.title).sectionHeader()) {
					// display items in this location
					ForEach(section.items) { item in
						// display a single row here for 'item'
						NavigationLink(destination: ModifyExistingItemView(editableItem: item)) {
							SelectableItemRowView(item: item,
																		selected: itemsChecked.contains(item),
																		sfSymbolName: "purchased",
																		respondToTapOnSelector:  { handleItemTapped(item) })
								.contextMenu {
									itemContextMenu(item: item, deletionTrigger: {
										confirmDeleteItemAlert = ConfirmDeleteItemAlert(item: item) {
											confirmDeleteItemAlert = nil
										}
									})
								} // end of contextMenu
						} // end of NavigationLink
					} // end of ForEach
				} // end of Section
			} // end of ForEach
		}  // end of List
		.listStyle(InsetGroupedListStyle())
		.alert(item: $confirmDeleteItemAlert) { item in item.alert() }

	} // end of body: some View
	
	// the purpose of this function is to break out the itemsToBePurchased by section,
	// according to whether the list is displayed as a single section or in multiple
	// sections (one for each Location that contains shopping items on the list)
	func sectionData() -> [SectionData] {
		
		// the easy case: if this is not a multi-section list, there will be one section with a title
		// and an array of all the items
		if !multiSectionDisplay {
			// if you want to change the sorting when this is a single section to "by name"
			// then comment out the .sorted() qualifier -- itemsToBePurchased is already sorted by name
			let sortedItems = itemsToBePurchased
				.sorted(by: { $0.location.visitationOrder < $1.location.visitationOrder })
			return [SectionData(title: "Items Remaining: \(itemsToBePurchased.count)", items: sortedItems)
			]
		}
		
		// otherwise, one section for each location, please.  break the data out by location first
		let dictionaryByLocation = Dictionary(grouping: itemsToBePurchased, by: { $0.location })
		// then reassemble the sections by sorted keys of this dictionary
		var completedSectionData = [SectionData]()
		for key in dictionaryByLocation.keys.sorted() {
			completedSectionData.append(SectionData(title: key.name, items: dictionaryByLocation[key]!))
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
