//
//  ModifyLocationView.swift
//  ShoppingList
//
//  Created by Jerry on 5/7/20.
//  Copyright © 2020 Jerry. All rights reserved.
//

import SwiftUI

// MARK: - View Definition

struct AddOrModifyLocationView: View {
	@Environment(\.presentationMode) var presentationMode
	
	// all editableData is packaged here. its initial values are set using
	// a custom init.
	@State private var editableLocationData: EditableLocationData
	var location: Location?
	
	// parameter to control triggering an Alert and defining what action
	// to take upon confirmation
	@State private var confirmDeleteLocationAlert: ConfirmDeleteLocationAlert?
	// trigger for adding a new item at this Location
	@State private var isAddNewItemSheetShowing = false
	
	// custom init to set up editable data
	init(location: Location? = nil) {
//		print("AddorModifyLocationView initialized")
		_editableLocationData = State(initialValue: EditableLocationData(location: location))
		self.location = location
	}

	var body: some View {
		Form {
			// 1: Name, Visitation Order, Colors
			Section(header: Text("Basic Information").sectionHeader()) {
				HStack {
					SLFormLabelText(labelText: "Name: ")
					TextField("Location name", text: $editableLocationData.locationName)
				}
				
				if editableLocationData.visitationOrder != kUnknownLocationVisitationOrder {
					Stepper(value: $editableLocationData.visitationOrder, in: 1...100) {
						HStack {
							SLFormLabelText(labelText: "Visitation Order: ")
							Text("\(editableLocationData.visitationOrder)")
						}
					}
				}
				
				ColorPicker("Location Color", selection: $editableLocationData.color)
			} // end of Section 1
			
			// Section 2: Delete button, if present (must be editing a user location)
			if editableLocationData.representsExistingLocation && !editableLocationData.associatedLocation.isUnknownLocation {
				Section(header: Text("Location Management").sectionHeader()) {
					SLCenteredButton(title: "Delete This Location",
													 action: {
														confirmDeleteLocationAlert = ConfirmDeleteLocationAlert(
															location: editableLocationData.associatedLocation,
															destructiveCompletion: { presentationMode.wrappedValue.dismiss() })
//														confirmationAlert.trigger(type: .deleteLocation(editableData.associatedLocation),
//																											completion: { presentationMode.wrappedValue.dismiss() })
													 }
					).foregroundColor(Color.red)
				}
			} // end of Section 2
			
			// Section 3: Items assigned to this Location, if we are editing a Location
			if editableLocationData.representsExistingLocation {
				SimpleItemsList(location: editableLocationData.associatedLocation,
												isAddNewItemSheetShowing: $isAddNewItemSheetShowing)
			}
			
		} // end of Form
		.onDisappear { PersistentStore.shared.saveContext() }
		.navigationBarTitle(barTitle(), displayMode: .inline)
		.navigationBarBackButtonHidden(true)
		.toolbar {
			ToolbarItem(placement: .cancellationAction, content: cancelButton)
			ToolbarItem(placement: .confirmationAction) { saveButton().disabled(!editableLocationData.canBeSaved) }
		}
		.alert(item: $confirmDeleteLocationAlert) { item in item.alert() }
		.sheet(isPresented: $isAddNewItemSheetShowing) {
			NavigationView {
				AddNewItemView(location: location)
				//AddOrModifyItemView(location: location)
					.environment(\.managedObjectContext, PersistentStore.shared.context)
			}
		}

	}
	
	func barTitle() -> Text {
		return editableLocationData.representsExistingLocation ? Text("Modify Location") : Text("Add New Location")
	}
	
	func deleteAndDismiss(_ location: Location) {
		Location.delete(location)
		presentationMode.wrappedValue.dismiss()
	}

	// the cancel button
	func cancelButton() -> some View {
		Button(action: { presentationMode.wrappedValue.dismiss() }) {
			Text("Cancel")
		}
	}
	
	// the save button
	func saveButton() -> some View {
		Button(action: commitData) {
			Text("Save")
		}
	}

	func commitData() {
		presentationMode.wrappedValue.dismiss()
		Location.updateData(using: editableLocationData)
	}
	
}


struct SimpleItemsList: View {
	
	@FetchRequest	private var items: FetchedResults<Item>
	@State private var listDisplayID = UUID()
	@Binding var isAddNewItemSheetShowing: Bool
	
	init(location: Location, isAddNewItemSheetShowing: Binding<Bool>) {
		let request = Item.allItemsFR(at: location)
		_items = FetchRequest(fetchRequest: request)
		_isAddNewItemSheetShowing = isAddNewItemSheetShowing
	}
	
	var body: some View {
		Section(header: ItemsListHeader()) {
			ForEach(items) { item in
				NavigationLink(destination: ModifyExistingItemView(editableItem: item)) {
					Text(item.name)
				}
			}
		}
//		.id(listDisplayID)
		.onAppear { listDisplayID = UUID() }
	}
	
	func ItemsListHeader() -> some View {
		HStack {
			Text("At this Location: \(items.count) items").sectionHeader()
			Spacer()
			Button {
				isAddNewItemSheetShowing = true
			} label: {
				Image(systemName: "plus")
					.font(.title2)
			}
		}
	}
}
