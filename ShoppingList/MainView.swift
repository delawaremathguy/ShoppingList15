//
//  MainView.swift
//  ShoppingList
//
//  Created by Jerry on 5/6/20.
//  Copyright © 2020 Jerry. All rights reserved.
//

import SwiftUI

// the MainView is where the app begins.  it is a tab view with four tabs.
// a fifth tab also appears if kShowDevToolsTab is true (this is set in code
// in Development.swift). not much happens here, other
// than to track the selected tab (1, 2, 3, or 4), although we don't actually
// use this value for anything right now.

struct MainView: View {
	@State private var selectedTab = 1
	
	var body: some View {
		TabView(selection: $selectedTab) {
			
			NavigationView { ShoppingListTabView() }
				.tabItem { Label("Shopping List", systemImage: "cart") }
				.tag(1)
			
			NavigationView { PurchasedItemsTabView() }
				.tabItem { Label("Purchased", systemImage: "purchased") }
				.tag(2)
			
			NavigationView { LocationsTabView() }
				.tabItem { Label("Locations", systemImage: "map") }
				.tag(3)
			
			NavigationView { TimerTabView()  }
				.tabItem { Label("Stopwatch", systemImage: "stopwatch") }
				.tag(4)
			
			NavigationView { PreferencesTabView() }
				.tabItem { Label("Preferences", systemImage: "gear") }
				.tag(5)
			
		} // end of TabView
		.navigationViewStyle(StackNavigationViewStyle())

	} // end of var body: some View
	
}

struct MainView_Previews: PreviewProvider {
	static var previews: some View {
		MainView()
	}
}
