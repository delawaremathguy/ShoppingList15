//
//  SectionHeaderButton.swift
//  Chicago Bridge Scorer
//
//  Created by Jerry on 12/12/21.
//  Copyright © 2021 Jerry. All rights reserved.
//

import SwiftUI

struct SectionHeaderButton: View {
	
	var selected: Bool
	var systemName: String
	var action: () -> Void
	
	var body: some View {
		RoundedRectangle(cornerRadius: 8)
			.fill(selected ? Color(.systemGray4) : Color.clear)
			.frame(width: 30, height: 30)
			.overlay(
				Button(action: action) {
					Image(systemName: systemName)
						.font(.body)
				})
			.contentShape(Rectangle())
	}
}
