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
	private var items: FetchedResults<Item>
	
		// the usual @State variables to handle the Search field and control
		// the action of the confirmation alert that you really do want to
		// delete an item
	@State private var searchText: String = ""
	
		// parameters to control triggering an Alert and defining what action
		// to take upon confirmation
		//@State private var confirmationAlert = ConfirmationAlert(type: .none)
	@State private var identifiableAlertItem: IdentifiableAlertItem?
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
		VStack(spacing: 0) {
			
			Rectangle()
				.frame(height: 1)
			
				// display either a "List is Empty" view, or the sectioned list of purchased items.
			if items.count == 0 {
				EmptyListView(listName: "Purchased")
			} else {
				ItemListView(items: items, sfSymbolName: "purchased",
										 identifiableAlertItem: $identifiableAlertItem, sectionData: sectionData)				
			} // end of if-else
			
			Divider() // keeps list from overrunning the tab bar in iOS 15
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
		.alert(item: $identifiableAlertItem) { item in item.alert() }
		.searchable(text: $searchText)
		
	}
	
	func handleOnAppear() {
		searchText = "" // clear searchText, get a clean screen
		today.update() // also recompute what "today" means, so the sectioning is correct
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
	
	
		// the idea of this function is to break out the purchased Items into
		// 2 sections: those purchased today (within the last N days), and everything else
	func sectionData() -> [ItemsSectionData] {
			// reduce items by search criteria
		let searchQualifiedItems = items.filter({ searchText.appearsIn($0.name) })
		
			// do we show one big section, or Today and then everything else?  one big section
			// is pretty darn easy:
		if !multiSectionDisplay {
			if searchText.isEmpty {
				return [ItemsSectionData(title: "Items Purchased: \(items.count)",
														items: items.map({ $0 }))]
			}
			return [ItemsSectionData(title: "Items Purchased containing: \"\(searchText)\": \(searchQualifiedItems.count)",
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
		return [
			ItemsSectionData(title: section1Title(searchText: searchText,
																			 historyMarker: historyMarker,
																			 count: recentItems.count),
									items: recentItems),
			ItemsSectionData(title: section2Title, items: allOlderItems)
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
