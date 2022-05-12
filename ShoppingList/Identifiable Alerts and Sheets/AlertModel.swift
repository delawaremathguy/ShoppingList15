//
//  AlertModel.swift
//  ShoppingList
//
//  Created by Jerry on 5/4/22.
//  Copyright © 2022 Jerry. All rights reserved.
//

import SwiftUI

/*
 this file contains an idea that I am pre-flighting, to replace all the deprecated
 .alert(item: ...) modifiers scattered throughout the code by the newer
 .alert( : isPresented: presenting: actions: message:) syntax.
 
 i'll only be testing this idea in the LocationsView and the ModifyExistingLocationView
 for now (where you will see commented out code for the previous ConfirmationAlert
 structure).
 
 if i stick with this, every time you want a new .alert, add a new enum case
 with appropriate associated data, and handle that case in updateAndPresent().
 to invoke from a View, you then need three things:
 
 (1) a default AlertModel defined in the View by
        @StateObject private var alertModel = AlertModel()

 (2) an .alert() modifier on the View with the newer syntax, which is generically
  		.alert(alertModel.title,
 				isPresented: $alertModel.isPresented,
 				presenting: alertModel,
 				actions: { model in model.actions() },
 				message: { model in model.message })
 
 (3) something that causes the alert to present itself:
		alertModel.updateAndPresent(for: .confirmDeleteLocation(location, nil))

 time will tell if i like it ... i think i prefer the .alert(item: ...) syntax, if only because
 it's three lines in a View and the ability to subclass from the identifiableAlertItem
 seemed more useful.
 */


enum AlertModelType {
		// default type (which will never be shown)
	case none
		// specific type: delete a Location, for which we want the location and a completion closure
	case confirmDeleteLocation(Location, (() -> Void)?)
}

class AlertModel: ObservableObject {
	
		// we keep the isPresented variable used to present the associated alert
		// right here in the AlertModel and make it @Published.  so potentially
		// a view that uses such an alert has a @StateObject viewModel of type
		// AlertModel and references viewModel.isPresented in the .alert() syntax
	@Published var isPresented = false
	
		// defaults for the String title and a Text for the message.  you will want
		// to set these when you call alertModel.updateAndPresent()
	var title = ""
	var message = Text("")
	
		// data to support agreement to do something destructive (title + what to do + a completion)
	var destructiveTitle: String = "OK"
	var destructiveAction: (() -> Void)?

		// data to support not agreeing to do the destructive thing (title + what to do + a completion)
//	var nonDestructiveTitle: String = "Cancel"
//	var nonDestructiveAction: (() -> Void)?
		
		// a @ViewBuilder function on how to produce actions for the alert's View.  this may not
		// be general enough, though: the previous confirmationAlert structure allowed an
		// override possibility, despite never actually overriding it.
	@ViewBuilder
	func actions() -> some View {
		Button(destructiveTitle, role: .destructive) { [self] in
			destructiveAction?()
		}
	}
	
		// call this function with an appropriate type as defined above, which updates the
		// model's variables for the type using associated data for the type.  you will need
		// to add cases, of course, for each type you define.
		// the alert will be presented when isPresented = true is executed.
	func updateAndPresent(for type: AlertModelType, dataManager: DataManager) {
		switch type {
				
			case .none:	// nothing to do!
				return
				
			case .confirmDeleteLocation(let location, let completion):
				title = "Delete \'\(location.name)\'?"
				message = Text("Are you sure you want to delete the Location named \'\(location.name)\'? All items at this location will be moved to the Unknown Location.  This action cannot be undone.")
				destructiveAction = {
					dataManager.delete(location: location)
					completion?()
				}

				// add future cases here ...
		}
		isPresented = true	// this is what presents the alert
	}
	
}

