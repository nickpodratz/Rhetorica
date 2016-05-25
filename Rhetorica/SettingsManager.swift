//
//  SettingsManager.swift
//  Tapasi
//
//  Created by Nick Podratz on 24.05.16.
//  Copyright © 2016 Nick Podratz. All rights reserved.
//

import Foundation

struct Link {
    let title: String
    let urlString: String
    var url: NSURL? {
        return NSURL(string: urlString)
    }
}


/// A wrapper for the app's settings. Access the properties through the sharedInstance singleton property.
class SettingsManager {
    
    private init(){}
    private let userDefaults = NSUserDefaults.standardUserDefaults()
    
    /// The singleton for this class.
    let sharedInstance = SettingsManager()
    
    let supportEmail = "nick.podratz.support@icloud.com"
    let websiteURL = "podratz.de"
    var licenseAgreementURL = "podratz.de"
    
    var thirdPartyFrameworks: [Link] = {
        guard let path = NSBundle.mainBundle().pathForResource("Assets/ThirdPartyFrameworks", ofType: "plist"),
            frameworkDict = NSDictionary(contentsOfFile: path) as? [String: String] else {
                print("Can't find ThirdPartyFrameworks file.")
                return []
        }
        
        let frameworkLinks = frameworkDict.map { (title, urlString) in
            return Link(title: title, urlString: urlString)
        }
        
        return frameworkLinks
    }()
    
    
    // MARK: Settings
    
    private let savesImagesAfterCreationKey = "savesImagesAfterCreationKey"
    var savesImagesAfterCreation: Bool {
        get {
            return userDefaults.boolForKey(savesImagesAfterCreationKey)
        }
        set {
            userDefaults.setBool(newValue, forKey: savesImagesAfterCreationKey)
        }
    }
    
    private let requestsTouchIdKey = "requestsTouchIdKey"
    var requestsTouchId: Bool {
        get {
            return userDefaults.boolForKey(requestsTouchIdKey)
        }
        set {
            userDefaults.setBool(newValue, forKey: requestsTouchIdKey)
        }
    }
}