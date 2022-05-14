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
	
		// incoming dismiss action.  the sheets in this app are all controlled with a
		// boolean $isXxxxxxxPresented, so the dismiss action will typically be to
		// set this variable to false.
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
			dataManager.updateAndSave(using: draftLocation)
			dismiss()
		} label: {
			Text("Save")
		}
	}
	
}

