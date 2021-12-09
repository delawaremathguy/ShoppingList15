	//
	//  ModifyExistingItemView.swift
	//  ShoppingList
	//
	//  Created by Jerry on 12/8/21.
	//  Copyright © 2021 Jerry. All rights reserved.
	//

import SwiftUI

struct ModifyExistingItemView: View {
	
		// addItemToShoppingList just means that by default, a new item will be added to
		// the shopping list, and so this is initialized to true.
		// however, if inserting a new item from the Purchased item list, perhaps
		// you might want the new item to go to the Purchased item list (?)
	var addItemToShoppingList: Bool = true
	
	@ObservedObject var editableItem: Item
	
		// custom init here to set up editableData state
	init(editableItem: Item) {
		self.editableItem = editableItem
	}
	
	var body: some View {
		
		EditableItemView(editableItem: editableItem, itemExists: true)
			.navigationBarTitle(Text("Modify Item"), displayMode: .inline)
			.onDisappear {
				PersistentStore.shared.saveContext()
			}
			//.alert(isPresented: $confirmationAlert.isShowing) { confirmationAlert.alert() }
			//.alert(item: $confirmDeleteItemAlert) { item in item.alert() }
	}
	
	

}

