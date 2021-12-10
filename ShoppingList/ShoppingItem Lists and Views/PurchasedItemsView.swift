//
//  PurchasedItemsView.swift
//  ShoppingList
//
//  Created by Jerry on 5/14/20.
//  Copyright © 2020 Jerry. All rights reserved.
//

import SwiftUI

// a simple list of items that are not on the current shopping list
// these are the items that were on the shopping list at some time and
// were later removed -- items we purchased.  you could also call it a
// catalog, of sorts, although we only show items that we know about
// that are not already on the shopping list.

struct PurchasedItemsView: View {
	
	// this is the @FetchRequest that ties this view to CoreData
	@FetchRequest(fetchRequest: Item.allItemsFR(onList: false))
	private var purchasedItems: FetchedResults<Item>
	
	// the usual @State variables to handle the Search field and control
	// the action of the confirmation alert that you really do want to
	// delete an item
	@State private var searchText: String = ""
	
	// parameters to control triggering an Alert and defining what action
	// to take upon confirmation
	//@State private var confirmationAlert = ConfirmationAlert(type: .none)
	@State private var confirmDeleteItemAlert: ConfirmDeleteItemAlert?
	@State private var isAddNewItemSheetShowing = false
	
	// local state for are we a multi-section display or not.  the default here is false,
	// but an eager developer could easily store this default value in UserDefaults (?)
	@State var multiSectionDisplay: Bool = false
	
	// link in to what is the start of today
	@EnvironmentObject var today: Today
	
	// items currently checked, on their way to the shopping list
	@State private var itemsChecked = [Item]()
	
	// number of days in the past for the first section when using sections
	@AppStorage(wrappedValue: 3, "PurchasedHistoryMarker") private var historyMarker
	
	var body: some View {
		//NavigationView {
			VStack(spacing: 0) {
				
				/* ---------
				1. search bar & add new item "button" is at top.  note that the button action will put up the
				 AddNewItemView inside its own NavigationView (so the Picker will work!)
				---------- */
				
//				SearchBarView(text: $searchText)
				
//				Button(action: { isAddNewItemSheetShowing = true }) {
//					Text("Add New Item")
//						.foregroundColor(Color.blue)
//						.padding(10)
//				}
//				.sheet(isPresented: $isAddNewItemSheetShowing) {
//					NavigationView {
//						AddNewItemView(initialItemName: searchText)
//					}
//				}
				
				Rectangle()
					.frame(height: 1)
//					.padding(.vertical, 5)
				
				/* ---------
				2. we display either a "List is Empty" view, or the sectioned list of purchased
				items.  there is some complexity here, so review the ShoppingListDisplay.swift code
				for more discussion about sectioning
				---------- */
				
				if purchasedItems.count == 0 {
					EmptyListView(listName: "Purchased")
				} else {
						// notice use of sectioning strategy that is described in ShoppingListDisplay.swift
					List {
						ForEach(sectionData()) { section in
							Section(header: Text(section.title).sectionHeader()) {
								ForEach(section.items) { item in
										// display of a single item
									NavigationLink(destination: ModifyExistingItemView(editableItem: item)) {
										SelectableItemRowView(item: item,
																					selected: itemsChecked.contains(item),
																					sfSymbolName: "cart",
																					respondToTapOnSelector: { handleItemTapped(item) })
											.contextMenu {
												itemContextMenu(item: item,
																				deletionTrigger: {
													confirmDeleteItemAlert = ConfirmDeleteItemAlert(item: item)
												})
											} // end of contextMenu
									} // end of NavigationLink
								} // end of ForEach
							} // end of Section
						} // end of ForEach
					}  // end of List
					.listStyle(InsetGroupedListStyle())

				} // end of if-else
				
				Divider()
			} // end of VStack
			.onAppear {
				logAppear(title: "PurchasedTabView")
				handleOnAppear()
			}
			.onDisappear() {
				logDisappear(title: "PurchasedTabView")
				PersistentStore.shared.saveContext()
			}
			.navigationBarTitle("Purchased List")
			.toolbar {
				ToolbarItem(placement: .navigationBarLeading, content: sectionDisplayButton)
				ToolbarItem(placement: .navigationBarTrailing, content: addNewButton)
			}
			.alert(item: $confirmDeleteItemAlert) { item in item.alert()}
			.searchable(text: $searchText)
			
	}
	
	func handleOnAppear() {
		// clear searchText, get a clean screen
		searchText = ""
		// and also recompute what "today" means, so the sectioning is correct
		today.update()
	}
	
	// makes a simple "+" to add a new item
	func addNewButton() -> some View {
		Button(action: { isAddNewItemSheetShowing = true }) {
			Image(systemName: "plus")
				.font(.title2)
		}
	}
	
	// a toggle button to change section display mechanisms
	func sectionDisplayButton() -> some View {
		Button(action: { multiSectionDisplay.toggle() }) {
			Image(systemName: multiSectionDisplay ? "tray.2" : "tray")
				.font(.title2)
		}
	}
	
	
	func handleItemTapped(_ item: Item) {
		// we keep track of what's on it's way to going off screen; if this
		// item is already going off screen, don;t add it again.
		guard !itemsChecked.contains(item) else {
			return
		}
		
			// put into our list of what's about to be removed, and because
			// itemsChecked is a @State variable, we will see a momentary
			// animation showing the change.
		itemsChecked.append(item)
			// queue the removal to allow animation to run
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.40) {
			item.toggleOnListStatus()
			itemsChecked.removeAll(where: { $0 == item })
			// this UI changed in ShoppingList15: clear the search text to allow new search
			searchText = ""
		}
	}
	
	// the idea of this function is to break out the purchased Items into
	// 2 sections: those purchased today (within the last N days), and everything else
	func sectionData() -> [SectionData] {
		// reduce items by search criteria
		let searchQualifiedItems = purchasedItems.filter({ searchText.appearsIn($0.name) })
		
		// do we show one big section, or Today and then everything else?  one big section
		// is pretty darn easy:
		if !multiSectionDisplay {
			if searchText.isEmpty {
				return [SectionData(title: "Items Purchased: \(purchasedItems.count)",
														items: purchasedItems.map({ $0 }))]
			}
			return [SectionData(title: "Items Purchased containing: \"\(searchText)\": \(searchQualifiedItems.count)",
													items: searchQualifiedItems)]
		}
		
		// break these out into (Today + back historyMarker days) and (all the others)
		let startingMarker = Calendar.current.date(byAdding: .day, value: -historyMarker, to: today.start)!
		let recentItems = searchQualifiedItems.filter({ $0.dateLastPurchased >= startingMarker })
		let allOlderItems = searchQualifiedItems.filter({ $0.dateLastPurchased < startingMarker })
		
		// determine titles
		var section2Title = "Items Purchased Earlier: \(allOlderItems.count)"
		if !searchText.isEmpty {
			section2Title = "Items Purchased Earlier containing \"\(searchText)\": \(allOlderItems.count)"
		}
		
		// return two sections only
		return [SectionData(title: section1Title(searchText: searchText,
																						 historyMarker: historyMarker,
																						 count: recentItems.count),
												items: recentItems),
						SectionData(title: section2Title,
												items: allOlderItems)
		]
	}
	
	func section1Title(searchText: String, historyMarker: Int, count: Int) -> String {
		var title = "Items Purchased "
		if historyMarker == 0 {
			title += "Today "
		} else {
			title += "in the last \(historyMarker) days "
		}
		if !searchText.isEmpty {
			title += "containing \"\(searchText)\" "
		}
		title += "(\(count) items)"
		return title
	}
	
}
