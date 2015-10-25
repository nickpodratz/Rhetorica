//
//  DeviceList.swift
//  Rhetorica
//
//  Created by Nick Podratz on 05.07.15.
//  Copyright (c) 2015 Nick Podratz. All rights reserved.
//

import Foundation

let latinAlphabet = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]

class DeviceList: NSObject {
    let title: String
    let editable: Bool
    var elements: [StylisticDevice] {
        willSet{
            if enoughForCategories {
                presentLetters = latinAlphabet.filter{self.sortedList[$0] != nil}
            }
            
            let backgroundQueue = dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0)
            dispatch_async(backgroundQueue) {
                // Save Elementlist under title
                let listOfFavouriteStrings = newValue.map{$0.title}
                NSUserDefaults.standardUserDefaults().setValue(listOfFavouriteStrings, forKey: self.title)
                NSUserDefaults.standardUserDefaults().synchronize()
            }
        }
        didSet {
            elements.sortInPlace(<)
        }
    }
    
    lazy var presentLetters: [String] = latinAlphabet.filter{self.sortedList[$0] != nil}
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
    
    init(title: String, editable: Bool, elements: [StylisticDevice]) {
        self.title = title
        self.editable = editable
        self.elements = elements
    }
}


// MARK: Sequence Type
extension DeviceList: SequenceType {
    typealias Generator = AnyGenerator<StylisticDevice>
    
    func generate() -> Generator {
        var index = 0
        return anyGenerator {
            if index < self.elements.count {
                return self.elements[index++]
            }
            return nil
        }
    }
}

// MARK: Collection Type
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

// MARK: CustomStringConvertible
extension DeviceList {
    override var description: String {
        let elementString = elements.map{$0.title}.joinWithSeparator(", ")
        return "\(self.title): " + elementString
    }
}

// MARK: Equatable
func ==(lhs:DeviceList, rhs:DeviceList) -> Bool {
    return (lhs.title == rhs.title)
}

func !=(lhs:DeviceList, rhs:DeviceList) -> Bool {
    return !(lhs.title == rhs.title)
}

func ~=(pattern: DeviceList, x: DeviceList) -> Bool {
    return pattern.title == x.title
}


extension DeviceList {
    
    @nonobjc static var allDeviceLists = [DeviceList.fewDevices, DeviceList.someDevices, DeviceList.allDevices, DeviceList.favorites]
    
    
    /// A mutable collection of the user's favored Stylistic Devices.
    @nonobjc static var favorites = DeviceList(
        title: "Lernliste",
        editable: true,
        elements: {
            // Load Favourites
            if let loadedFavourites = NSUserDefaults.standardUserDefaults().valueForKey("Lernliste") as? [String] {
                return allStylisticDevices.filter{ element in
                    loadedFavourites.contains(element.title)
                }
            }
            return [StylisticDevice]()
        }()
    )
    
    @nonobjc static let fewDevices = DeviceList(title: "Wichtigste Stilmittel", editable: false,
        elements: allStylisticDevices.filter { device in
            return device.levelOfImportance >= 7
        }
    )

    @nonobjc static let someDevices = DeviceList(title: "Einige Stilmittel", editable: false,
        elements: allStylisticDevices.filter{ device in
            return device.levelOfImportance >= 4
        }
    )
    
    /// An immutable collection of all Stylistic Devices.
    @nonobjc static let allDevices = DeviceList(title: "Alle Stilmittel", editable: false, elements: allStylisticDevices)
    
}
