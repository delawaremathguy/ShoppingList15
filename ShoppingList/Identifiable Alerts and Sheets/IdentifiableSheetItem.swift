//
//  IdentifiableSheetItem.swift
//  ShoppingList
//
//  Created by Jerry on 10/9/21.
//  Copyright © 2021 Jerry. All rights reserved.
//

import SwiftUI

// the IdentifiableSheetItem class returns a View that will appear within a sheet, given
// some data with which to create and dismiss the sheet.  this extension is a convenient
// way to turn that view into a type-erased view, just to avoid getting into the weeds
// about syntax issues below.
extension View {
	func eraseToAnyView() -> AnyView {
		AnyView(self)
	}
}

	// IdentifiableSheetItem is a base class used to trigger sheet displays.
	// one property and one method are required:
	// -- an id, needed to work with .sheet(item: ...)
	// -- a method to generate a view to put into the sheet
	//
	// create a subclass of IdentifiableSheetItem for every sheet instance you
	// want to open.  for each, you'll want a custom initializer to bring in the
	// data necessary to create the view being presented by the sheet, and you'll
	// also probably bring in and pass along to that View a function that will ultimately
	// close the sheet (e.g., after touching a close or a cancel button).  often,
	// such a dismiss function will set the identifiable sheet item variable you use to
	// open the sheet back to nil (which dismisses the sheet).

class IdentifiableSheetItem: Identifiable {

		// Identifiable conformance, implemented as a UUID
	var id = UUID()
	
	// a function to generate content that's a View, except we just don't know exactly
	// what kind of view it is.  any subclass of us will have to override and return
	// their custom view with a type-erasing .eraseToAnyView() modifier.
	func content() -> AnyView {
		return EmptyView().eraseToAnyView()
	}
}
