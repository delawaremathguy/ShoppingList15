//
//  ShoppingListBottomButtons.swift
//  ShoppingList
//
//  Created by Jerry on 7/12/22.
//  Copyright © 2022 Jerry. All rights reserved.
//

import SwiftUI

struct ShoppingListBottomButtons: View {
	
	@EnvironmentObject private var dataManager: DataManager
	
		// incoming list of items to be purchased
	var itemsToBePurchased: [ItemStruct]
		// determines whether to show the "Mark All Available" button
	var showMarkAllAvailable: Bool { !itemsToBePurchased.allSatisfy({ $0.isAvailable }) }
		// trigger for alert to confirm you want to move all items off the shopping list
	@State private var isConfirmMoveAllPresented = false
	
	var body: some View {
		
		HStack {
			Spacer()
			
			Button {
				isConfirmMoveAllPresented = true
					//moveAllItemsOffShoppingList()
			} label: {
				Text("Move All Off List")
			}
			
			if showMarkAllAvailable {
				Spacer()
				
				Button {
					dataManager.markAsAvailable(items: itemsToBePurchased)
				} label: {
					Text("Mark All Available")
				}
			}
			
			Spacer()
		}
		.padding(.vertical, 6)
		.animation(.easeInOut(duration: 0.4), value: showMarkAllAvailable)
		.alert("Move All Items Off-List", isPresented: $isConfirmMoveAllPresented) {
			Button("Yes", role: .destructive) {
				dataManager.moveAllItemsOffShoppingList()
			}
		}
		
	}
	
} // end of ShoppingListBottomButtons
