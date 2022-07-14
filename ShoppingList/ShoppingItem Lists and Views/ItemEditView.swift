	//
	//  ItemEditView.swift
	//  ShoppingList
	//
	//  Created by Jerry on 12/8/21.
	//  Copyright © 2021 Jerry. All rights reserved.
	//

import SwiftUI

	// the ItemEditView is a simple Form that allows the user to edit the fields
	// for either a new Item, or those associated with an Item that already exists.
	// its view model holds a "draft" that is used during the editing; that draft can
	// then be used to update the original Item that underlies the data when either
	// tapping the save button (if presented in an "add new" operation, or by
	// navigating back (this is essentially a live edit) in a "modify" operation.
struct ItemEditView: View {
	
		// usual environment values
	@EnvironmentObject private var dataManager: DataManager
	@Environment(\.dismiss) var dismiss: DismissAction

		// we use a view model to drive the data in the view, as passed in from
		// the parent view.  we're editing the values in that view model.
	@ObservedObject var viewModel: ItemViewModel

		// needed to support showing a delete confirmation
	@State private var isDeleteConfirmationPresented = false
	
		// we need all locations so we can populate the Picker.
	var locationStructs: [LocationStruct] { dataManager.locationStructs }

	var body: some View {
		Form {
			
				// Section 1. Basic Information Fields
			Section(header: Text("Basic Information").sectionHeader()) {
				
				HStack(alignment: .firstTextBaseline) {
					SLFormLabelText(labelText: "Name: ")
					TextField("Item name", text: $viewModel.draft.name)
				}
				
				Stepper(value: $viewModel.draft.quantity, in: 1...10) {
					HStack {
						SLFormLabelText(labelText: "Quantity: ")
						Text("\(viewModel.draft.quantity)")
					}
				}
				
				Picker(selection: $viewModel.draft.locationID,
							 label: SLFormLabelText(labelText: "Location: ")) {
					ForEach(locationStructs) { locationStruct in
						Text(locationStruct.name).tag(locationStruct.id)
					}
				}
				
				HStack(alignment: .firstTextBaseline) {
					Toggle(isOn: $viewModel.draft.onList) {
						SLFormLabelText(labelText: "On Shopping List: ")
					}
				}
				
				HStack(alignment: .firstTextBaseline) {
					Toggle(isOn: $viewModel.draft.isAvailable) {
						SLFormLabelText(labelText: "Is Available: ")
					}
				}
				
				if viewModel.associatedItem != nil {
					HStack(alignment: .firstTextBaseline) {
						SLFormLabelText(labelText: "Last Purchased: ")
						Text("\(viewModel.dateText)")
					}
				}
				
			} // end of Section 1
			
				// Section 2. Item Management (Delete), if present
			if viewModel.associatedItem != nil {
				Section(header: Text("Shopping Item Management").sectionHeader()) {
					SLCenteredButton(title: "Delete This Shopping Item") {
						isDeleteConfirmationPresented = true
					}
					.foregroundColor(Color.red)
				} // end of Section 2
			} // end of if ...
			
		} // end of Form
		.alert(alertTitle(), isPresented: $isDeleteConfirmationPresented) {
			Button("OK", role: .destructive) {
				viewModel.deleteItem()
				dismiss()
			}
		} message: {
			Text(alertMessage())
		}

	}
	
	func alertTitle() -> String {
		"Delete \(viewModel.draft.name)?"
	}
	
	func alertMessage() -> String {
		"Are you sure you want to delete the Location named \'\(viewModel.draft.name)\'? All items at this location will be moved to the Unknown Location.  This action cannot be undone."
	}

}

