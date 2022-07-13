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
	
		// locationViewModel will be initialized from the incoming Location
	@StateObject private var locationViewModel: LocationViewModel
		// a way to locate the Location associated with the locationViewModel in real time.
	var associatedLocation: Location? { dataManager.location(associatedWith: locationViewModel) }
	
	@State private var isDeleteConfirmationPresented = false

		// custom init here to set up the LocationViewModel object.  in this case, must pass the
		// dataManager in directly (and not rely on it being in the environment) because
		// we're inside the init() that runs first before everything else is available.
	private var dataManager: DataManager
	init(location: Location, dataManager: DataManager) {
		self.dataManager = dataManager
		_locationViewModel = StateObject(wrappedValue: dataManager.locationViewModel(location: location))
	}
	
	var body: some View {
		LocationEditView(viewModel: locationViewModel)
			.navigationBarTitle(Text("Modify Location"), displayMode: .inline)
			.alert(alertTitle(), isPresented: $isDeleteConfirmationPresented) {
				Button("OK", role: .destructive) {
					dataManager.delete(location: associatedLocation)
				}
			} message: { Text(alertMessage()) }
			.onDisappear {
					// a way to locate the Location associated with the locationViewModel in real time.
				if associatedLocation != nil {
					dataManager.updateAndSave(using: locationViewModel)
				}
				dataManager.saveData()
			}
	}
	
	func alertTitle() -> String {
		return "Delete \(locationViewModel.name)?"
	}
	
	func alertMessage() -> String {
		"Are you sure you want to delete the Location named \'\(locationViewModel.name)\'? All items at this location will be moved to the Unknown Location.  This action cannot be undone."
	}

	
}

