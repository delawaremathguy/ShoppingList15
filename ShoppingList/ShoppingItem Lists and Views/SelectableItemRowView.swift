//
//  SelectableItemRowView.swift
//  ShoppingList
//
//  Created by Jerry on 11/28/20.
//  Copyright © 2020 Jerry. All rights reserved.
//

import Foundation
import SwiftUI

// MARK: - SelectableItemRowView

struct SelectableItemRowView: View {
	
	// incoming are an item, whether that item is selected or not, what symbol
	// to use for animation, and what to do if the selector is tapped.  we treat
	// the item as an @ObservedObject: we want to get redrawn if any property changes.
	
	@ObservedObject var item: Item
	var selected: Bool
	var sfSymbolName: String
	var handleTap: () -> ()
	
	var body: some View {
		HStack {
			
			// --- build the little circle to tap on the left
			ZStack {
				// not sure if i want to have at least a visible circle here at the bottom or not.  for
				// some color choices (e.g., Dairy = white) nothing appears to be shown as tappable
//				Circle()
//					.stroke(Color(.systemGray6))
//					.frame(width: 28.5, height: 28.5)
				if selected {
					Image(systemName: "circle.fill")
						.foregroundColor(.blue)
						.font(.title)
				}
				Image(systemName: "circle")
					.foregroundColor(item.color) // Color(item.uiColor))
					.font(.title)
				if selected {
					Image(systemName: sfSymbolName)
						.foregroundColor(.white)
						.font(.subheadline)
				}
			} // end of ZStack
			.animation(.easeInOut, value: selected)
			.frame(width: 24, height: 24)
			.onTapGesture(perform: handleTap)
			
			// color bar is next
			item.color // Color(item.uiColor)
				.frame(width: 10, height: 36)
			
			// name and location
			VStack(alignment: .leading) {
				
				if item.isAvailable {
					Text(item.name)
				} else {
					Text(item.name)
						.italic()
						.strikethrough()
				}
				
				Text(item.locationName)
					.font(.caption)
					.foregroundColor(.secondary)
			}
			
			Spacer()
			
				// quantity at the right
			Text("\(item.quantity)")
				.font(.headline)
				.foregroundColor(Color.blue)
			
		} // end of HStack
	}
}
