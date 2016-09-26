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
            let parameters = ["list": deviceList.title, "language": language.description, "score": score, "question_index": questionIndex] as [String : Any]
            FBSDKAppEvents.logEvent("Quiz Cancels", parameters: parameters as [AnyHashable: Any])
        }
    }

    static func quizModeDidFinish(forDeviceList deviceList: DeviceList, inLanguage language: Language, withScore score: Int) {
        if !isUITestMode {
            let parameters = ["list": deviceList.title, "language": language.description, "score": score] as [String : Any]
            FBSDKAppEvents.logEvent("Quiz Finishes", parameters: parameters as [AnyHashable: Any])
        }
    }

    
    // MARK: General
    
    static func currentDeviceListDidChange(_ deviceList: DeviceList, andLangugage language: Language) {
        if !isUITestMode {
            let parameters = ["list": deviceList.title, "language": language.description]
            FBSDKAppEvents.logEvent("Current Devicelist Changes", parameters: parameters as [AnyHashable: Any])
        }
    }
    
    
    // MARK: About Page
    
    static func aboutPageOpened() {
        if !isUITestMode {
            FBSDKAppEvents.logEvent("About Page Visits")
        }
    }
    
    static func detailsDidShowUpForApp(_ appTitle: String) {
        if !isUITestMode {
            let parameters = ["app": appTitle]
            FBSDKAppEvents.logEvent("About Page: App Previews", parameters: parameters as [AnyHashable: Any])
        }
    }
    
    static func myWebsiteVisitedFromAboutPage() {
        if !isUITestMode {
            FBSDKAppEvents.logEvent("About Page: My Website Visits")
        }
    }
    
    static func twitterPageDidOpenFromAboutPage() {
        if !isUITestMode {
            FBSDKAppEvents.logEvent("About Page: Twitter Page Visits")
        }
    }

    
    
    
    // MARK: Feedback
    
    static func feedbackDidReceiveUserResponse(_ response: Bool) {
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

    static func learningListModified(_ device: StylisticDevice, addedDevice added: Bool) {
        if !isUITestMode {
            let modificationString = added ? "added" : "removed"
            let parameters = ["device": device.title, "language": device.language.description, "modification": modificationString]
            FBSDKAppEvents.logEvent("Learninglist Modifications", parameters: parameters as [AnyHashable: Any])
        }
    }

    static func wikipediaForDeviceDidOpen(_ device: StylisticDevice) {
        if !isUITestMode {
            let parameters = ["device": device.title, "language": device.language.description]
            FBSDKAppEvents.logEvent("Wikipedia Visits", parameters: parameters as [AnyHashable: Any])
        }
    }

    static func detailsForDeviceDidOpen(_ device: StylisticDevice) {
        if !isUITestMode {
            let parameters = ["device": device.title, "language": device.language.description]
            FBSDKAppEvents.logEvent("Detail Visits", parameters: parameters as [AnyHashable: Any])
        }
    }

}
