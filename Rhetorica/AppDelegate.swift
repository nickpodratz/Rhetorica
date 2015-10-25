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
let masterVCLoadingCounterKey = "MASTERVIEWCONTROLLERLOADINGKEY"
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
        let splitViewController = self.window!.rootViewController as! UISplitViewController
        let navigationController = splitViewController.viewControllers[splitViewController.viewControllers.count-1] as! UINavigationController
        navigationController.topViewController?.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem()
        splitViewController.delegate = self
        
        indexAllStylisticDevicesIfPossible()
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
    
    // Searching from system search
    func application(application: UIApplication, continueUserActivity userActivity: NSUserActivity, restorationHandler: ([AnyObject]?) -> Void) -> Bool {
        if #available(iOS 9.0, *) {
            print("called!")
            guard userActivity.activityType == CSSearchableItemActionType else { return true }
            if let uniqueIdentifier = userActivity.userInfo?[CSSearchableItemActivityIdentifier] as? String {
                let device = allStylisticDevices.filter{return "\($0.title)" == uniqueIdentifier}.first
                let splitVC = self.window!.rootViewController as! UISplitViewController
                let firstNavigationVC = splitVC.viewControllers.first as! UINavigationController
                let masterVC = firstNavigationVC.viewControllers.first as! MasterViewController
                
                // Dismiss Quiz or List-VC
                masterVC.presentedViewController?.dismissViewControllerAnimated(true, completion: nil)
                if firstNavigationVC.viewControllers.count > 1 {
                    // Called on iPhone
                    let secondNavigationVC = firstNavigationVC.viewControllers[1] as! UINavigationController
                    let detailVC = secondNavigationVC.viewControllers.first as! DetailViewController
                    secondNavigationVC.popToViewController(detailVC, animated: false)
                    detailVC.device = device
                } else {
                    // Called on iPad
                    // TODO: Handle open Quiz
                    //                    navigationController.visibleViewController?.dismissViewControllerAnimated(false, completion: nil)
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let detailNavigationVC = storyboard.instantiateViewControllerWithIdentifier("DetailNavigationVC") as! UINavigationController
                    let detailVC = detailNavigationVC.visibleViewController as! DetailViewController
                    detailVC.device = device
                    splitVC.showDetailViewController(detailNavigationVC, sender: self)
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
    
    func indexAllStylisticDevicesIfPossible() {
        let deviceList = allStylisticDevices
        
        if #available(iOS 9.0, *) {
            for device in deviceList {
                let attributeSet = CSSearchableItemAttributeSet(itemContentType: kUTTypeText as String)
                attributeSet.title = device.title
                attributeSet.contentDescription = device.definition
                let item = CSSearchableItem(uniqueIdentifier: "\(device.title)", domainIdentifier: "np.rhetorica", attributeSet: attributeSet)
                CSSearchableIndex.defaultSearchableIndex().indexSearchableItems([item]) { (error: NSError?) -> Void in
                    if let error = error {
                        print("Indexing error: \(error.localizedDescription)")
                    }
                }
            }
        } else {
            print("Could not index stylistic devices on device, as its OS is too old.")
        }
    }


}

