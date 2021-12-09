//
//  PersistentStore.swift
//  ShoppingList
//
//  Created by Jerry on 7/4/20.
//  Copyright © 2020 Jerry. All rights reserved.
//

import Foundation
import CoreData

final class PersistentStore: ObservableObject {
	
	private(set) static var shared = PersistentStore()
	
	// this makes sure we're the only one who can create one of these
	private init() { }
		
	lazy var persistentContainer: NSPersistentContainer = {
		/*
		The persistent container for the application. This implementation
		creates and returns a container, having loaded the store for the
		application to it. This property is optional since there are legitimate
		error conditions that could cause the creation of the store to fail.
		*/
		
		// choose here whether you want the cloud or not
		// -- when i install this on a device, i may want the cloud (you will need an Apple Developer
		//    account to use the cloud an add the right entitlements to your project);
		// -- for some initial testing on the simulator, i may use the cloud;
		// -- but for basic app building in the simulator, i prefer a non-cloud store.
		// by the way: using NSPersistentCloudKitContainer in the simulator works fine,
		// but you will see lots of console traffic about sync transactions.  those are not
		// errors, but it will clog up your console window.
		//
		// by the way, just choosing to use NSPersistentCloudKitContainer is not enough by itself.
		// you will have to make some changes in the project settings. see
		//    https://developer.apple.com/documentation/coredata/mirroring_a_core_data_store_with_cloudkit/setting_up_core_data_with_cloudkit
		
		let container = NSPersistentContainer(name: "ShoppingList")
		// let container = NSPersistentCloudKitContainer(name: "ShoppingList")

		// some of what follows are suggestions by "Apple Staff" on the Apple Developer Forums
		// for the case when you have an NSPersistentCloudKitContainer and iCloud synching
		// https://developer.apple.com/forums/thread/650173
		// you'll also see there how to use this code with the new XCode 12 App/Scene structure
		// that replaced the AppDelegate/SceneDelegate of XCode 11 and iOS 13.  additionally,
		// follow along with this discussion https://developer.apple.com/forums/thread/650876
		
		// (1) Enable history tracking.  this seems to be important when you have more than one persistent
		// store in your app (e.g., when using the cloud) and you want to do any sort of cross-store
		// syncing.  See WWDC 2019 Session 209, "Making Apps with Core Data."
		// also, once you use NSPersistentCloudKitContainer and turn these on, then you should leave
		// these on, even if you just now want to use what's on-disk with NSPersistentContainer and
		// without cloud access.
		guard let persistentStoreDescriptions = container.persistentStoreDescriptions.first else {
			fatalError("\(#function): Failed to retrieve a persistent store description.")
		}
		persistentStoreDescriptions.setOption(true as NSNumber,
																					forKey: NSPersistentHistoryTrackingKey)
		persistentStoreDescriptions.setOption(true as NSNumber,
																					forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
		
	
		container.loadPersistentStores(completionHandler: { (storeDescription, error) in
			if let error = error as NSError? {
				// Replace this implementation with code to handle the error appropriately.
				// fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
				
				/*
				Typical reasons for an error here include:
				* The parent directory does not exist, cannot be created, or disallows writing.
				* The persistent store is not accessible, due to permissions or data protection when the device is locked.
				* The device is out of space.
				* The store could not be migrated to the current model version.
				Check the error message to determine what the actual problem was.
				*/
				fatalError("Unresolved error \(error), \(error.userInfo)")
			}
			
		})
		
		// (2) also suggested for cloud-based Core Data are the two lines below for syncing with
		// the cloud.  i don't think there's any harm in adding these even for a single, on-disk
		// local store.
		container.viewContext.automaticallyMergesChangesFromParent = true
		container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
		
		return container
	}()
	
	var context: NSManagedObjectContext { persistentContainer.viewContext }
	
	func saveContext () {
		if context.hasChanges {
			do {
				try context.save()
			} catch let error as NSError {
				NSLog("Unresolved error saving context: \(error), \(error.userInfo)")
			}
		}
	}
}
