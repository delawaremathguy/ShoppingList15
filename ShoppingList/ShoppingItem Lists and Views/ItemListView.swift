	//
	//  ShoppingListDisplay.swift
	//  ShoppingList
	//
	//  Created by Jerry on 2/7/21.
	//  Copyright © 2021 Jerry. All rights reserved.
	//

import Foundation
import SwiftUI

	// MARK: - ItemListView

	// this is a subview of the ShoppingListView and the PurchasedItemsView, and shows a
	// sectioned list of Items that is determined by the caller (who then must supply a function
	// that determines how the sectioning should be done)
	//
	// each item that appears has a NavigationLink to a detail view and has a contextMenu
	// associated with it; an action from the contextMenu  to delete an Item will require bringing
	// up an alert to confirm the deletion, but we will not do that here in this view.  we will simply
	// set the @Binding variable identifiableAlertItem from the parent view appropriately and let
	// the parent deal with it (e.g., because the parent uses the same identifiableAlertItem structure
	// to present its own alerts.
	//
struct ItemListView: View {
	
		// this is the incoming @FetchRequest from either ShoppingListView or PurchasedItemsViews
	var items: FetchedResults<Item>
		// what symbol to show for an Item that is tapped
	var sfSymbolName: String
	
		// this is an incoming binding to the parent view's alert trigger mechanism,which lets us
		// post an alert on the parent view, just by setting it here
	@Binding var identifiableAlertItem: IdentifiableAlertItem?
	
		// this is the sectioning function to use on the items for display
	var sectionData: () -> [ItemsSectionData]
	
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
							SelectableItemRowView(item: item, selected: itemsChecked.contains(item), sfSymbolName: sfSymbolName) {
								handleItemTapped(item)
							}
							.contextMenu {
								itemContextMenu(item: item) {
									identifiableAlertItem = ConfirmDeleteItemAlert(item: item) {
										identifiableAlertItem = nil
									}
								} // end of itemContextMenu
							} // end of contextMenu
						} // end of NavigationLink
					} // end of ForEach
				} // end of Section
			} // end of ForEach
		}  // end of List
		.listStyle(InsetGroupedListStyle())
		
	} // end of body: some View
	
	
	func handleItemTapped(_ item: Item) {
		if !itemsChecked.contains(item) {
				// put the item into our list of what's about to be removed, and because
				// itemsChecked is a @State variable, we will see a momentary
				// animation showing the change.
			itemsChecked.append(item)
				// and we queue the actual removal long enough to allow animation to finish
			DispatchQueue.main.asyncAfter(deadline: .now() + 0.50) {
				item.toggleOnListStatus()
				itemsChecked.removeAll(where: { $0 == item })
			}
		}
	}
	
		// Builds out a context menu for an Item that can be used to quickly move the item to the
		// other list, toggle the state of the availability, or delete the item.
		//
	@ViewBuilder
	func itemContextMenu(item: Item, affirmDeletion: @escaping () -> Void) -> some View {
		
		Button(action: { item.toggleOnListStatus() }) {
			Text(item.onList ? "Move to Purchased" : "Move to ShoppingList")
			Image(systemName: item.onList ? "purchased" : "cart")
		}
		
		Button(action: { item.toggleAvailableStatus() }) {
			Text(item.isAvailable ? "Mark as Unavailable" : "Mark as Available")
			Image(systemName: item.isAvailable ? "pencil.slash" : "pencil")
		}
		
		Button(action: { affirmDeletion() }) {
			Text("Delete This Item")
			Image(systemName: "trash")
		}
	}
	
}
