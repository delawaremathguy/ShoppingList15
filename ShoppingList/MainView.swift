//
//  MainView.swift
//  ShoppingList
//
//  Created by Jerry on 5/6/20.
//  Copyright © 2020 Jerry. All rights reserved.
//

import SwiftUI

// the MainView is where the app begins.  it is a tab view with five tabs.
// not much happens here, other than to track the selected tab (1, 2, 3, or 4),
// although we don't actually use this value for anything right now.

struct MainView: View {
	@State private var selectedTab = 1
	
	var body: some View {
		TabView(selection: $selectedTab) {
			
			NavigationView { ShoppingListView() }
				.tabItem { Label("Shopping List", systemImage: "cart") }
				.tag(1)
			
			NavigationView { PurchasedItemsView() }
				.tabItem { Label("Purchased", systemImage: "purchased") }
				.tag(2)
			
			NavigationView { LocationsView() }
				.tabItem { Label("Locations", systemImage: "map") }
				.tag(3)
			
			NavigationView { TimerTabView()  }
				.tabItem { Label("Stopwatch", systemImage: "stopwatch") }
				.tag(4)
			
			NavigationView { PreferencesTabView() }
				.tabItem { Label("Preferences", systemImage: "gear") }
				.tag(5)
			
		} // end of TabView
		.navigationViewStyle(.stack)

	} // end of var body: some View
		
}

