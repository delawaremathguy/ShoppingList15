//
//  AddorModifyItemView.swift
//  ShoppingList
//
//  Created by Jerry on 5/3/20.
//  Copyright © 2020 Jerry. All rights reserved.
//

import SwiftUI

struct AddOrModifyItemView: View {
	// we use this so we can dismiss ourself (sometimes we're in a Sheet, sometimes
	// in a NavigationLink)
	@Environment(\.presentationMode) var presentationMode

	// addItemToShoppingList just means that by default, a new item will be added to
	// the shopping list, and so this is initialized to true.
	// however, if inserting a new item from the Purchased item list, perhaps
	// you might want the new item to go to the Purchased item list (?)
	var addItemToShoppingList: Bool = true
	
	// this editableData struct contains all of the fields of an Item that
	// can be edited here, so that we're not doing a "live edit" on the Item.
	@State private var editableData: EditableItemData

	// parameters to control triggering an Alert and defining what action
	// to take upon confirmation
	//@State private var confirmationAlert = ConfirmationAlert(type: .none)
	@State private var confirmDeleteItemAlert: ConfirmDeleteItemAlert?
	
	// we need all locations so we can populate the Picker.  it may be curious that i
	// use a @FetchRequest here; the problem is that if this Add/ModifyItem view is open
	// to add a new item, then we tab over to the Locations tab to add a new location,
	// we have to be sure the Picker's list of locations is updated.
	@FetchRequest(fetchRequest: Location.allLocationsFR())
	private var locations: FetchedResults<Location>
	
	// custom init here to set up editableData state
	init(editableItem: Item? = nil, initialItemName: String? = nil, location: Location? = nil) {
		// initialize the editableData struct for the incoming item, if any; and
		// also carry in whatever might be a suggested Item name for a new Item
		if let item = editableItem {
			_editableData = State(initialValue: EditableItemData(item: item))
		} else {
			// here's we'll see if a suggested name for adding a new item was supplied
			let initialValue = EditableItemData(initialItemName: initialItemName, location: location)
			_editableData = State(initialValue: initialValue)
		}
	}
	
	var body: some View {
		Form {
			// Section 1. Basic Information Fields
			Section(header: Text("Basic Information").sectionHeader()) {
				
				HStack(alignment: .firstTextBaseline) {
					SLFormLabelText(labelText: "Name: ")
					TextField("Item name", text: $editableData.name)
				}
				
				Stepper(value: $editableData.quantity, in: 1...10) {
					HStack {
						SLFormLabelText(labelText: "Quantity: ")
						Text("\(editableData.quantity)")
					}
				}
				
				Picker(selection: $editableData.location, label: SLFormLabelText(labelText: "Location: ")) {
					ForEach(locations) { location in
						Text(location.name).tag(location)
					}
				}
				
				HStack(alignment: .firstTextBaseline) {
					Toggle(isOn: $editableData.onList) {
						SLFormLabelText(labelText: "On Shopping List: ")
					}
				}
				
				HStack(alignment: .firstTextBaseline) {
					Toggle(isOn: $editableData.isAvailable) {
						SLFormLabelText(labelText: "Is Available: ")
					}
				}
				
				if !editableData.dateText.isEmpty {
					HStack(alignment: .firstTextBaseline) {
						SLFormLabelText(labelText: "Last Purchased: ")
						Text("\(editableData.dateText)")
					}
				}

			} // end of Section 1
			
			// Section 2. Item Management (Delete), if present
			if editableData.representsExistingItem {
				Section(header: Text("Shopping Item Management").sectionHeader()) {
					SLCenteredButton(title: "Delete This Shopping Item",
													 action: {
														confirmDeleteItemAlert =
															ConfirmDeleteItemAlert(item: editableData.associatedItem,
																										 destructiveCompletion: { presentationMode.wrappedValue.dismiss() })
//														confirmationAlert.trigger( type: .deleteItem(editableData.associatedItem),
//																											 completion: { presentationMode.wrappedValue.dismiss() })
													 }
					)
						.foregroundColor(Color.red)
				} // end of Section 2
			} // end of if ...
			
		} // end of Form
		.navigationBarTitle(barTitle(), displayMode: .inline)
		.navigationBarBackButtonHidden(true)
		.toolbar {
			ToolbarItem(placement: .cancellationAction) { cancelButton() }
			ToolbarItem(placement: .confirmationAction) { saveButton().disabled(!editableData.canBeSaved) }
		}
		.onAppear {
			logAppear(title: "AddOrModifyItemView")
			handleOnAppear()
		}
		.onDisappear {
			logDisappear(title: "AddOrModifyItemView")
			PersistentStore.shared.saveContext()
		}
		//.alert(isPresented: $confirmationAlert.isShowing) { confirmationAlert.alert() }
		.alert(item: $confirmDeleteItemAlert) { item in item.alert() }
	}
		
