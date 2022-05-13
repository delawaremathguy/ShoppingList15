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
	private var dataManager: DataManager

	
		// draftLocation will be initialized from the incoming DraftLocation
	@StateObject private var draftLocation: DraftLocation
	var associatedLocation: Location? { dataManager.location(withID: draftLocation.id) }
	
		// alert trigger item to confirm deletion of a Location
//	@State private var confirmDeleteLocationAlert: ConfirmDeleteLocationAlert?
//	@StateObject private var alertModel = AlertModel()
	@State private var isDeleteConfirmationPresented = false

	init(location: Location, dataManager: DataManager) {
		self.dataManager = dataManager
		_draftLocation = StateObject(wrappedValue: dataManager.draftLocation(location: location))
	}
	
	var body: some View {

			// the trailing closure provides the DraftLocationView with what to do after the user has
			// opted to delete the location, namely "trigger an alert whose destructive action is to delete the
			// Location, and whose destructive completion is to dismiss this view,"
			// so we "go back" up the navigation stack
		DraftLocationView(draftLocation: draftLocation)
		//{
//			alertModel.updateAndPresent(for: .confirmDeleteLocation(draftLocation.associatedLocation, { dismiss() }),
//					 dataManager: dataManager)
//			isDeleteConfirmationPresented = true
//			confirmDeleteLocationAlert = ConfirmDeleteLocationAlert(
//				location: draftLocation.associatedLocation) {
//					dismiss()
//				}
//		}
			.navigationBarTitle(Text("Modify Location"), displayMode: .inline)
//			.alert(item: $confirmDeleteLocationAlert) { item in item.alert() }
//			.alert(alertModel.title, isPresented: $alertModel.isPresented, presenting: alertModel,
//						 actions: { model in model.actions() },
//						 message: { model in model.message })
		
			.alert(alertTitle(), isPresented: $isDeleteConfirmationPresented) {
				Button("OK", role: .destructive) {
					dataManager.delete(location: associatedLocation)
				}
			} message: { Text(alertMessage()) }

			.onDisappear {
					// we have been doing a pseudo-live edit for the associated  and we're leaving
					// the screen ... but one of the actions we may have performed is to delete the
					// Location ... and we would not want to do any updating with this draftLocation
					// if we deleted the underlying Location.
				if associatedLocation != nil {
					dataManager.updateAndSave(using: draftLocation)
				}
				dataManager.saveData()
			}
	}
	
	func alertTitle() -> String {
		return "Delete \(draftLocation.name)?"
	}
	
	func alertMessage() -> String {
		"Are you sure you want to delete the Location named \'\(draftLocation.name)\'? All items at this location will be moved to the Unknown Location.  This action cannot be undone."
	}

	
}

