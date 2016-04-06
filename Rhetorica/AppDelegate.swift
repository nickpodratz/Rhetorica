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

let appId = "926449450"
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        let splitViewController = self.window!.rootViewController as! UISplitViewController
        let navigationController = splitViewController.viewControllers[splitViewController.viewControllers.count-1] as! UINavigationController
        navigationController.topViewController?.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem()
        splitViewController.delegate = self
        
        application.setStatusBarStyle(UIStatusBarStyle.LightContent, animated: false)
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
    
    @available(iOS 9.0, *)
    func application(application: UIApplication, performActionForShortcutItem shortcutItem: UIApplicationShortcutItem, completionHandler: (Bool) -> Void) {
        let splitVC = self.window!.rootViewController as! UISplitViewController
        let firstNavigationVC = splitVC.viewControllers.first as! UINavigationController
        let masterVC = firstNavigationVC.viewControllers.first as! MasterViewController

        switch shortcutItem.type.componentsSeparatedByString(".").last! {
        case "showFavorites":
            masterVC.selectedDeviceList = masterVC.deviceLists.last!
            masterVC.searchController.searchBar.resignFirstResponder()
            
        case "searchForStylisticDevice":
            masterVC.selectedDeviceList = masterVC.deviceLists[2]
            masterVC.searchController.active = true
            NSTimer.scheduledTimerWithTimeInterval(0.1, target: masterVC.searchController.searchBar, selector: "becomeFirstResponder", userInfo: nil, repeats: false)
            
        case "playQuiz":
            masterVC.performSegueWithIdentifier("showQuiz", sender: masterVC)
            
        default: ()
        }
        // Handle quick actions
        //        completionHandler(handleQuickAction(shortcutItem))
        
    }
    
    
    func application(application: UIApplication, continueUserActivity userActivity: NSUserActivity, restorationHandler: ([AnyObject]?) -> Void) -> Bool {
        // Searching from system search
        if #available(iOS 9.0, *) {
            guard userActivity.activityType == CSSearchableItemActionType else { return true }
            if let uniqueIdentifier = userActivity.userInfo?[CSSearchableItemActivityIdentifier] as? String {
                let device = StylisticDevice.getDevicesFromPlistForLanguages(Language.allLanguages).filter{return "\($0.title)" == uniqueIdentifier}.first
                let splitVC = self.window!.rootViewController as! UISplitViewController
                let firstNavigationVC = splitVC.viewControllers.first as! UINavigationController
                let masterVC = firstNavigationVC.viewControllers.first as! MasterViewController
                
                if device != nil {
                    masterVC.selectedLanguage = device!.language
                    Language.setSelectedLanguage(device!.language)
                    // Dismiss Quiz or List-VC
                    masterVC.presentedViewController?.dismissViewControllerAnimated(true, completion: nil)
                    if firstNavigationVC.viewControllers.count > 1 {
                        // Called on iPhone
                        let secondNavigationVC = firstNavigationVC.viewControllers[1] as! UINavigationController
                        let detailVC = secondNavigationVC.viewControllers.first as! DetailViewController
                        detailVC.device = device
                        detailVC.favorites = masterVC.favorites
                        secondNavigationVC.popToViewController(detailVC, animated: false)
                    } else {
                        // Called on iPad
                        // TODO: Handle open Quiz
                        //                    navigationController.visibleViewController?.dismissViewControllerAnimated(false, completion: nil)
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let detailNavigationVC = storyboard.instantiateViewControllerWithIdentifier("DetailNavigationVC") as! UINavigationController
                        let detailVC = detailNavigationVC.visibleViewController as! DetailViewController
                        detailVC.device = device
                        detailVC.favorites = masterVC.favorites
                        splitVC.showDetailViewController(detailNavigationVC, sender: self)
                    }
                }
            }
        }
        return true
    }
    
}


// MARK: AppDelegate: UISplitViewControllerDelegate

extension AppDelegate: UISplitViewControllerDelegate {
    
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