	//
	//  LocationEditView.swift
	//  ShoppingList
	//
	//  Created by Jerry on 12/10/21.
	//  Copyright © 2021 Jerry. All rights reserved.
	//

import SwiftUI

	// the LocationViewModelView is a simple Form that allows the user to edit
	// the default fields for a new Location, or the fields associated with a Location
	// that already exists.
struct LocationEditView: View {
	
		// incoming data: some environment plus the viewModel to drive this view
	@Environment(\.dismiss) var dismiss
	@EnvironmentObject private var dataManager: DataManager
	@ObservedObject var viewModel: LocationViewModel

		// control for confirmation alert
	@State private var isDeleteConfirmationPresented = false
	
		// trigger for adding a new item at this Location
	@State private var isAddNewItemSheetShowing = false
	
		// items at this location, to form list to get to editing those items.
	var itemsAtThisLocation: [ItemStruct] {
		dataManager.itemStructs.filter({ $0.locationID == viewModel.draft.id })
	}

	var body: some View {
		Form {
				// 1: Name, Visitation Order, Colors.  These are shown for both an existing
				// location and a potential new Location about to be created.
			Section(header: Text("Basic Information").sectionHeader()) {
				HStack {
					SLFormLabelText(labelText: "Name: ")
					TextField("Location name", text: $viewModel.draft.name)
				}
				
				if viewModel.draft.visitationOrder != kUnknownLocationVisitationOrder {
					Stepper(value: $viewModel.draft.visitationOrder, in: 1...100) {
						HStack {
							SLFormLabelText(labelText: "Visitation Order: ")
							Text("\(viewModel.draft.visitationOrder)")
						}
					}
				}
				
				ColorPicker("Location Color", selection: $viewModel.draft.color)
			} // end of Section 1
			
				// Section 2: Delete button, if we are editing a real Location
			if viewModel.draft.isExistingLocation && !viewModel.draft.isUnknownLocation {
				Section(header: Text("Location Management").sectionHeader()) {
					SLCenteredButton(title: "Delete This Location")  {
						isDeleteConfirmationPresented = true
					}
					.foregroundColor(Color.red)
				} // end of Section
			} // end of if

			if viewModel.draft.isExistingLocation  && itemsAtThisLocation.count > 0 {
				Section(header: ItemsListHeader(count: itemsAtThisLocation.count)) {
					SimpleItemsList(itemStructs: itemsAtThisLocation,
													isAddNewItemSheetShowing: $isAddNewItemSheetShowing)
				}
			}

		} // end of Form
			// note to self on this .sheet: it can only be triggered if the locationViewModel
			// is associated with a real Location
		.sheet(isPresented: $isAddNewItemSheetShowing) {
			AddNewItemView(dataManager: dataManager, locationViewModel: viewModel) {
				isAddNewItemSheetShowing = false
			}
		}
		
			// note to self on this .alert: it can only be triggered if the locationViewModel
			// is associated with a real Location
		.alert("Delete \(viewModel.draft.name)?", isPresented: $isDeleteConfirmationPresented) {
			Button("OK", role: .destructive) {
				dataManager.delete(location: dataManager.location(associatedWith: viewModel)!)
			}
		} message: {
			Text("Are you sure you want to delete the Location named \'\(viewModel.draft.name)\'? All items at this location will be moved to the Unknown Location.  This action cannot be undone.")
		}

	} // end of var body: some View
	
	func ItemsListHeader(count: Int) -> some View {
		HStack {
			Text("At this Location: \(count) items").sectionHeader()
			Spacer()
			SystemImageButton("plus") {
				isAddNewItemSheetShowing = true
			}
		}
	}

}

struct SimpleItemsList: View {
	
	@EnvironmentObject private var dataManager: DataManager
	var itemStructs: [ItemStruct]
		// our hook back to the parent view (the LocationViewModelView) to add a new
		// Item at this Location.
	@Binding var isAddNewItemSheetShowing: Bool
	
	var body: some View {
		ForEach(itemStructs) { itemStruct in
			NavigationLink {
				ModifyExistingItemView(itemStruct: itemStruct, dataManager: dataManager)
			} label: {
				Text(itemStruct.name)
			}
		}
	}
	
}
