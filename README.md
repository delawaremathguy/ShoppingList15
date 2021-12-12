#  About "ShoppingList15"

* This repo was first made publicly available on XXX December, XXXX.

ShoppingList15 is a simple iOS app to process a shopping list that you can take to the grocery store with you, and move items off the list as you pick them up.  It persists data in CoreData and uses SwiftUI.  The project should be compiled with XCode 13.2 or later and will run on iOS 15.2 or later.

* An [earlier version of this project](https://github.com/delawaremathguy/ShoppingList14) is available that works with XCode 12.5/iOS 13.  If you have not yet made the move to XCode 13 and iOS 15, you should use this earlier project instead.

* An [even earlier version of this project](https://github.com/delawaremathguy/ShoppingList) is available that works with XCode 11.7/iOS 13.7. 


Feel free to use this as is, to develop further,  to completely ignore, or even just to inspect and then send me a note or Open an Issue to tell me I am doing this all wrong.  


### Most Recent Update of XX December, 2021

This is the first update of my two-year-old ShoppingList project for Xcode 13/iOS 15.  Major changes that you will find in this release of the project are:

* Cloud-syncing across devices on the same Apple ID is implemented. (Note: *To use this feature, you will need an Apple Developer account, you will need to manage app signing, and you must specify your own bundle identifier*.)

* I have separated what were dual-purpose "AddOrModify" views for both Items and Locations so that we now have a "ModifyExisting" view that is presented via a NavigationLink, and an "AddNew" view that is brought up by a sheet. 

* Alerts and sheets more often than not prefer to use a presentation syntax of `.alert(item:)` or `.sheet(item:)`, using a slightly newer design pattern based on class objects (and not structs with protocol requirements).  There is an obvious advantage here -- once you "get" the implementation idea, that every such item is a little bit of a "view model" to drive an alert or sheet, any one view can use a single `.alert` or `.sheet` modifier that handles any number of possible alerts and sheets, depending on how you set up the (Identifiable) item.  So the "one alert/one sheet per view" restriction of SwiftUI is not necessarily (!) a concern with this design pattern.

* The functionality of what was SearchBarView (by Simon Ng) has now been completely replaced using the iOS 15 native `.searchable()` view modifier.

* The coding for the display of Items in the shopping list view and purchased list view has, thankfully, been cleanly merged, removing much code duplication. 

* UI changes: 

  * The "Add New Item/Location" button at the top of the ShoppingList, PurchasedItems, and Locations view have been removed.  Each screen already has a "+" at the top, right of the screen to add a new shopping item or location.
  * The "Mark All Items Available" and "Move All Items Off-list" buttons on the shopping list view are now in an HStack (not a VStack), with some animation managing the transition if the "Mark All Items Available" button need not appear.
  

## General App Structure

The main screen is a TabView, to show 

* a current shopping list (which can appear as a single section, or in multiple sections by Location) 

![](IMG_0175.jpeg)  ![](IMG_0176.jpeg) 


* a (searchable) list of previously purchased items, with one section showing items "purchased today" and a second section showing all other items 

![](IMG_0177.jpeg)  ![](IMG_0173.jpeg) 

* a list of "locations" in a store, such as "Dairy," "Fruits & Vegetables," "Deli," and so forth

![](IMG_0174.jpeg) 

* an in-store timer, to track how long it takes you to complete shopping (not shown), and

* a user Preferences tab, which also contains (for development purposes only) lets you load sample data that you can use to try out the app.

For the first two tabs, tapping on the circular button on the leading edge of an item's display moves a shopping item from one list to the other list (from "on the shopping list" to "purchased" and vice-versa).  

Tapping on any item (*not the leading circular button*) in either list lets you edit it for name, quantity, assign/edit the store location in which it is found, or even delete the item.  Long pressing on an item gives you a contextMenu to let you move items between lists, toggle between the item being available and not available, or directly delete the item.  (*Items not available will have a strike-through, italic presentation on screen*.)

The shopping list is sorted by the visitation order of the locations, and then alphabetically within each location.  Items in the shopping list cannot be otherwise re-ordered, although all items in the same Location have the same user-assignable color as a form of grouping.  

Tapping on the leading icon in the navigation bar of the Shopping List will toggle the display from a simple, one-section list, to a multi-section list. Tapping on the "envelope" trailing icon allows you to send an email with the shopping list to whomever would prefer a printed copy.

Tapping on the leading icon in the navigation bar of the Purchased Item List will toggle the display from a simple, one-section list, to a two-section list that breaks out items as those purchased "today" and those purchased earlier.

The third tab shows a list of all locations, each having a visitation order (an integer from 1...100, as in, go to the dairy first, then the deli, then the canned vegetables, etc).  One special Location is the "Unknown Location," which serves as the default location for all new items.  I use this special location to mean that "I don't really know where this item is yet, but I'll figure it out at the store." The unknown location has the highest of all visitation order values, so that it comes last in the list of Locations, and shopping items with this unknown location will come at the bottom of the shopping list. 

Tapping on a Location in the list lets you edit location information, including reassigning the visitation order, changing its color, or deleting it.  In this updated version, the color is settable using the ColorPicker available in iOS 14.  You will also see a list of the Items that are associated with this Location. A long press on a location (other than the "unknown location") will allow you to delete the location directly.

* What happens to Items in a Location when the Location is deleted?  The Items are not deleted, but are moved to the Unknown Location.

The fourth tab is an in-store timer, with three simple button controls: "Start," "Stop," and "Reset."  This timer does *not* pause when the app goes into the background -- e.g., if you pull up a calculator or take a phone call while shopping. (*See GlobalTimer.swift if you wish to change this behaviour*.)

Finally, there is a Preferences tab that contains two areas:

* one that's intended for production, where you can change the user default value for the number of days used to section out the PurchasedTabView;
* the other for "development-only" purposes, to allow wholesale loading of sample data and offloading data for later use. This area should be hidden for any production version of the app (*see Development.swift to hide this*).

Here's what you do next:


* **If you would like to test out this app and decide if it might be of interest to you**, run it on the simulator, go straight to the Preferences tab on startup and tap the "Load Sample Data" button.  Now you can play with the app.

* **If you plan to install and use this app on your own device**, the app will start with an empty shopping list and a location list having only the special "Unknown Location"; from there you can create your own shopping items and locations associated with those items.  (*Hint: add Locations before adding Items!*)  I would suggest that you remove the development-only portion of the Preferences tab before installing the app (see comments in Development.swift).



## What's New in ShoppingList15

This third iteration of my ShoppingList project will be my learning environment for what most people cal "SwiftUI 3," and will try to use new features available in iOS 15.

There are no design changes to the app, so please check out the earlier README documents.

Here are some of the major, code-level changes:

* There have been other name changes to the Core Data model (you will read about these and why they were made in the code) and I have versioned the model. Although I *believe* that previous CD models will migrate data from earlier models, I *cannot guarantee this, based on my own experience*.  Unfortunately, I lost data during migration on my own device (from V1 to V2) due to some combination of using the new App structure, or mixing versions of XCode with the version of iOS on my phone.

* Many code changes have been made and much has been simplified.

* Comments throughout the code have been updated -- some with expanded detail on why something is being done the way it is being done.


### Core Data Notes

The CoreData model has only two entities named `Item` and `Location`, with every `Item` having a to-one relationship to a `Location` (the inverse is to-many).

* `Item`s have an id (UUID), a name, a quantity, a boolean that indicates whether the item is on the list for today's shopping exercise, or not on the list (and so available in the purchased list for future promotion to the shopping list), and also a boolean that provides an italic, strike-through appearance for the item when false (sometimes an item is on the list, but not available today, and I want to remember that when planning the future shopping list).  New to this project is the addition of a Date for an Item to keep track of when the Item was last purchased.

* `Location`s have an id (UUID), a name, a visitation order (an integer, as in, go to the dairy first, then the deli, then the canned vegetables, etc), and then values red, green, blue, opacity to define a color that is used to color every item listed in the shopping list. 

* Almost all of the attribute names for the `Item` and `Location` entities are different from before, and are "fronted" using (computed) variables in the Item and Location classes.  Example: the Item entity has a `name_` attribute (an *optional* String) in the Core Data model, but we define a set/get variable `name` in Item+Extensions.swift of type `String` to make it available to all code outside of the Core Data bubble, as it were, to read and write the name.  (Reading `name` does a nil-coalesce of the optional `name_` property of the Item class in Swift.)  You will read about this strategy of fronting Core Data attributes in code comments.

* This updated app has added a version 2 and then also a version 3 to the Core Data data model, to handle these renaming issues and to add a dateLastPurchased attribute to every Item. (It is a lightweight migration.)

### App Architecture

As I said above, this app started out as a few SwiftUI views driven by @FetchRequests, but that eventually ran into trouble when deleting Core Data objects.  For example, if a View has an @ObservedObject reference to a Core Data object and that object is deleted (while the view is still alive in SwiftUI), you could be in for some trouble.  And there are also timing issues in Core Data deletions: the in-memory object graph doesn't always get updated right away for delete operations, which means a SwiftUI view could be trying to reference something that doesn't really exist before the SwiftUI system actually learns about the deletion.

Next, I tried to insert a little Combine into the app (e.g., a view driven by a list of Locations would make the list a subscriber to each of the Locations in the list), but there were problems with that as well.  

I finally settled on more of an MVVM-style architecture, managing a list of Items or Locations myself, instead of letting @FetchRequest handle that list.  And I used internal notifications posted through the NotificationCenter that an `Item` or a `Location` had either been created, or edited, or was about to be deleted, so that view models could react appropriately.

That design worked in version 1.0 of ShoppingList ... and I liked it a lot, frankly ... but I decided that I should go back and revisit my avoidance of @FetchRequest.  

Unfortunately, what has always bothered me about the current state of SwiftUI view code that I see that uses @FetchRequest is that such a view often needs to understand that the data it processes come from Core Data.  The view must also know some of the gritty details of Core Data (e.g. @FetchRequests needed to know about sortDescriptors and keyPaths) and possibly know when to either nil-coalesce or at least test for nil values.

The design in this app now lives somewhere between MVVM and a basic, @FetchRequest-driven SwiftUI app structure.  My goal in reaching the current code structure was that all SwiftUI views should follow **these three rules**: 

* a View should never "really" know that its data comes from Core Data (*no use of Core Data keypaths or managedObjectContexts*);

* a View should never access or manipulate attributes of a CD object directly; and

* the associated "View.swift" file that defines the View should never have to  `import CoreData`.  

The code of this app **follows the three rules above**, and I think the result works quite well.



## License

* The app icon was created by Wes Breazell from [the Noun Project](https://thenounproject.com). 
* The extension I use on Bundle to load JSON files is due to Paul Hudson (@twostraws, [hackingwithswift.com](https://hackingwithswift.com)) 
* The MailView used in the ShoppingListView was created by [Mohammad Rahchamani](https://github.com/mohammad-rahchamani/MailView), copyright © 1399 AP BetterSleep.

Otherwise, just about all of the code is original, and it's yours if you want it -- please see LICENSE for the usual details and disclaimers.


## ChangeLog

This section will list changes made to ShoppingList15, from its initial release onward.

