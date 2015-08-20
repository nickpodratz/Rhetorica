//
//  DeviceList.swift
//  Rhetorica
//
//  Created by Nick Podratz on 05.07.15.
//  Copyright (c) 2015 Nick Podratz. All rights reserved.
//

import Foundation

final class DeviceList {
    let title: String
    let editable: Bool
    var elements: [StylisticDevice] {
        willSet{
            if enoughForCategories {
                presentLetters = latinAlphabet.filter{self.sortedList[$0] != nil}
            }
            // Save Elementlist under title
            let listOfFavouriteStrings = newValue.map{$0.title}
            NSUserDefaults.standardUserDefaults().setValue(listOfFavouriteStrings, forKey: title)
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
    
    var enoughForCategories: Bool { return elements.count > 30 }
    lazy var presentLetters: [String] = latinAlphabet.filter{self.sortedList[$0] != nil}
    lazy var sortedList: [String: [StylisticDevice]] = {
        var returnList = [String: [StylisticDevice]]()
        for element in self.elements {
            let firstCharacterOfElement = String(first(element.title)!)
            
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

// MARK: Sequence Type
extension DeviceList: SequenceType {
    typealias Generator = GeneratorOf<StylisticDevice>
    
    func generate() -> Generator {
        var index = 0
        return GeneratorOf {
            if index < self.elements.count {
                return self.elements[index++]
            }
            return nil
        }
    }
}

// MARK: Collection Type
extension DeviceList: CollectionType {
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

// MARK: Printable
extension DeviceList: Printable {
    var description: String {
        let elementString = join(", ", elements.map{$0.title})
        return "\(self.title): " + elementString
    }
}

// MARK: Equatable
extension DeviceList: Equatable{}
func ==(lhs:DeviceList, rhs:DeviceList) -> Bool {
    return (lhs.title == rhs.title)
}

func !=(lhs:DeviceList, rhs:DeviceList) -> Bool {
    return !(lhs.title == rhs.title)
}



