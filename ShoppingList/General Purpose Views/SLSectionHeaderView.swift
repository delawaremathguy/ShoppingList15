//
//  MySectionHeaderView.swift
//  ShoppingList
//
//  Created by Jerry on 6/8/20.
//  Copyright © 2020 Jerry. All rights reserved.
//

import SwiftUI

// this is here to give a consistent theme to section titles, but
// there's certainly a better way to do it using a customized ListStyle.
// but that's a matter for another day.  besides, the View we provide
// here does not really own the space in which it appears.

// XCODE 12 NOTE.  uncomment-out the commented lines below (this code will
// not compile under XCode 11) to get the iOS 13 appearance of section headers.

//struct SLSectionHeaderView: View {
//	
//	var title: String
//	
//	var body: some View {
//		GeometryReader { geo in
//			Text(self.title)
//				.font(.body)
//				.foregroundColor(.black)
//				.textCase(.none)
//				.position(x: geo.size.width/2, y: geo.size.height/2)
//			
//		}
//	}
//	
//}
