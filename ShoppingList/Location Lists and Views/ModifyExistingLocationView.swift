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
	
		// location's viewModel will be initialized from the incoming Location
	@StateObject private var viewModel: LocationViewModel
	
//	@State private var isDeleteConfirmationPresented = false

		// custom init here to set up the LocationViewModel object.  in this case, must pass the
		// dataManager in directly (and not rely on it being in the environment) because
		// we're inside the init() that runs first before everything else is available.
	private var dataManager: DataManager
	init(locationStruct: LocationStruct, dataManager: DataManager) {
		self.dataManager = dataManager
		_viewModel = StateObject(wrappedValue: dataManager.locationViewModel(locationStruct: locationStruct))
	}
	
	var body: some View {
		LocationEditView(viewModel: viewModel)
			.navigationBarTitle(Text("Modify Location"), displayMode: .inline)
//			.alert(alertTitle(), isPresented: $isDeleteConfirmationPresented) {
//				Button("OK", role: .destructive) {
//					viewModel.deleteLocation()
//					dismiss()
//				}
//			} message: { Text(alertMessage()) }
//			.onDisappear {
//				viewModel.updateAndSave()
//			}
	}
	
//	func alertTitle() -> String {
//		return "Delete \(viewModel.draft.name)?"
//	}
//	
//	func alertMessage() -> String {
//		"Are you sure you want to delete the Location named \'\(viewModel.draft.name)\'? All items at this location will be moved to the Unknown Location.  This action cannot be undone."
//	}

	
}

