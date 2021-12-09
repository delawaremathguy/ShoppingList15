//
//  LocationRowView.swift
//  ShoppingList
//
//  Created by Jerry on 6/1/20.
//  Copyright © 2020 Jerry. All rights reserved.
//

import SwiftUI

// MARK: - LocationRowData Definition
// this is a struct to transport all the incoming data about a Location that we
// will display.  see the commentary over in EditableItemData.swift and
// SelectableItemRowView.swift about why we do this.
struct LocationRowData {
	let name: String
	let itemCount: Int
	let visitationOrder: Int
	let uiColor: UIColor
	
	init(location: Location) {
		name = location.name
		itemCount = location.itemCount
		visitationOrder = location.visitationOrder
		uiColor = location.uiColor
	}
}

// MARK: - LocationRowView

struct LocationRowView: View {
	 var rowData: LocationRowData

	var body: some View {
		HStack {
			// color bar at left (new in this code)
			Color(rowData.uiColor)
				.frame(width: 10, height: 36)
			
			VStack(alignment: .leading) {
				Text(rowData.name)
					.font(.headline)
				Text(subtitle())
					.font(.caption)
			}
			if rowData.visitationOrder != kUnknownLocationVisitationOrder {
				Spacer()
				Text(String(rowData.visitationOrder))
			}
		} // end of HStack
	} // end of body: some View
	
	func subtitle() -> String {
		if rowData.itemCount == 1 {
			return "1 item"
		} else {
			return "\(rowData.itemCount) items"
		}
	}
	
}
