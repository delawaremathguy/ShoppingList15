//
//  ShoppingListView.swift
//  ShoppingList
//
//  Created by Jerry on 4/22/20.
//  Copyright © 2020 Jerry. All rights reserved.
//

import SwiftUI

struct ShoppingListView: View {
		
	// this is the @FetchRequest that ties this view to CoreData Items
	@FetchRequest(fetchRequest: Item.allItemsFR(onList: true))
	private var itemsToBePurchased: FetchedResults<Item>

	// local state to trigger showing a sheet to add a new item
	@State private var isAddNewItemSheetShowing = false
	
	// alert to move all item off the shopping list
	@State private var confirmMoveAllItemsOffShoppingListAlert: ConfirmMoveAllItemsOffShoppingListAlert?
	
	// local state for are we a multi-section display or not.  the default here is false,
	// but an eager developer could easily store this default value in UserDefaults (?)
	@State var multiSectionDisplay: Bool = false
	
	// support for Mail
	@State private var showMailSheet: Bool = false
	var mailViewData = MailViewData()
	
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

				ZStack {
					EmptyListView(listName: "Shopping")
						.opacity(itemsToBePurchased.count == 0 ? 1 : 0)
						.zIndex(-1)

					ShoppingListDisplay(itemsToBePurchased: itemsToBePurchased,
															multiSectionDisplay: $multiSectionDisplay)
						.opacity(itemsToBePurchased.count == 0 ? 0 : 1)
				} // end of ZStack
				
/* ---------
and for non-empty lists, we have a few buttons at the end for bulk operations
---------- */

				if itemsToBePurchased.count > 0 {
					Divider()
					
					ShoppingListBottomButtons(itemsToBePurchased: itemsToBePurchased) {
						confirmMoveAllItemsOffShoppingListAlert = ConfirmMoveAllItemsOffShoppingListAlert()
					}
				} //end of if itemsToBePurchased.count > 0

				Divider()

			} // end of VStack
			.navigationBarTitle("Shopping List")
			.toolbar {
				ToolbarItem(placement: .navigationBarLeading, content: sectionDisplayButton)
				ToolbarItem(placement: .navigationBarTrailing, content: trailingButtons)
			}
		.sheet(isPresented: self.$showMailSheet) {
			MailView(isShowing: $showMailSheet, mailViewData: mailViewData, resultHandler: mailResultHandler)
				.safe()
		}
		.alert(item: $confirmMoveAllItemsOffShoppingListAlert) { item in item.alert() }

		.onAppear {
			logAppear(title: "ShoppingListView")
		}
		.onDisappear {
			logDisappear(title: "ShoppingListView")
			PersistentStore.shared.saveContext()
		}
		
	} // end of body: some View
	
	// MARK: - ToolbarItems
	
	// a "+" symbol to support adding a new item
	func addNewButton() -> some View {
		Button(action: { isAddNewItemSheetShowing = true })
			{ Image(systemName: "plus")
			.font(.title2)
		}
	}
	
	func trailingButtons() -> some View {
		HStack(spacing: 12) {
			Button() {
				prepareDataForMail()
				self.showMailSheet = true
			} label: {
				Image(systemName: "envelope")
					.font(.title2)
			}
			.disabled(!MailView.canSendMail)
			
			Button(action: { isAddNewItemSheetShowing = true })
				{ Image(systemName: "plus")
				.font(.title2)
			}
		}
	}
	
	// a toggle button to change section display mechanisms
	func sectionDisplayButton() -> some View {
		Button() {
			multiSectionDisplay.toggle()
		} label: {
			Image(systemName: multiSectionDisplay ? "tray.2" : "tray")
				.font(.title2)
		}
	}
	
	//MARK: - Mail support
	
	func prepareDataForMail() {
		// start with a clean, default set of parameters to pass to the MailView
		mailViewData.clear()
		
		// put together a simple mail message
		var messageString = "Items on your Shopping List: \n"
		
		// pull out Locations appearing in the shopping list as a dictionary, keyed by location
		// and write the mail message = one big string
		let dictionary = Dictionary(grouping: itemsToBePurchased, by: { $0.location })
		for key in dictionary.keys.sorted() {
			let items = dictionary[key]!
			messageString += "\n\(key.name), \(items.count) item(s)\n\n"
			for item in items {
				messageString += "  \(item.name)\n"
			}
		}
		
		mailViewData.subject = "Shopping List"
		mailViewData.messageBody = messageString
		self.showMailSheet = true
	}
	
	func mailResultHandler(value: Result<MailViewResult, Error>) {
		switch value {
			case .success(let result):
				switch result {
					case .cancelled:
						print("cancelled")
					case .failed:
						print("failed")
					case .saved:
						print("saved")
					default:
						print("sent")
				}
			case .failure(let error):
				NSLog("error: \(error.localizedDescription)")
		}
	}

	
} // end of ShoppingListView


struct ShoppingListBottomButtons: View {
	
		// incoming list of items to be purchased
	var itemsToBePurchased: FetchedResults<Item>
		// incoming function: what to do when the user wants to move all items of the shopping list
	var moveAllItemsOffShoppingList: () -> ()
	
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
