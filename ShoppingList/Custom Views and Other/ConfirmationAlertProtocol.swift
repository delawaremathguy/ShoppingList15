//
//  ConfirmationAlertProtocol.swift
//  Chicago Bridge Scorer
//
//  Created by Jerry on 5/4/21.
//  Copyright © 2021 Jerry. All rights reserved.
//

import SwiftUI

protocol ConfirmationAlertProtocol: Identifiable {
	// must be Identifiable to work with .alert(item: ...)
	var id: UUID { get }
	
	// strings for title and message
	var title: String { get }
	var message: String { get }
	
	// data to support agreement to do something destructive
	var destructiveTitle: String { get }
	func destructiveAction()
	
	// data to support not agreeing to do the destructive thing
	var nonDestructiveTitle: String { get }
	func nonDestructiveAction()
	
	// completion handlers for after we do what we do. generally, these
	// will execute view-specific code (dismiss() or an animation?) and are
	// determined at the call site when creating the alert, and are
	// not code performed on model data such as deleting a Core Data object
	var destructiveCompletion: (() -> Void)? { get set }
	var nonDestructiveCompletion: (() -> Void)? { get set }
	
	// uses all the data above to produce an Alert in an .alert() modifier
	func alert() -> Alert
}

extension ConfirmationAlertProtocol {
	// default titles for buttons -- you may wish to override
	var destructiveTitle: String { "Yes" }
	var nonDestructiveTitle: String { "No" }
	// default actions -- normally, you should provide the destructive
	// action; it's unusual, but you may want to do something other than
	// nothing when the user declines to do the destructive action
	func nonDestructiveAction() { }
	
	// these are implementation hooks to do actions and then allow a separate
	// completion handler
	fileprivate func doDestructiveAction() {
		destructiveAction()
		destructiveCompletion?()
	}
	
	fileprivate func doNonDestructiveAction() {
		nonDestructiveAction()
		nonDestructiveCompletion?()
	}
	
	// produces the actual alert
	func alert() -> Alert {
		Alert(title: Text(title),
					message: Text(message),
					primaryButton:
						.cancel(Text(nonDestructiveTitle), action: doNonDestructiveAction),
					secondaryButton:
						.destructive(Text(destructiveTitle), action: doDestructiveAction))
	}
}


// USING THIS:  a confirmation alert, say, to delete a "player" in a game
// would look like this
//	struct ConfirmDeletePlayerAlert: ConfirmationAlertProtocol {
//
//		var id = UUID()
//
//		var player: PlayerCD // the player to be deleted
//
//		var title: String
//		{ "Delete player \'\(player.fullName)\'?" }
//
//		var message: String
//		{ "\(player.fullName) will be deleted and this cannot be undone." }
//
//		func destructiveAction() {
//			Player.delete(player: player)
//		}
//
//		var destructiveCompletion: (() -> Void)?
//		var nonDestructiveCompletion: (() -> Void)?
//
//		init(player: PlayerCD,
//				 destructiveCompletion: (() -> Void)? = nil, nonDestructiveCompletion: (() -> Void)? = nil) {
//			self.player = player
//			self.destructiveCompletion = destructiveCompletion
//			self.nonDestructiveCompletion = nonDestructiveCompletion
//		}
//	}
//
// so, a template you can use is this:

struct MyCustomConfirmationAlert: ConfirmationAlertProtocol {
	
	var id = UUID() // you must assign an id
	
	// add any specialized data as one or more variables,
	// such a player in a game or a list of items on a shopping list
	// that will be deleted

	var title: String
	{ "Alert title" }
	
	var message: String
	{ "Alert message" }
	
	func destructiveAction() {
		// implement code for the destructive action
	}
	
	var destructiveCompletion: (() -> Void)?
	var nonDestructiveCompletion: (() -> Void)?
	
	init(
		/* pass in your own custom data here, if any, maybe as the first argument */
		destructiveCompletion: (() -> Void)? = nil, nonDestructiveCompletion: (() -> Void)? = nil) {
		
		// assign your custom data here from the arguments passed in
		self.destructiveCompletion = destructiveCompletion
		self.nonDestructiveCompletion = nonDestructiveCompletion
	}
	
	// it's possible that you may want to implement your own
	//	func nonDestructiveAction() { }
	//
	// it's also possible you want to change the Yes/No titles
	//	var destructiveTitle: String { "Go" }
	//	var nonDestructiveTitle: String { "Stop" }

}

// whenever you want to use your MyCustomConfirmationAlertTemplate in a view, you
// need just three lines of code in most cases:
//
// (1) a state variable
//
//		@State private var myCustomConfirmationAlert: MyCustomConfirmationAlert?
//
// (2) an alert modifier on the view
//
//		.alert(item: $myCustomConfirmationAlert) { item in item.alert() }
//
// (3) to make the alert happen, just instantiate and assign a MyCustomConfirmationAlert
// struct to myCustomConfirmationAlert to trigger the alert, passing along any custom
// data and possibly passing completion closures if needed
//
//		myCustomConfirmationAlert = MyCustomConfirmationAlert(/* specific data to pass, if any */)
