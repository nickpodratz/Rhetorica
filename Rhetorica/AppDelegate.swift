//
//  AppDelegate.swift
//  Rhetorica
//
//  Created by Nick Podratz on 16.10.14.
//  Copyright (c) 2014 Nick Podratz. All rights reserved.
//

import UIKit
import CoreSpotlight
import MobileCoreServices

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate {

    // 1. iPhone: Cell shouldn't highlight
    // 2. Register in Table View
    // 3. UISearchController
    
    // - Zweck
    // - Quizmodus
    // - Design
    // - Wikipedia Link

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

        loadFavorites()
        DataManager.sharedInstance.indexAllStylisticDevicesIfPossible()
        let splitViewController = self.window!.rootViewController as! UISplitViewController
        let navigationController = splitViewController.viewControllers[splitViewController.viewControllers.count-1] as! UINavigationController
        navigationController.topViewController?.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem()
        splitViewController.delegate = self
        
        application.statusBarStyle = .LightContent
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func loadFavorites(){
        // TODO: Memory Leak with 4300 calls
        
        // Load Favourites
        if let loadedFavourites = NSUserDefaults.standardUserDefaults().valueForKey(DataManager.favorites.title) as? [String] {
            DataManager.favorites.elements = DataManager.allDevices.elements.filter{ element in
                loadedFavourites.contains(element.title)
            }
        }
    }
    
    func application(application: UIApplication, continueUserActivity userActivity: NSUserActivity, restorationHandler: ([AnyObject]?) -> Void) -> Bool {
        if #available(iOS 9.0, *) {
            if userActivity.activityType == CSSearchableItemActionType {
                if let uniqueIdentifier = userActivity.userInfo?[CSSearchableItemActivityIdentifier] as? String {
                    let splitViewController = self.window!.rootViewController as! UISplitViewController
                    let navigationController = splitViewController.viewControllers[splitViewController.viewControllers.count-1] as! UINavigationController
                    navigationController.popToRootViewControllerAnimated(false)
                    if let _ = navigationController.topViewController as? MasterViewController {
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let detailVC = storyboard.instantiateViewControllerWithIdentifier("DetailVC") as! DetailViewController
                        print(uniqueIdentifier)
                        detailVC.device = DataManager.allDevices.filter({return "\($0.title)" == uniqueIdentifier}).first
                        navigationController.pushViewController(detailVC, animated: false)
                    }
                }
            }
        }
        return true
    }

        
    // MARK: SplitViewController

    func splitViewController(svc: UISplitViewController, shouldHideViewController vc: UIViewController, inOrientation orientation: UIInterfaceOrientation) -> Bool {
        return false
    }
    
    func splitViewController(splitViewController: UISplitViewController, collapseSecondaryViewController secondaryViewController:UIViewController, ontoPrimaryViewController primaryViewController:UIViewController) -> Bool {
        if let secondaryAsNavController = secondaryViewController as? UINavigationController {
            if let topAsDetailController = secondaryAsNavController.topViewController as? DetailViewController {
                if topAsDetailController.device == nil {
                    // Return true to indicate that we have handled the collapse by doing nothing; the secondary controller will be discarded.
                    return true
                }
            }
        }
        return false
    }


}

