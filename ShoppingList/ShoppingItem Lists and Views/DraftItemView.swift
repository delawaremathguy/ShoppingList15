	//
	//  DraftItemView.swift
	//  ShoppingList
	//
	//  Created by Jerry on 12/8/21.
	//  Copyright © 2021 Jerry. All rights reserved.
	//

import SwiftUI

	// the DraftItemView is a simple Form that allows the user to edit the default fields
	// for a new Item, or the fields associated with an Item that already exists.
struct DraftItemView: View {
	
	@EnvironmentObject private var dataManager: DataManager
	@Environment(\.dismiss) var dismiss: DismissAction

		// incoming data representing an about-to-be created Item, or an
		// existing Item.
	@ObservedObject var draftItem: DraftItem
		// a closure to call should the user try to delete the associated
		// Item (should be supplied only the draftItem represents a
		// real Item that already exists).  in usage, calling this action only initiates
		// a deletion sequence in which the user will be asked to confirm the deletion.
	//var deleteActionInitiator: (() -> ())?
	private var associatedItem: Item? { dataManager.item(withID: draftItem.id) }
	
	@State private var isDeleteConfirmationPresented = false
	
		// we need all locations so we can populate the Picker.
	var locations: [Location] { dataManager.locations }

	var body: some View {
		Form {
				// Section 1. Basic Information Fields
			Section(header: Text("Basic Information").sectionHeader()) {
				
				HStack(alignment: .firstTextBaseline) {
					SLFormLabelText(labelText: "Name: ")
					TextField("Item name", text: $draftItem.name)
				}
				
				Stepper(value: $draftItem.quantity, in: 1...10) {
					HStack {
						SLFormLabelText(labelText: "Quantity: ")
						Text("\(draftItem.quantity)")
					}
				}
				
				Picker(selection: $draftItem.location, label: SLFormLabelText(labelText: "Location: ")) {
					ForEach(locations) { location in
						Text(location.name).tag(location)
					}
				}
				
				HStack(alignment: .firstTextBaseline) {
					Toggle(isOn: $draftItem.onList) {
						SLFormLabelText(labelText: "On Shopping List: ")
					}
				}
				
				HStack(alignment: .firstTextBaseline) {
					Toggle(isOn: $draftItem.isAvailable) {
						SLFormLabelText(labelText: "Is Available: ")
					}
				}
				
				if associatedItem != nil {
					HStack(alignment: .firstTextBaseline) {
						SLFormLabelText(labelText: "Last Purchased: ")
						Text("\(draftItem.dateText)")
					}
				}
				
			} // end of Section 1
			
				// Section 2. Item Management (Delete), if present
			if associatedItem != nil {
				Section(header: Text("Shopping Item Management").sectionHeader()) {
					SLCenteredButton(title: "Delete This Shopping Item") {
						isDeleteConfirmationPresented = true
//						deleteActionInitiator?()
					}
					.foregroundColor(Color.red)
				} // end of Section 2
			} // end of if ...
			
		} // end of Form
		.alert(alertTitle(), isPresented: $isDeleteConfirmationPresented) {
			Button("OK", role: .destructive) {
				dataManager.delete(item: associatedItem)
				dismiss()
			}
		} message: {
			Text(alertMessage())
		}

	}
	
	func alertTitle() -> String {
		"Delete \(draftItem.name)?"
	}
	
	func alertMessage() -> String {
		"Are you sure you want to delete the Location named \'\(draftItem.name)\'? All items at this location will be moved to the Unknown Location.  This action cannot be undone."
	}

}

