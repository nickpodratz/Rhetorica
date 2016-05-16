//
//  FacebookLogger.swift
//  Rhetorica
//
//  Created by Nick Podratz on 16.05.16.
//  Copyright © 2016 Nick Podratz. All rights reserved.
//

import Foundation
import FBSDKCoreKit
import Bolts

class FacebookLogger {
    
    
    // MARK: Quizmode
    
    static func quizModeDidStart(forDeviceList deviceList: DeviceList, inLanguage language: Language) {
        if !isUITestMode {
            let parameters = ["list": deviceList.title, "language": language.description]
            FBSDKAppEvents.logEvent("Quiz Starts", parameters: parameters)
        }
    }
    
    static func quizModeDidCancel(forDeviceList deviceList: DeviceList, inLanguage language: Language, withScore score: Int, atQuestion questionIndex: Int) {
        if !isUITestMode {
            let parameters = ["list": deviceList.title, "language": language.description, "score": score, "question_index": questionIndex]
            FBSDKAppEvents.logEvent("Quiz Cancels", parameters: parameters as [NSObject : AnyObject])
        }
    }

    static func quizModeDidFinish(forDeviceList deviceList: DeviceList, inLanguage language: Language, withScore score: Int) {
        if !isUITestMode {
            let parameters = ["list": deviceList.title, "language": language.description, "score": score]
            FBSDKAppEvents.logEvent("Quiz Finishes", parameters: parameters as [NSObject : AnyObject])
        }
    }

    
    // MARK: General
    
    static func currentDeviceListDidChange(deviceList: DeviceList, andLangugage language: Language) {
        if !isUITestMode {
            let parameters = ["list": deviceList.title, "language": language.description]
            FBSDKAppEvents.logEvent("Current Devicelist Changes", parameters: parameters as [NSObject : AnyObject])
        }
    }
    
    
    // MARK: About Page
    
    static func aboutPageOpened() {
        if !isUITestMode {
            FBSDKAppEvents.logEvent("About Page Visits")
        }
    }
    
    static func detailsDidShowUpForApp(appTitle: String) {
        if !isUITestMode {
            let parameters = ["app": appTitle]
            FBSDKAppEvents.logEvent("About Page: App Previews", parameters: parameters as [NSObject : AnyObject])
        }
    }
    
    static func myWebsiteVisitedFromAboutPage() {
        if !isUITestMode {
            FBSDKAppEvents.logEvent("About Page: My Website Visits")
        }
    }
    
    static func facebookPageDidOpenFromAboutPage() {
        if !isUITestMode {
            FBSDKAppEvents.logEvent("About Page: FB Page Visits")
        }
    }
    
    
    
    
    // MARK: Feedback
    
    static func feedbackDidReceiveUserResponse(response: Bool) {
        if !isUITestMode {
            let parameters = ["positive": response]
            FBSDKAppEvents.logEvent("Feedback: General Responses", parameters: parameters)
        }
    }

    static func appStoreDidOpenFromFeedback() {
        if !isUITestMode {
            FBSDKAppEvents.logEvent("Feedback: App Store Visits")
        }
    }
    
    static func likeFBPagePressedFromFeedback() {
        if !isUITestMode {
            FBSDKAppEvents.logEvent("Feedback: Like Presses")
        }
    }

    
    
    // MARK: Stylistic Device Tracking

    static func learningListModified(device: StylisticDevice, addedDevice added: Bool) {
        if !isUITestMode {
            let modificationString = added ? "added" : "removed"
            let parameters = ["device": device.title, "language": device.language.description, "modification": modificationString]
            FBSDKAppEvents.logEvent("Learninglist Modifications", parameters: parameters as [NSObject : AnyObject])
        }
    }

    static func wikipediaForDeviceDidOpen(device: StylisticDevice) {
        if !isUITestMode {
            let parameters = ["device": device.title, "language": device.language.description]
            FBSDKAppEvents.logEvent("Wikipedia Visits", parameters: parameters as [NSObject : AnyObject])
        }
    }

    static func detailsForDeviceDidOpen(device: StylisticDevice) {
        if !isUITestMode {
            let parameters = ["device": device.title, "language": device.language.description]
            FBSDKAppEvents.logEvent("Detail Visits", parameters: parameters as [NSObject : AnyObject])
        }
    }

}