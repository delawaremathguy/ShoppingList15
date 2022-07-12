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
	// that determines how the sectioning should be done).
	//
	// each item that appears has a NavigationLink to a detail view and has a contextMenu
	// associated with it; an action from the contextMenu  to delete an Item will require bringing
	// up an alert to confirm the deletion
	//
struct ItemListView: View {
	
		// MARK: - Incoming Data Source
	
	@EnvironmentObject private var dataManager: DataManager
	
		// this is the incoming section layout from the ShoppingListView or the PurchasedItemsView
	var sections: [ItemsSectionData]
		// the symbol to show for an Item that is tapped
	var sfSymbolName: String
		// whether we're multi-section or single section
	@Binding var multiSectionDisplay: Bool

		// MARK: - @State Values
	
		// hooks for showing a delete item confirmation, as well as which
		// Item it is we want to delete.
	@State private var isDeleteItemShowing = false
	@State private var itemToDelete: ItemStruct?
	
	
		// this is a temporary holding array for items being moved to the other list.  it's a
		// @State variable, so if any SelectableItemRowView or a context menu adds an Item
		// to this array, we will get some redrawing + animation; and we'll also have queued
		// the actual execution of the move to the purchased list to follow after the animation
		// completes -- and that deletion will again change this array and redraw.
	@State private var itemsChecked = [ItemStruct]()
	
	// MARK: - Body
		
	var body: some View {
		List {
			ForEach(sections) { section in
				Section(header: sectionHeader(section: section)) {
					ForEach(section.items) { itemStruct in
						NavigationLink {
							ModifyExistingItemView(itemStruct: itemStruct, dataManager: dataManager)
						} label: {
							SelectableItemRowView(itemStruct: itemStruct,
																		selected: itemsChecked.contains(itemStruct),
																		sfSymbolName: sfSymbolName,
																		handleTap: { handleItemTapped(itemStruct) })
						}
						.contextMenu {
							ItemContextMenu(item: itemStruct) {
								itemToDelete = itemStruct
								isDeleteItemShowing = true
							} // end of itemContextMenu
						} // end of contextMenu
					} // end of ForEach
				} // end of Section
			} // end of ForEach
		}  // end of List ... phew!
		.listStyle(InsetGroupedListStyle())
		.animation(.default, value: sections)
		.alert(alertTitle(), isPresented: $isDeleteItemShowing) {
			Button("OK", role: .destructive) {
				withAnimation { dataManager.delete(itemStruct: itemToDelete) }
				dataManager.saveData()
			}
		} message: {
			Text(alertMessage())
		}
		
	} // end of body: some View
	
	func alertTitle() -> String {
		if let item = itemToDelete {
			return "Delete \'\(item.name)\'?"
		}
		return ""
	}
	
	func alertMessage() -> String {
		if let item = itemToDelete {
			return "Are you sure you want to delete the Item named \'\(item.name)\'? This action cannot be undone."
		}
		return ""
	}
	
	@ViewBuilder
	func sectionHeader(section: ItemsSectionData) -> some View {
		HStack {
			Text(section.title).textCase(.none)
			
			if section.index == 1 {
				Spacer()
				
				SectionHeaderButton(selected: multiSectionDisplay == false, systemName: "tray") {
					multiSectionDisplay = false
				}
				
				Rectangle()
					.frame(width: 1, height: 20)
				
				SectionHeaderButton(selected: multiSectionDisplay == true, systemName: "tray.2") {
					multiSectionDisplay = true
				}
			} // end of if ...
		} // end of HStack
	}
	
	func handleItemTapped(_ itemStruct: ItemStruct) {
		if !itemsChecked.contains(itemStruct) {
				// put the item into our list of what's about to be removed, and because
				// itemsChecked is a @State variable, we will see a momentary
				// animation showing the change.
			itemsChecked.append(itemStruct)
				// and we queue the actual removal long enough to allow animation to finish
			DispatchQueue.main.asyncAfter(deadline: .now() + 0.50) {
				withAnimation {
					dataManager.toggleOnListStatus(item: itemStruct)
					itemsChecked.removeAll(where: { $0 == itemStruct })
				}
			}
		}
	}
		
}

// MARK: - ItemContextMenu

	// provides a context menu for an Item that can be used to quickly move the item to the
	// other list, toggle the state of the availability, or delete the item.
	//
	// note: this replaces the previous @ViewBuilder function and is, i think, a little
	// cleaner ... but there remains a problem that i do not fully understand, and one that either
	// has now appeared in iOS 15, or one that was present under iOS 14 and no one noticed?
	//
	// the problem:
	// -- long-press on an item that is available
	// -- context menu comes down, second element reads "Mark As Unavailable" with pencil.slash
	// -- item now appears italic + strikethrough, indicating not available
	// -- long-press on the item a second time
	// -- context menu comes down, second element STILL READS "Mark As Unavailable" with pencil.slash
	//
	// and the problem is inverted for an item that comes on-screen as unavailable.  the first
	// long-press shows "Mark as Available with pencil; further long-presses show the same menu.
	//
	// i think this is a bug in SwiftUI, and eventually it will get fixed, but maybe not here and not now.
	// (i have submitted feedback on this to Apple:
	//      FB9811060: SwiftUI: ContextMenu Item Display Not Updating Correctly)
	//
	// and, for the record, with iOS 15.0, you'll see three messages appear on the console
	// when the menu is drawn that look something like this (one for each item in the context menu):
	//
	// [UICollectionViewRecursion] cv == 0x7fb5bb80e800 Disabling recursion trigger logging
	//
	// these messages seem to now be gone in iOS 15.2, but the problem remains (!)
	//
struct ItemContextMenu: View {
	
	@EnvironmentObject private var dataManager: DataManager
	
	// i have tried using this both with and without marking the item as an ObservedObject; it
	// makes no difference which way i do this; it's still the wrong display the second time
	// the context menu comes down.  (i have filed Feedback ... i will not hold my breath.)
	// @ObservedObject
	var item: ItemStruct
	var affirmDeletion: () -> Void
	
	var body: some View {
		Button(action: { dataManager.toggleOnListStatus(item: item) }) {
			Text(item.onList ? "Move to Purchased" : "Move to ShoppingList")
			Image(systemName: item.onList ? "purchased" : "cart")
		}
		
		Button(action: { dataManager.toggleAvailableStatus(itemStruct: item) }) {
			Text(item.isAvailable ? "Mark as Unavailable" : "Mark as Available")
			Image(systemName: item.isAvailable ? "pencil.slash" : "pencil")
		}
		
		Button(action: { affirmDeletion() }) {
			Text("Delete This Item")
			Image(systemName: "trash")
		}
	}
	
}
