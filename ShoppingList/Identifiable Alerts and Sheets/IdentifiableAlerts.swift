	//
	//  IdentifiableAlerts.swift
	//  ShoppingList
	//
	//  Created by Jerry on 4/22/21.
	//  Copyright © 2021 Jerry. All rights reserved.
	//

//import SwiftUI
//
//	// MARK: - Confirm DELETE A PLAYER
//class ConfirmDeletePlayerAlert: IdentifiableAlertItem {
//	
//	 init(player: PlayerCD, destructiveCompletion: (() -> Void)? = nil) {
//		super.init()
//		title = "Delete player `\(player.fullName)`?"
//		message = "\(player.fullName) will be deleted and this cannot be undone."
//		destructiveAction = { PlayerManager.shared.delete(player: player) }
//		self.destructiveCompletion = destructiveCompletion
//	}
//}
//
//	// MARK: - Confirm DELETE A SESSION
//class ConfirmDeleteSessionAlert: IdentifiableAlertItem {
//	
//	init(session: SessionCD, destructiveCompletion: (() -> Void)? = nil) {
//		super.init()
//		title = "Delete \'\(session.name)\'?"
//		message = "Are you sure you want to delete the session named \(session.name)?"
//		+ " All \(session.handCount) hands in this Session will be deleted as well."
//		destructiveAction = { SessionManager.shared.delete(session) }
//		self.destructiveCompletion = destructiveCompletion
//	}
//}
//
//
//	// MARK: - Confirm DELETE A GROUP
//class ConfirmDeleteGroupAlert: IdentifiableAlertItem {
//	
//	init(group: GroupCD) {
//		super.init()
//		title = "Delete \'\(group.name)\'?"
//		message = "Are you sure you want to delete this group?."
//		let sessionCount = group.sessionCount
//		if sessionCount > 0 {
//			message += "\n\nNote: Deleting this Group will remove only its session associations.  Each of the \(sessionCount) session(s) currently associated with this group will be retained."
//		}
//		destructiveAction = { GroupCD.delete(group) }
//	}
//}
//
//	// MARK: - Confirm PASTE NEW SESSION DATA
//class ConfirmPasteNewSessionAlert: IdentifiableAlertItem {
//	
//		// incoming info
//	var pasteStatus: PersistentStore.DeltaSessionStatus
//	var affirmativeAction: (SharedSessionPackage, PersistentStore.DeltaSessionStatus) -> Void
//	
//	init(sessionDescription: SharedSessionPackage,
//			 pasteStatus: PersistentStore.DeltaSessionStatus,
//			 affirmativeAction: @escaping (SharedSessionPackage, PersistentStore.DeltaSessionStatus) -> Void,
//			 destructiveCompletion: (() -> Void)? = nil,
//			 nonDestructiveCompletion: (() -> Void)? = nil) {
//		
//		self.pasteStatus = pasteStatus
//		self.affirmativeAction = affirmativeAction
//		super.init()
//		
//		switch pasteStatus {
//			case .previouslyLoaded(_):
//				title = "Import Operation Failed."
//				message = "The data you are trying to import has already been loaded."
//				
//			case .canBeAdded:
//				title = "Import New Session Data?"
//				message = "Confirm that you wish to proceed importing new session data."
//				
//			case .likelyTheSameAs(let session):
//				title = "Import New Session Data?"
//				message = "The data you are trying to import appears to represent the existing session \"\(session.name)\" " +
//				  "played on \(session.dateText(style: .medium)). Are you sure that you wish to proceed?"
//				
//			case .notDecodable:
//				title = "Import Operation Failed."
//				message = "The data you are trying to import does not have the structure of session data."
//		}
//		destructiveTitle = "Proceed"
//		nonDestructiveTitle = "Cancel"
//		
//		destructiveAction = {
//			affirmativeAction(sessionDescription, pasteStatus)
//			//PersistentStore.shared.addNewSession(using: sessionDescription)
//		}
//		self.destructiveCompletion = destructiveCompletion
//		self.nonDestructiveCompletion = nonDestructiveCompletion
//	}
//	
//		// override here, to allow for one-button confirmation that just says "OK" in two cases.
//	override func alert() -> Alert {
//		switch pasteStatus {
//			case .previouslyLoaded(_), .notDecodable:
//				return Alert(title: Text(title), message: Text(message))
//				
//			case .canBeAdded, .likelyTheSameAs(_):
//				return super.alert()
//		}
//	}
//	
//}
//
//
