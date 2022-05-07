//
//  AlertModel.swift
//  ShoppingList
//
//  Created by Jerry on 5/4/22.
//  Copyright © 2022 Jerry. All rights reserved.
//

import SwiftUI

// This file contains an idea that I am working on, to replace all the deprecated
// .alert(item: ...) modifiers scattered throughout the code by the newer
// .alert( : isPresented: presenting: actions: message:) syntax.  It turns out the idea
// does not quite work ... this newer form still is not a simple, direct replacement
// and still has some quirks.
//
// Nevertheless, I'll leave this file here for now, noting that in the LocationsView and the
// ModifyExistingLocationView you will see some commented out code that should be
// ignored for now until I figure out what's going on.

enum AlertModelType {
	case none
	case confirmDeleteLocation(Location, (() -> Void)?)
}

class AlertModel: ObservableObject {
	
		// we keep the isPresented variable used to trigger the associated alert
		// right here in the AlertModel and make it @Published.  so potentially
		// a view that uses such an alert has a @StateObject viewModel of type
		// AlertModel and references viewModel.isPresented in the .alert() syntax
	@Published var isPresented = false
	
		// defaults for the String title and a Text for the message.  you will want
		// to set these when you call alertModel.updateAndTrigger()
	var title = ""
	var message = Text("")
	
		// data to support agreement to do something destructive (title + what to do + a completion)
	var destructiveTitle: String = "OK"
	var destructiveAction: (() -> Void)?

		// data to support not agreeing to do the destructive thing (title + what to do + a completion)
//	var nonDestructiveTitle: String = "Cancel"
//	var nonDestructiveAction: (() -> Void)?
		
	// a default @ViewBuilder function on how to produce actions for the alert's View
	@ViewBuilder
	func actions() -> some View {
		Button(destructiveTitle, role: .destructive) { [self] in
			destructiveAction?()
		}
	}
	
	func updateAndTrigger(for type: AlertModelType) {
		switch type {
				
			case .none:
				return
				
			case .confirmDeleteLocation(let location, let completion):
				title = "Delete \'\(location.name)\'?"
				message = Text("Are you sure you want to delete the Location named \'\(location.name)\'? All items at this location will be moved to the Unknown Location.  This action cannot be undone.")
				destructiveAction = {
					Location.delete(location)
					completion?()
				}
				isPresented = true	// don;t forget to set this ... this triggers the alert

		}
	}
	
}

