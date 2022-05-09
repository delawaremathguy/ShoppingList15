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

	// MARK: - a sheet to ADD AN ITEM

	// the basic data to open up AddNewLocationView and specify:
	// -- a function that the AddNewLocationView will use to dismiss the
	//      sheet after the user touches the close or save button and the
	//      AddNewLocationView is finished doing what it's supposed to do.
class AddNewItemSheetItem: IdentifiableSheetItem {
	
		// specialized data for this instance
	private var dismiss: () -> Void
	
	init(dismiss: @escaping () -> Void) {
		self.dismiss = dismiss
		super.init()
	}
	
	override func content() -> AnyView {
		AddNewItemView(dismiss: dismiss)
			.eraseToAnyView()
	}
	
}
