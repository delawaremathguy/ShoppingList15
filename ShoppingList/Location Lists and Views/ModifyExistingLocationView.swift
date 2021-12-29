	//
	//  ModifyExistingLocationView.swift
	//  ShoppingList
	//
	//  Created by Jerry on 12/11/21.
	//  Copyright © 2021 Jerry. All rights reserved.
	//

import SwiftUI

struct ModifyExistingLocationView: View {
	
	@Environment(\.dismiss) var dismiss: DismissAction
	
		// editableLocationData will be initialized from the incoming Location
	@State private var editableLocationData: EditableLocationData
	
		// alert trigger item to confirm deletion of a Location
	@State private var confirmDeleteLocationAlert: ConfirmDeleteLocationAlert?
		// if we really do go ahead and delete the Location, then we want the destructive action
		// (delete) to be remembered so that we don't try  to update the Location (that we just deleted)
		// on the way out of this view in .onDisappear
	@State private var locationWasDeleted: Bool = false
	
	init(location: Location) {
		_editableLocationData = State(initialValue: EditableLocationData(location: location))
	}
	
	var body: some View {

			// the trailing closure provides the EditableLocationDataView with what to do after the user has
			// opted to delete the location, namely "trigger an alert whose destructive action is to delete the
			// Location, and whose destructive completion is to dismiss this view,"
			// so we "go back" up the navigation stack
		EditableLocationDataView(editableLocationData: $editableLocationData) {
			confirmDeleteLocationAlert = ConfirmDeleteLocationAlert(
				location: editableLocationData.associatedLocation) {
					dismiss()
				}
		}
			.navigationBarTitle(Text("Modify Location"), displayMode: .inline)
			.alert(item: $confirmDeleteLocationAlert) { item in item.alert() }
			.onDisappear {
					// we were doing a pseudo-live edit, so update on the way out, unless
					// we chose above to delete the associated location
				if editableLocationData.representsExistingLocation {
					Location.updateAndSave(using: editableLocationData)
					PersistentStore.shared.saveContext()
				}
			}
	}
	
}

