//
//  ActivityViewController.swift
//  ShoppingList
//
//  Created by Jerry on 12/22/21.
//  Copyright © 2021 Jerry. All rights reserved.
//

import SwiftUI

// note: thanks to my friend Mark Perryman (@appledad05) for sharing (!)

struct ActivityViewController: UIViewControllerRepresentable {
	var itemsToShare: [Any]
	var servicesToShareItem: [UIActivity]?
	
	func makeUIViewController(context: UIViewControllerRepresentableContext<ActivityViewController>) -> UIActivityViewController {
		let controller = UIActivityViewController(activityItems: itemsToShare, applicationActivities: servicesToShareItem)
		
		return controller
	}
	
	func updateUIViewController(_ uiViewController: UIActivityViewController, context: UIViewControllerRepresentableContext<ActivityViewController>) {
			// Do nothing here
	}
}

