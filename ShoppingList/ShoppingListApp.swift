//
//  ShoppingListApp.swift
//  ShoppingList
//
//  Created by Jerry on 11/19/20.
//  Copyright © 2020 Jerry. All rights reserved.
//

import Foundation
import SwiftUI

// the app will hold an object of type Today, which keeps track of the "start of
// today."  the PurchasedItemsTabView needs to know what "today" means to properly
// section out its data, and it might seem to you that the PurchasedItemsTabView
// could handle that by itself.  however, if you push the app into the background
// when the PurchasedItemsTabView is showing and then bring it back a few days later,
// the PurchasedItemsTabView will show the same display as when it went into the background
// and not know about the change; so its view will need to be updated.  that's why
// this is here: the app certainly knows when it becomes active, and can update what
// "today" means, and the PurchasedItemsTabView will pick up on that in its environment
class Today: ObservableObject {
	@Published var start: Date = Calendar.current.startOfDay(for: Date())
	func update() {
		let newStart = Calendar.current.startOfDay(for: Date())
		if newStart != start {
			start = newStart
		}
	}
}

// this is the new App structure for iOS 14.  it pushes the managedObjectContext of the
// singleton (global) PersistentStore into the environment of the MainView -- this makes
// sure that all the @FetchRequets will work.  it pushes a Today object into the environment,
// primarily for the PurchasedItemsTabView.  and it applies the .onReceive modifiers
// to the MainView to watch being moved into and out of the background

// as an alternative structure, consider the comments on the Apple Developer Forums in this thread
//     https://developer.apple.com/forums/thread/650876
// which suggests watching for changes to the Scene, rather than hooking into the NotificationCenter

@main
struct ShoppingListApp: App {
	
	// we create the PersistentStore here (although it will be created lazily anyway)
	// and the date object that defines the meaning of "today"
	@StateObject var persistentStore = PersistentStore.shared
	@StateObject var today = Today()
	
	var body: some Scene {
		WindowGroup {
			MainView()
				.environment(\.managedObjectContext, persistentStore.context)
				.environmentObject(today)
				.onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification),
									 perform: handleResignActive)
				.onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification),
									 perform: handleBecomeActive)
		}
	}
	
	func handleResignActive(_ note: Notification) {
		// when going into background, save Core Data and shutdown timer
		persistentStore.saveContext()
		if kDisableTimerWhenAppIsNotActive {
			gInStoreTimer.suspend()
		}
	}
	
	func handleBecomeActive(_ note: Notification) {
		// when app becomes active, restart timer if it was running previously
		// also update the meaning of Today because we may be transitioning to
		// active on a different day than when we were pushed into the background
		if gInStoreTimer.isSuspended {
			gInStoreTimer.start()
		}
		today.update()
	}

}
