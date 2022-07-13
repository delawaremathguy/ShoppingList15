//
//  LocationRowView.swift
//  ShoppingList
//
//  Created by Jerry on 6/1/20.
//  Copyright © 2020 Jerry. All rights reserved.
//

import SwiftUI

//// MARK: - LocationRowData Definition
//
//// this is a struct to transport all the incoming data about a Location that we
//// will display.  see the commentary over in DraftItem.swift and
//// SelectableItemRowView.swift about why we do this.
//struct LocationRowData {
//
//	var locationStruct: LocationStruct
////	let name: String
////	let itemCount: Int
////	let visitationOrder: Int
////	//let uiColor: UIColor
////	let color: Color
////
////	init(location: Location) {
////		name = location.name
////		itemCount = location.itemCount
////		visitationOrder = location.visitationOrder
////		//uiColor = location.uiColor
////		color = location.color
////	}
//}

// MARK: - LocationRowView

struct LocationRowView: View {
	 var locationStruct: LocationStruct

	var body: some View {
		HStack {
			// color bar at left (new in this code)
			locationStruct.color // Color(rowData.uiColor)
				.frame(width: 10, height: 36)
			
			VStack(alignment: .leading) {
				Text(locationStruct.name)
					.font(.headline)
				Text(subtitle())
					.font(.caption)
			}
			if locationStruct.visitationOrder != kUnknownLocationVisitationOrder {
				Spacer()
				Text(String(locationStruct.visitationOrder))
			}
		} // end of HStack
	} // end of body: some View
	
	func subtitle() -> String {
		if locationStruct.itemCount == 1 {
			return "1 item"
		} else {
			return "\(locationStruct.itemCount) items"
		}
	}
	
}
