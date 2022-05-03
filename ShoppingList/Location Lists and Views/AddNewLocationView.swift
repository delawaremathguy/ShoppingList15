//
//  AddNewLocationView.swift
//  ShoppingList
//
//  Created by Jerry on 12/10/21.
//  Copyright © 2021 Jerry. All rights reserved.
//

import SwiftUI

// see AddNewItemView.swift for similar comments and explanation of how this works
struct AddNewLocationView: View {
	
	// incoming dismiss action.  we're a View presented as a sheet via an
	// identifiableSheetItem, so the presenter needs to tell us how it will dismiss us
	var dismiss: () -> Void
		// default draftLocation is initialized here
	@StateObject private var draftLocation = DraftLocation()
	
	var body: some View {
		DraftLocationView(draftLocation: draftLocation)
			.navigationBarTitle(Text("Add New Location"), displayMode: .inline)
			.navigationBarBackButtonHidden(true)
			.toolbar {
				ToolbarItem(placement: .cancellationAction, content: cancelButton)
				ToolbarItem(placement: .confirmationAction) { saveButton().disabled(!draftLocation.canBeSaved) }
			}
			.onDisappear { PersistentStore.shared.saveContext() }
	}
	
		// the cancel button
	func cancelButton() -> some View {
		Button {
			dismiss()
		} label: {
			Text("Cancel")
		}
	}
	
		// the save button
	func saveButton() -> some View {
		Button {
			dismiss()
			Location.updateAndSave(using: draftLocation)
		} label: {
			Text("Save")
		}
	}
	
}

