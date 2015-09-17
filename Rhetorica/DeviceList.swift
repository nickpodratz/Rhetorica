//
//  DeviceList.swift
//  Rhetorica
//
//  Created by Nick Podratz on 05.07.15.
//  Copyright (c) 2015 Nick Podratz. All rights reserved.
//

import Foundation

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
    
    var enoughForCategories: Bool { return elements.count > 30 }
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
    
    
    init(title: String, editable: Bool, elements: [StylisticDevice]) {
        self.title = title
        self.editable = editable
        self.elements = elements
    }
}

// ------------------------------------------------------------------------
// MARK: - Protocol Conformance
// ------------------------------------------------------------------------

func ~=(pattern: DeviceList, x: DeviceList) -> Bool {
    return pattern.title == x.title
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



