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
	
		// draftLocation will be initialized from the incoming DraftLocation
	@StateObject private var draftLocation: DraftLocation
	
		// alert trigger item to confirm deletion of a Location
//	@State private var confirmDeleteLocationAlert: ConfirmDeleteLocationAlert?
	@StateObject private var alertModel = AlertModel()

	init(location: Location) {
		_draftLocation = StateObject(wrappedValue: DraftLocation(location: location))
	}
	
	var body: some View {

			// the trailing closure provides the DraftLocationView with what to do after the user has
			// opted to delete the location, namely "trigger an alert whose destructive action is to delete the
			// Location, and whose destructive completion is to dismiss this view,"
			// so we "go back" up the navigation stack
		DraftLocationView(draftLocation: draftLocation) {
			alertModel.updateAndTrigger(for: .confirmDeleteLocation(draftLocation.associatedLocation, { dismiss() }))
//			confirmDeleteLocationAlert = ConfirmDeleteLocationAlert(
//				location: draftLocation.associatedLocation) {
//					dismiss()
//				}
		}
			.navigationBarTitle(Text("Modify Location"), displayMode: .inline)
//			.alert(item: $confirmDeleteLocationAlert) { item in item.alert() }
			.alert(alertModel.title, isPresented: $alertModel.isPresented, presenting: alertModel,
						 actions: { model in model.actions() },
						 message: { model in model.message })

			.onDisappear {
					// we have been doing a pseudo-live edit, so update the associated location of
					// the draftLocation when finished with this view (i.e., when dismissed).
					// note that if
				if draftLocation.representsExistingLocation {
					Location.updateAndSave(using: draftLocation)
					PersistentStore.shared.saveContext()
				}
			}
	}
	
}

