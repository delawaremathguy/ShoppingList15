	//
	//  IdentifiableSheets.swift
	//  ShoppingList
	//
	//  Created by Jerry on 10/11/21.
	//  Copyright © 2021 Jerry. All rights reserved.
	//

import SwiftUI

	// MARK: - a sheet to ADD A LOCATION

	// the basic data to open up AddNewLocationView and specify:
	// -- a function that the AddNewLocationView will use to dismiss the
	//      sheet after the user touches the close or save button and the
	//      AddNewLocationView is finished doing what it's supposed to do.
class AddNewLocationSheetItem: IdentifiableSheetItem {
	
		// specialized data for this instance
	private var dismiss: () -> Void
	
	init(dismiss: @escaping () -> Void) {
		self.dismiss = dismiss
		super.init()
	}
	
	override func content() -> AnyView {
		AddNewLocationView(dismiss: dismiss)
			.eraseToAnyView()
	}
	
}

	//	// MARK: - a sheet to ADD OR MODIFY A PLAYER
	//
	//import CoreData
	//
	//	// the basic data to open up the AddModifyPlayerView:
	//	// -- what player data to edit
	//	// -- how to dismiss
	//class AddModifyPlayerSheetItem: IdentifiableSheetItem {
	//
	//		// specialized data
	//	var player: PlayerCD?
	//	var suggestedUUID: UUID?
	//	var dismissAction: () -> Void
	//
	//	init(player: PlayerCD?, suggestedUUID: UUID? = nil, dismissAction: @escaping () -> Void) {
	//		self.player = player
	//		self.suggestedUUID = suggestedUUID
	//		self.dismissAction = dismissAction
	//		super.init()
	//	}
	//
	//	override func content() -> AnyView {
	//		AddModifyPlayerView(player: player,
	//												suggestedUUID: suggestedUUID,
	//												dismissAction: dismissAction)
	//			.wrappedInNavigationView()
	//			.eraseToAnyView()
	//	}
	//
	//}
	//
	//
	//	// MARK: - a sheet to PRESENT THE MAILVIEW
	//
	//class MailViewSheet: IdentifiableSheetItem {
	//
	//	private var session: SessionCD?
	//	private var dismiss: () -> Void
	//
	//	init(session: SessionCD?, dismiss: @escaping () -> Void) {
	//		self.session = session
	//		self.dismiss = dismiss
	//		super.init()
	//	}
	//
	//	override func content() -> AnyView {
	//		MailPreparationSheetView(session: session, dismiss: dismiss)
	//			.wrappedInNavigationView()
	//			.eraseToAnyView()
	//	}
	//
	//}

