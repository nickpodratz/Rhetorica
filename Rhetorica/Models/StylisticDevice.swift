//
//  StylisticDevice.swift
//  Rhetorica
//
//  Created by Nick Podratz on 17.10.14.
//  Copyright (c) 2014 Nick Podratz. All rights reserved.
//

import Foundation
import CoreSpotlight
import MobileCoreServices


class StylisticDevice: NSObject {
    let language: Language
    let title: String
    let definition: String
    let examples: [String]
    let synonym: String?
    let wikipedia: String?
    let opposite: String?
    let levelOfImportance: Int
    
    init (language: Language, title: String, definition: String, examples: [String], synonym: String? = nil, wikipedia: String? = nil, opposite: String? = nil, levelOfImportance: Int = 0){
        self.language = language
        self.title = title
        self.definition = definition
        self.examples = examples
        self.synonym = synonym
        self.wikipedia = wikipedia
        self.opposite = opposite
        self.levelOfImportance = levelOfImportance
    }
}


// MARK: - StylisticDevice: CustomStringConvertible

extension StylisticDevice {
    override var description: String {
        return self.title
    }
}


// MARK: - StylisticDevice: Comparable

extension StylisticDevice: Comparable {}
func <(lhs: StylisticDevice, rhs: StylisticDevice) -> Bool {
    return lhs.title < rhs.title
}


// MARK: - StylisticDevice + Search For String

extension StylisticDevice {
    var searchableStrings: [String] {
        return [title, definition, examples.reduce("", combine: {$0 + $1}), synonym , wikipedia].flatMap {$0}
    }
}


// MARK: - StylisticDevice + Load from Plist

extension StylisticDevice {
    
    static func getDevicesFromPlistForLanguage(language: Language) -> [StylisticDevice] {
        var devices = [StylisticDevice]()
        if let path = NSBundle.mainBundle().pathForResource("stylisticDevices_\(language.identifier)", ofType: "plist"),
            dict = NSDictionary(contentsOfFile: path) {
                for (_, deviceDict) in dict {
                    let device = StylisticDevice(
                        language: language,
                        title: deviceDict.valueForKey("title") as! String,
                        definition: deviceDict.valueForKey("definition") as! String,
                        examples: deviceDict.valueForKey("examples") as! [String],
                        synonym: deviceDict.valueForKey("synonym") as! String?,
                        wikipedia: deviceDict.valueForKey("wikipedia") as! String?,
                        opposite: deviceDict.valueForKey("opposite") as! String?,
                        levelOfImportance: deviceDict.valueForKey("levelOfImportance") as! Int)
                    
                    devices.append(device)
                }
        }
        return devices
    }

    static func getDevicesFromPlistForLanguages(languages: [Language]) -> [StylisticDevice] {
        var allDevices = [StylisticDevice]()
        for language in languages {
            allDevices.appendContentsOf(StylisticDevice.getDevicesFromPlistForLanguage(language))
        }
        return allDevices
    }
}


// MARK: StylisticDevice + Indexing for System Search

extension StylisticDevice {
    
    
    static func indexAllIfPossible(devices: [StylisticDevice]) {
        if #available(iOS 9.0, *) {
            for device in devices {
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