	func barTitle() -> Text {
		return editableData.representsExistingItem ? Text("Modify Item") : Text("Add New Item")
	}
	
	func handleOnAppear() {
		// what follows here is a kludge for a very special case:
		// -- we were in the ShoppingListTabView
		// -- we navigate to this Add/ModifyItem view for an Item X at Location Y
		// -- we use the tab bar to move to the Locations tab
		// -- we select Location Y and navigate to its Add/ModifyLocation view
		// -- we tap Item X listed for Location Y, opening a second Add/ModifyItem view for Item X
		// -- we delete Item X in this second Add/ModifyItem view
		// -- we use the tab bar to come back to the shopping list tab, and
		// -- this view is now what's on-screen, showing us an item that was deleted underneath us (!)
		//
		// the only thing that makes sense is to dismiss ourself in the case that we were instantiated
		// with a real item (editableData.id != nil) but that item does not exist anymore.
		
		if editableData.representsExistingItem && Item.object(withID: editableData.id!) == nil {
			presentationMode.wrappedValue.dismiss()
		}
		
		// by the way, this applies symmetrically to opening an Add/ModifyItem view from the
		// Add/ModifyLocation view, then tabbing over to the shopping list, looking at a second
		// Add/ModifyItem view there and deleting.  the first Add/ModifyItem view will get the
		// same treatment in this code, getting dismissed when it tries to come back on screen.
		
		// ADDITIONAL DISCUSSION:
		//
		// apart from the delete operation, when two instances of the Add/ModifyItem view are
		// active, any edits made to item data in one will not be replicated in the other, because
		// these views copy data to their local @State variable editableData, and that is what
		// gets edited.  so if you do a partial edit in one of the views, when you visit the second
		// view, you will not see those changes.  this is a natural side-effect of doing an edit
		// on a draft copy of the data and not doing a live edit.  we are aware of the problem
		// and may look to fix this in the future.  (two strategies come to mind: a live edit of an
		// ObservableObject, which then means we have to rethink combining the add and modify
		// functions; or always doing the Add/Modify view as a .sheet so that you cannot so easily
		// navigate elsewhere in the app and make edits underneath this view.)
		
		// a third possibility offered by user jjatie on 7 Jan, 2021, on the Apple Developer's Forum
		//   https://developer.apple.com/forums/thread/670564
		// suggests tapping into the NotificationCenter to watch for changes in the NSManaged
		// context, and checking to see if the Item is among those in the notification's
		// userInfo[NSManagedObjectContext.NotificationKey.deletedObjectIDs].

	}
	
	// the cancel button
	func cancelButton() -> some View {
		Button("Cancel",
					 action: { presentationMode.wrappedValue.dismiss() })
	}
	
	// the save button
	func saveButton() -> some View {
		Button("Save",
					 action: commitDataEntry)
	}
	
	// called when you tap the Save button.
	func commitDataEntry() {
		guard editableData.canBeSaved else { return }
		Item.update(using: editableData)
		presentationMode.wrappedValue.dismiss()
	}
	
}

