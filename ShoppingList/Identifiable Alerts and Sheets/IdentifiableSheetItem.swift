//
//  IdentifiableSheetItem.swift
//  Chicago Bridge Scorer
//
//  Created by Jerry on 10/9/21.
//  Copyright © 2021 Jerry. All rights reserved.
//

import SwiftUI

	// IdentifiableSheetItem is a base class used to trigger sheet displays
// one property and one method are required:
	// -- an id, needed to work with .sheet(item: ...)
	// -- a method to generate a view to put into the sheet

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
