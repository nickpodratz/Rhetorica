//
//  DeviceList.swift
//  Rhetorica
//
//  Created by Nick Podratz on 05.07.15.
//  Copyright (c) 2015 Nick Podratz. All rights reserved.
//

import Foundation


class DeviceList: NSObject {
    let language: Language
    let title: String
    let editable: Bool
    var elements: [StylisticDevice] {
        willSet{
            if enoughForCategories {
                presentLetters = Language.latinAlphabet.filter{self.sortedList[$0] != nil}
            }
            let backgroundQueue = dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0)
            if self.editable {
                dispatch_async(backgroundQueue) {
                    // Save Elementlist under title
                    let listOfFavouriteStrings = newValue.map{$0.title}
                    NSUserDefaults.standardUserDefaults().setValue(listOfFavouriteStrings, forKey: "\(self.language.identifier)_favorites"
                    )
                    NSUserDefaults.standardUserDefaults().synchronize()
                }
            }
        }
        didSet {
            elements.sortInPlace(<)
        }
    }
    lazy var presentLetters: [String] = Language.latinAlphabet.filter{self.sortedList[$0] != nil}
    lazy var sortedList: [String: [StylisticDevice]] = {
        var returnList = [String: [StylisticDevice]]()
        for element in self.elements {
            let firstCharacterOfElement = String(element.title.characters.first!)
            
            if returnList[firstCharacterOfElement] != nil {
                returnList[firstCharacterOfElement]?.append(element)
            } else {
                returnList[firstCharacterOfElement] = [element]
            }
        }
        return returnList
    }()
    
    var enoughForCategories: Bool { return elements.count > 30 }
    
    init(language: Language, title: String, editable: Bool, elements: [StylisticDevice]) {
        self.language = language
        self.title = title
        self.editable = editable
        self.elements = elements.sort()
    }
}


// MARK: DeviceList: Sequence Type

extension DeviceList: SequenceType {
    typealias Generator = AnyGenerator<StylisticDevice>
    
    func generate() -> Generator {
        let index = 0
        return AnyGenerator {
            if index < self.elements.count {
                return self.elements[index.successor()]
            }
            return nil
        }
    }
}


// MARK: DeviceList: Collection Type

extension DeviceList: CollectionType {
    typealias Index = Int
    
    var startIndex: Int {
        return 0
    }
    
    var endIndex: Int {
        return elements.count
    }
    
    subscript(i: Int) -> StylisticDevice {
        return elements[i]
    }
}


// MARK: DeviceList: CustomStringConvertible

extension DeviceList {
    override var description: String {
        let elementString = elements.map{$0.title}.joinWithSeparator(", ")
        return "\(self.title): " + elementString
    }
}


// MARK: DeviceList: Equatable

func ==(lhs:DeviceList, rhs:DeviceList) -> Bool {
    return (lhs.title == rhs.title)
}


// MARK: DeviceList: Comparable

extension DeviceList: Comparable {}
func <(lhs:DeviceList, rhs:DeviceList) -> Bool {
    return (lhs.title < rhs.title)
}

func ~=(pattern: DeviceList, x: DeviceList) -> Bool {
    return pattern.title == x.title
}


// MARK: DeviceList + Default Instances

extension DeviceList {
        
    static func getAllDeviceLists(allDevices: [StylisticDevice], forLanguage language: Language) -> [DeviceList] {
        let favoritesKey = "\(language.identifier)_favorites"
        
        /// A mutable collection of the user's favored Stylistic Devices.
        let favoritesList = DeviceList(
            language: language,
            title: NSLocalizedString("lernliste", comment: ""),
            editable: true,
            elements: {
                // Load Favourites
                if let loadedFavourites = NSUserDefaults.standardUserDefaults().valueForKey(favoritesKey) as? [String] {
                    return allDevices.filter{ element in
                        loadedFavourites.contains(element.title)
                    }
                } else {
                    return [StylisticDevice]()
                }
            }()
        )
        
        let fewDevicesList = DeviceList(language: language, title: NSLocalizedString("wichtigste_stilmittel", comment: ""), editable: false,
            elements: allDevices.filter { device in
                return device.levelOfImportance >= 7
            }
        )
        
        let someDevicesList = DeviceList(language: language, title: NSLocalizedString("einige_stilmittel", comment: ""), editable: false,
            elements: allDevices.filter{ device in
                return device.levelOfImportance >= 4
            }
        )
        
        /// An immutable collection of all Stylistic Devices.
        let allDevicesList = DeviceList(language: language, title: NSLocalizedString("alle_Stilmittel", comment: ""), editable: false, elements: allDevices)
        
        return [fewDevicesList, someDevicesList, allDevicesList, favoritesList]
    }
    
}


// MARK: - DeviceList + Persistence of selected list

extension DeviceList {
    
    // NSLocalizedString("gewählte_liste", comment: "")
    
    /// The key under which the title of the selected list is saved.
    private static var selectedListTitleKey = "selected_list_title"
    
    /// - Returns: The title of the selected list if it was set or nil.
    static func getSelectedListTitle() -> String? {
        return NSUserDefaults.standardUserDefaults().stringForKey(selectedListTitleKey)
    }
    
    /// Saves the title of the selected List to the user defaults for later retrieval.
    static func setSelectedListTitle(title: String) {
        let defaults = NSUserDefaults.standardUserDefaults()
        
        defaults.setValue(title, forKey: selectedListTitleKey)
        defaults.synchronize()
    }
}


// MARK: DeviceList + Random Device

extension DeviceList {
    /** - returns: A random Device from the 'devices' array. */
    func getRandomDevice() -> StylisticDevice {
        let randomNumber = Int(arc4random_uniform(UInt32(self.elements.count)))
        return self.elements[randomNumber]
    }
}