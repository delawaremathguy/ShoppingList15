	//
	//  IdentifiableAlertItem.swift
	//  ShoppingList
	//
	//  Created by Jerry on 5/4/21.
	//  Copyright © 2021 Jerry. All rights reserved.
	//

import SwiftUI

	// IdentifiableAlertItem is a base class used to trigger alert displays
	// -- an id, needed to work with .sheet(item: ...)
	// -- title and message for the Alert
	// -- destructive & non-destructive titles and actions
	// -- destructive & non-destructive completion handlers

class IdentifiableAlertItem: Identifiable {
		// must be Identifiable to work with .alert(item: ...)
	var id = UUID()
		// strings for title and message -- you will always want to set these yourself
	var title: String = "Alert title"
	var message: String = "Alert message"
	
		// data to support agreement to do something destructive (title + what to do)
	var destructiveTitle: String = "Yes"
	var destructiveAction: (() -> Void)?
	
		// data to support not agreeing to do the destructive thing (title + what to do)
	var nonDestructiveTitle: String = "No"
	var nonDestructiveAction: (() -> Void)?
	
		// completion handlers for after we do what we do. generally, these
		// will execute view-specific code (dismiss() or an animation?) that is
		// determined at the call site when creating the alert (e.g., not code performed
		// on model data such as deleting a Core Data object)
	var destructiveCompletion: (() -> Void)?
	var nonDestructiveCompletion: (() -> Void)?
	
		// these are implementation hooks to do actions and then allow a separate
		// completion handler
	fileprivate func doDestructiveActionWithCompletion() {
		destructiveAction?()
		destructiveCompletion?()
	}
	
	fileprivate func doNonDestructiveActionWithCompletion() {
		nonDestructiveAction?()
		nonDestructiveCompletion?()
	}
	
		// uses all the data above to produce an Alert in an .alert() modifier
		// note: some subclasses might override to produce a variation of the Alert,
		// such as one that has a single OK button
	func alert() -> Alert {
		Alert(title: Text(title),
					message: Text(message),
					primaryButton:
							.cancel(Text(nonDestructiveTitle), action: doNonDestructiveActionWithCompletion),
					secondaryButton:
							.destructive(Text(destructiveTitle), action: doDestructiveActionWithCompletion))
	}
	
		// simple init ... but nothing to do here, since everything is defaulted
	init() { }
	
}

