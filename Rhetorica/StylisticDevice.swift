//
//  StylisticDevice.swift
//  Rhetorica
//
//  Created by Nick Podratz on 17.10.14.
//  Copyright (c) 2014 Nick Podratz. All rights reserved.
//

import Foundation

var allStylisticDevices = StylisticDevice.getAllDevicesFromPlist()


class StylisticDevice: NSObject {
    let title: String
    let definition: String
    let examples: [String]
    let synonym: String?
    let wikipedia: String?
    let opposite: String?
    let levelOfImportance: Int
    
    init (title: String, definition: String, examples: [String], synonym: String? = nil, wikipedia: String? = nil, opposite: String? = nil, levelOfImportance: Int = 0){
        self.title = title
        self.definition = definition
        self.examples = examples
        self.synonym = synonym
        self.wikipedia = wikipedia
        self.opposite = opposite
        self.levelOfImportance = levelOfImportance
    }
}

extension StylisticDevice {
    var searchableStrings: [String] {
        return [title, definition, examples.reduce("", combine: {$0 + $1}), synonym , wikipedia].flatMap {$0}
    }
}

extension StylisticDevice {
    override var description: String {
        return self.title
    }
}

extension StylisticDevice: Comparable {}
func <(lhs: StylisticDevice, rhs: StylisticDevice) -> Bool {
    return lhs.title < rhs.title
}

extension StylisticDevice {
    static func getAllDevicesFromPlist() -> [StylisticDevice] {
        var devices = [StylisticDevice]()
        let languageId = NSBundle.mainBundle().preferredLocalizations.first!

        if let path = NSBundle.mainBundle().pathForResource("stylisticDevices_\(languageId)", ofType: "plist"),
            dict = NSDictionary(contentsOfFile: path) {
                for (_, deviceDict) in dict {
                    let device = StylisticDevice(
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

}