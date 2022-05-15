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
	
		// draftLocation will be initialized from the incoming Location
	@StateObject private var draftLocation: DraftLocation
		// a way to locate the Location associated with the draftLocation in real time.
	var associatedLocation: Location? { dataManager.location(associatedWith: draftLocation) }
	
	@State private var isDeleteConfirmationPresented = false

		// custom init here to set up the DraftLocation object.  in this case, must pass the
		// dataManager in directly (and not rely on it being in the environment) because
		// we're inside the init() that runs first before everything else is available.
	private var dataManager: DataManager
	init(location: Location, dataManager: DataManager) {
		self.dataManager = dataManager
		_draftLocation = StateObject(wrappedValue: dataManager.draftLocation(location: location))
	}
	
	var body: some View {
		DraftLocationView(draftLocation: draftLocation)
			.navigationBarTitle(Text("Modify Location"), displayMode: .inline)
			.alert(alertTitle(), isPresented: $isDeleteConfirmationPresented) {
				Button("OK", role: .destructive) {
					dataManager.delete(location: associatedLocation)
				}
			} message: { Text(alertMessage()) }
			.onDisappear {
					// a way to locate the Location associated with the draftLocation in real time.
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

