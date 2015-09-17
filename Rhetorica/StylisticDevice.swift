//
//  StylisticDevice.swift
//  Rhetorica
//
//  Created by Nick Podratz on 17.10.14.
//  Copyright (c) 2014 Nick Podratz. All rights reserved.
//

import Foundation

// TODO: Final class?
class StylisticDevice {
    let title: String
    let definition: String
    let example: String
    let synonym: String?
    let wikipedia: String?
    
    init (title: String, definition: String, example: String, synonym: String? = nil, wikipedia: String? = nil){
        self.title = title
        self.definition = definition
        self.example = example
        self.synonym = synonym
        self.wikipedia = wikipedia
    }
}

extension StylisticDevice {
    var searchableStrings: [String] {
// SWIFT 2:       return [title, definition, example, synonym , wikipedia].flatMap {$0}
        return [title, definition, example, synonym , wikipedia].filter{$0 != nil}.map{$0!}
    }
}

extension StylisticDevice: Printable {
    var description: String {
        return self.title
    }
}

extension StylisticDevice: Hashable {
    var hashValue: Int {
        return count(title.utf16)
    }
}

extension StylisticDevice: Equatable{}
func ==(lhs: StylisticDevice, rhs: StylisticDevice) -> Bool {
    return lhs.title == rhs.title && lhs.definition == rhs.definition && lhs.example == rhs.example
}

extension StylisticDevice: Comparable {}
func <(lhs: StylisticDevice, rhs: StylisticDevice) -> Bool {
    return lhs.title < rhs.title
}
