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
	
	@EnvironmentObject private var dataManager: DataManager
	var items: [Item] { dataManager.itemsOffList }

	
		// this is the @FetchRequest that ties this view to CoreData
//	@FetchRequest(fetchRequest: Item.allItemsFR(onList: false))
//	private var items: FetchedResults<Item>
	
		// the usual @State variables to handle the Search field
	@State private var searchText: String = ""
	
		// trigger for any alert we will put up
	@State private var identifiableAlertItem: IdentifiableAlertItem?

		// trigger for sheet used to add a new shopping item
	@State private var identifiableSheetItem: IdentifiableSheetItem?

		// whether are we a multi-section display or not.
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
				ItemListView(sections: sectionData(), //items: items,
										 sfSymbolName: "cart",
										 identifiableAlertItem: $identifiableAlertItem,
										 multiSectionDisplay: $multiSectionDisplay)
			} // end of if-else
			
			Divider() // keeps list from overrunning the tab bar in iOS 15
		} // end of VStack
		.searchable(text: $searchText)

		.onAppear {
			logAppear(title: "PurchasedTabView")
			handleOnAppear()
		}
		.onDisappear() {
			logDisappear(title: "PurchasedTabView")
			dataManager.saveData()
		}
		.navigationBarTitle("Purchased List")
		.toolbar {
			ToolbarItem(placement: .navigationBarTrailing, content: addNewButton)
		}
		.alert(item: $identifiableAlertItem) { item in item.alert() }
		.sheet(item: $identifiableSheetItem) { item in item.content() }
		
	}
	
	func handleOnAppear() {
		searchText = "" // clear searchText, get a clean screen
		today.update() // also recompute what "today" means, so the sectioning is correct
	}
	
		// makes a simple "+" to add a new item.  yapping on the button triggers a sheet to add a new item.
	func addNewButton() -> some View {
		NavBarImageButton("plus") {
			identifiableSheetItem = AddNewItemSheetItem(dataManager: dataManager) { identifiableSheetItem = nil }
		}
	}
	
		// the idea of this function is to break out the purchased Items into sections, and can produce either one section
		// for everything, or else two sections if multiSectionDisplay == true with:
		// -- those items purchased within the last N days,
		// -- and everything else
	func sectionData() -> [ItemsSectionData] {
			// reduce items by search criteria
		let searchQualifiedItems = items.filter({ searchText.appearsIn($0.name) })
		
			// do we show one big section or two (recent + everything else)?  one big section is pretty darn easy:
		if !multiSectionDisplay {
			if searchText.isEmpty {
				return [ItemsSectionData(index: 1, title: "Items Purchased: \(items.count)",
														items: items.map({ $0 }))]
			}
			return [ItemsSectionData(index: 1, title: "Items Purchased containing: \"\(searchText)\": \(searchQualifiedItems.count)",
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
			ItemsSectionData(index: 1,
											 title: section1Title(searchText: searchText, count: recentItems.count),
											 items: recentItems),
			ItemsSectionData(index: 2,
											 title: section2Title,
											 items: allOlderItems)
		]
	}
	
	func section1Title(searchText: String, count: Int) -> String {
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
