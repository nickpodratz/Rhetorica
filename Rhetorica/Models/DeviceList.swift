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
            let backgroundQueue = DispatchQueue.global(qos: DispatchQoS.QoSClass.background)
            if self.editable {
                backgroundQueue.async {
                    // Save Elementlist under title
                    let listOfFavouriteStrings = newValue.map{$0.title}
                    UserDefaults.standard.setValue(listOfFavouriteStrings, forKey: "\(self.language.identifier)_favorites"
                    )
                    UserDefaults.standard.synchronize()
                }
            }
        }
        didSet {
            elements.sort(by: <)
            if oldValue.count < elements.count {
                // Device was added
                let devices = elements.filter{!oldValue.contains($0)}
                for device in devices {
                    FacebookLogger.learningListModified(device, addedDevice: true)
                }
            } else {
                // Device was deleted
                let devices = oldValue.filter{!elements.contains($0)}
                for device in devices {
                    FacebookLogger.learningListModified(device, addedDevice: false)
                }
            }
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
        self.elements = elements.sorted()
    }
}


// MARK: DeviceList: Sequence Type

extension DeviceList: Sequence {
    typealias Iterator = DeviceIterator

    func makeIterator() -> DeviceIterator {
        return DeviceIterator(self)
    }
    
    struct DeviceIterator: IteratorProtocol {
        let deviceList: DeviceList
        var index: Int = 0
        
        init(_ deviceList: DeviceList) {
            self.deviceList = deviceList
        }
        
        mutating func next() -> StylisticDevice? {
            let maxIndex = deviceList.elements.isEmpty ? 0 : deviceList.elements.count - 1
            if let nextIndex = deviceList.elements.index(deviceList.startIndex, offsetBy: index + 1, limitedBy: maxIndex) {
                index = nextIndex
                return deviceList.elements[index]
            }
            return nil
        }
    }
}


// MARK: DeviceList: Collection Type

extension DeviceList: Collection {
    /// Returns the position immediately after the given index.
    ///
    /// - Parameter i: A valid index of the collection. `i` must be less than
    ///   `endIndex`.
    /// - Returns: The index value immediately after `i`.
    public func index(after i: Int) -> Int {
        return i + 1
    }

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
        let elementString = elements.map{$0.title}.joined(separator: ", ")
        return "\(self.title): " + elementString
    }
}


// MARK: DeviceList: Equatable

func ==(lhs:DeviceList, rhs:DeviceList) -> Bool {
    return (lhs.hash == rhs.hash)
}


// MARK: DeviceList: Comparable

extension DeviceList: Comparable {}
func <(lhs:DeviceList, rhs:DeviceList) -> Bool {
    return (lhs.title < rhs.title)
}

func ~=(pattern: DeviceList, x: DeviceList) -> Bool {
    return pattern.hash == x.hash
}


// MARK: DeviceList + Default Instances

extension DeviceList {
        
    static func getAllDeviceLists(_ allDevices: [StylisticDevice], forLanguage language: Language) -> [DeviceList] {
        let favoritesKey = "\(language.identifier)_favorites"
        
        /// A mutable collection of the user's favored Stylistic Devices.
        let favoritesList = DeviceList(
            language: language,
            title: NSLocalizedString("lernliste", comment: ""),
            editable: true,
            elements: {
                // Load Favourites
                if let loadedFavourites = UserDefaults.standard.value(forKey: favoritesKey) as? [String] {
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
    fileprivate static var selectedListTitleKey = "selected_list_title"
    
    /// - Returns: The title of the selected list if it was set or nil.
    static func getSelectedListTitle() -> String? {
        return UserDefaults.standard.string(forKey: selectedListTitleKey)
    }
    
    /// Saves the title of the selected List to the user defaults for later retrieval.
    static func setSelectedListTitle(_ title: String) {
        let defaults = UserDefaults.standard
        
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
