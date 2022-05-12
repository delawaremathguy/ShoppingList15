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
	
	private var dataManager: DataManager
	
	// incoming dismiss action.  we're a View presented as a sheet via an
	// identifiableSheetItem, so the presenter needs to tell us how it will dismiss us
	var dismiss: () -> Void
		// default draftLocation is initialized here
	@StateObject private var draftLocation: DraftLocation
	
	init(dataManager: DataManager, dismiss: @escaping () -> Void) {
		self.dataManager = dataManager
		self.dismiss = dismiss
		_draftLocation = StateObject(wrappedValue: dataManager.draftLocation())
	}
	
	var body: some View {
		NavigationView {
			DraftLocationView(draftLocation: draftLocation)
				.navigationBarTitle(Text("Add New Location"), displayMode: .inline)
				.navigationBarBackButtonHidden(true)
				.toolbar {
					ToolbarItem(placement: .cancellationAction, content: cancelButton)
					ToolbarItem(placement: .confirmationAction) { saveButton().disabled(!draftLocation.canBeSaved) }
				}
				.onDisappear { dataManager.saveData() }
		}
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
			dataManager.updateAndSave(using: draftLocation)
		} label: {
			Text("Save")
		}
	}
	
}

