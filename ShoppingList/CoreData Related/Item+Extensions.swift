//
//  Item+Extensions.swift
//  ShoppingList
//
//  Created by Jerry on 4/23/20.
//  Copyright © 2020 Jerry. All rights reserved.
//

import Foundation
import CoreData
import SwiftUI
//import UIKit

extension Item {
	
	/* Discussion
	
	Update 24 May, 2022:
	
	(1) Fronting of Core Data Attributes
	
	Notice that all except one of the Core Data attributes on an Item in the
	CD model appear with an underscore (_) at the end of their name.
	(the only exception is "id" because tweaking that name is a problem due
	 to conformance to Identifiable, although in retrospect, i should have used
	 id_ in the Core Data model, and then just fronted it with var id: UUID { id_! };
	 however, i don't want to up the version of the database for such a small change.)
	
	my general theory of the case is that no one outside of this class and the DM
	should really be touching these attributes directly -- and certainly no SwiftUI
	views should ever touch these attributes directly.
	
	therefore, i choose to "front" each of them in this file, as well as perhaps provide
	other computed properties of interest.
	 
	  -- one update ... not all of the properties are fronted; the DataManager is well
	     acquainted with Core Data, and in the redesign where all Core Data objects
	     will be exposed using structs using fully-realized values (and not the Core Data
	     objects themselves),
	     it does not seem as important to do this for all properties.
	
	doing so helps smooth out the awkwardness of nil-coalescing (we don't want SwiftUI views
	continually writing item.name ?? "Unknown" all over the place); and in the case of an
	item's quantity, "fronting" its quantity_ attribute smooths the transition from
	Int32 to Int.  indeed, in SwiftUI views, these Core Data objects should
	appear just as objects, without any knowledge that they come from Core Data.
	
	finally, we do not allow SwiftUI views to write to these fronted properties -- all
	 changes must be channeled through the DM.  so, in some sense, what the DM
	 offers to SwiftUI views are read-only objects (as long as the SwiftUI views do
	 not cheat and access the underlying Core Data attributes; and now you know a
	 little more about why we have different names for attributes and their
	 exposed names within the app).
	
	
	(2) @ObservedObject References to Items
	 
	 -- NOTE: the discussion below is not particularly relevant, since there are no
	     @ObservedObject references to any Core Data Items in any SwiftUI view.
	
	only the SelectableItemRowView has an @ObservedObject reference to an Item, and in early
	 development, that view (or whatever this view was during development) had a serious problem:
	
		if a SwiftUI view holds an Item as an @ObservedObject and that object is deleted
	 	while the view is still alive, the view is then holding on to a zombie object.  if SwiftUI
	 	tries to access this object ... yes, SwiftUI may try to access this object between the time
	 	that your code deleted the object and SwiftUI comes around to updating the view ...
	 	your program may crash.

	if you front all your Core Data attributes as i do below, especially by nil-coalescing optional values,
	 the problem above seems to disappear, for the most part (but it's really still there).  even though
	 SwiftUI may be trying to access a deleted object, every attribute in memory will be 0 (e.g., nil for
	 a Date, 0 for an Integer 32, and nil for every optional attribute) and so the fronting property
	 will give SwiftUI _something_ that it can work with, even if it's about to remove the view
	 holding the ObservedObject anyway (and you probably will never see it on screen).
	
	*/
	
		// MARK: - Fronting Properties (Read-only)
	
		// an item's associated location.  this fronts a Core Data optional attribute.
	var location: Location { location_! }

		// MARK: - Computed Properties (determined by associated Location)

		// the name of its associated location
	var locationName: String {
		get { location_?.name_ ?? "Not Available" }
	}
		
}

