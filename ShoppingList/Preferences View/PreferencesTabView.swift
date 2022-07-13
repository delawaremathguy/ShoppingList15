//
//  OperationTabView.swift
//  ShoppingList
//
//  Created by Jerry on 6/11/20.
//  Copyright © 2020 Jerry. All rights reserved.
//

import SwiftUI

struct PreferencesTabView: View {
	
	@EnvironmentObject private var dataManager: DataManager
	
	// this view is a restructured version of the older DevToolTab to now handle
	// user preferences.  for the moment, the only preference we have is for
	// setting the number of days back in time to section out the item in the
	// PurchasedItemsView:
	// -- first section: items purchased within the last N days
	// -- second section: all other items purchased.
	// we'll allow N here to be 0 ... 10
	
	// i have made no real effort to pretty-up this View.  it's purely a
	// development hack to load sample data, remove data, and flip a few
	// switches in the code.  this could become a "settings" or "preferences"
	// tab in the future, in which case i would clean it up; although the only
	// thing that might remain is whether the timer is stopped when in the background.
	
	@State private var confirmDataHasBeenAdded = false
	@State private var locationsAdded: Int = 0
	@State private var itemsAdded: Int = 0
	
	// user default. 0 = purchased today; 3 = purchased up to 3 days ago, ...
	@AppStorage(wrappedValue: 3, "PurchasedHistoryMarker") private var historyMarker
	
	var body: some View {
		VStack(spacing: 0) {
			
			Form {
				Section(header: Text("Purchased Items History Mark").textCase(.none),
								footer: Text("Sets the number of days to look backwards in time to separate out items purchased recently.")) {
					Stepper(value: $historyMarker, in: 0...10) {
						HStack {
							SLFormLabelText(labelText: "History mark: ")
							Text("\(historyMarker)")
						}
					}
				}
			}
			
#if targetEnvironment(simulator)
//			// all of what follows is not the best of code -- hey, it's quick and dirty so i
//			// can add sample data to the app for testing, and also dump data from the app
//			// in case i want to reseed the data in the future.  setting kDevTools = false in
//			// Development.swift will remove this (and you should for real usage, although
//			// leaving this in on a device gives you a good way to suck out its data and later
//			// restore it after a re-install).
////			if kShowDevTools {
//				Rectangle()
//					.frame(height: 1)
//
//
//				Text("This button will add some sample data so you can test out the app. Presumably, you'll delete the app from a device after doing this, and then reinstall it later to start with a clean slate.")
//					.padding([.leading, .trailing], 10)
//					.padding(.bottom, 20)
//
//				Button("Load sample data") {
//					let currentLocationCount = dataManager.locationCount() // what it is now
//					let currentItemCount = dataManager.itemCount() // what it is now
//					dataManager.populateDatabaseFromJSON()
//					self.locationsAdded = dataManager.locationCount() - currentLocationCount // now the differential
//					self.itemsAdded = dataManager.itemCount() - currentItemCount // now the differential
//					self.confirmDataHasBeenAdded = true
//				}
//				.padding(.bottom, 20)
//				.alert("Data Added", isPresented: $confirmDataHasBeenAdded) {
//					Button("OK", role: .cancel) {}
//				} message: {
//					Text("Sample data for the app (\(locationsAdded) locations and \(itemsAdded) shopping items) have been added.")
//				}
//
//				Text("This button lets you offload existing data to JSON. On the simulator, it will dump to files on the Desktop (see Development.swift to get the path right); on a device, it will simply print to the console.  You can use that JSON output later to re-seed the app data.")
//					.padding([.leading, .trailing], 10)
//					.padding(.bottom, 20)
//
//				Button("Write database as JSON") {
//					dataManager.exportDataToJSON()
//				}
//				.padding(.bottom, 20)
//
//				Text("This developer's view can and should be hidden for production (see Development.swift)")
//					.italic()
//					.padding([.leading, .trailing, .bottom], 10)
//
////				Spacer()
////			}
#endif
			
			Spacer()
			Divider()
		} // end of VStack
		.navigationBarTitle("Preferences")
	} // end of body
	
}

