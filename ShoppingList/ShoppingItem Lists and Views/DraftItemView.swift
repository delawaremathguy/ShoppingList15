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

		// incoming data representing an about-to-be created Item, or an
		// existing Item.
	@ObservedObject var draftItem: DraftItem
		// a closure to call should the user try to delete the associated
		// Item (should be supplied only the draftItem represents a
		// real Item that already exists).  in usage, calling this action only initiates
		// a deletion sequence in which the user will be asked to confirm the deletion.
	var deleteActionInitiator: (() -> ())?
		// a simple way to tell whether we can delete this Item ... it's the same
		// as whether the caller gave us something to do to initiate a deletion.
		// we could also ask draftItem.representsExistingItem, but let's
		// keep it simple for the code below.
	private var itemExists: Bool {
		deleteActionInitiator != nil
	}
	
		// we need all locations so we can populate the Picker.
	var locations: [Location] { dataManager.locations }

//	@FetchRequest(fetchRequest: Location.allLocationsFR())
//	private var locations: FetchedResults<Location>
		
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
				
				if itemExists {
					HStack(alignment: .firstTextBaseline) {
						SLFormLabelText(labelText: "Last Purchased: ")
						Text("\(draftItem.dateText)")
					}
				}
				
			} // end of Section 1
			
				// Section 2. Item Management (Delete), if present
			if itemExists {
				Section(header: Text("Shopping Item Management").sectionHeader()) {
					SLCenteredButton(title: "Delete This Shopping Item") {
						deleteActionInitiator?()
					}
					.foregroundColor(Color.red)
				} // end of Section 2
			} // end of if ...
			
		} // end of Form
	}
}

