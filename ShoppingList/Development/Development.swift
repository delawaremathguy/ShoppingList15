//
//  Development.swift
//  ShoppingList
//
//  Created by Jerry on 5/14/20.
//  Copyright © 2020 Jerry. All rights reserved.
//

import Foundation

// what i previously called a "Dev Tools" tab -- now incorporated into the
// Preferences tab -- so that if you want to use this as a real app (device or simulator),
// access to all the debugging stuff can be displayed or not by setting this global
// variable `kShowDevTools`. for now, we'll show this on the simulator and not on a device.

#if targetEnvironment(simulator)
	let kShowDevTools = true
#else
	let kShowDevTools = false
#endif

// one of the things that seems to have changed from release to release of SwiftUI is when
// the view modifiers .onAppear and .onDisappear are called.  so throughout the app, you
// will find .onAppear and .onDisappear modifiers that print out when these actually do
// something by calling back to these two little functions.  you can turn this logging
// off by just commenting out the print statement (or deleting their being called from code).
func logAppear(title: String) {
	print(title + " Appears")
}
func logDisappear(title: String) {
	print(title + " Disappears")
}



