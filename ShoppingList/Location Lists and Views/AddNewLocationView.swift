//
//  AddNewLocationView.swift
//  ShoppingList
//
//  Created by Jerry on 12/10/21.
//  Copyright © 2021 Jerry. All rights reserved.
//

import SwiftUI

struct AddNewLocationView: View {
	
	//@Environment(\.dismiss) var dismiss: DismissAction
	
	// incoming dismissal actions
	var dismiss: () -> Void

		// default editableLocationData is initialized here
	@State private var editableLocationData = EditableLocationData()
	
	var body: some View {
		EditableLocationDataView(editableLocationData: $editableLocationData)
			.navigationBarTitle(Text("Add New Location"), displayMode: .inline)
			.navigationBarBackButtonHidden(true)
			.toolbar {
				ToolbarItem(placement: .cancellationAction, content: cancelButton)
				ToolbarItem(placement: .confirmationAction) { saveButton().disabled(!editableLocationData.canBeSaved) }
			}
			.onDisappear { PersistentStore.shared.saveContext() }
	}
	
		// the cancel button
	func cancelButton() -> some View {
		Button { dismiss() } label: { Text("Cancel") }
	}
	
		// the save button
	func saveButton() -> some View {
		Button {
			dismiss()
			Location.updateData(using: editableLocationData)
		} label: {
			Text("Save")
		}
	}
	
}

