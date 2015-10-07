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
    let examples: [String]
    let synonym: String?
    let wikipedia: String?
    let opposite: String?
    
    init (title: String, definition: String, examples: [String], synonym: String? = nil, wikipedia: String? = nil, opposite: String? = nil){
        self.title = title
        self.definition = definition
        self.examples = examples
        self.synonym = synonym
        self.wikipedia = wikipedia
        self.opposite = opposite
    }
}

extension StylisticDevice {
    var searchableStrings: [String] {
//        return [title, definition, example, synonym , wikipedia].flatMap {$0}
        return [title, definition, examples.reduce("", combine: {$0 + $1}), synonym, wikipedia].filter{$0 != nil}.map{$0!}
    }
}

extension StylisticDevice: CustomStringConvertible {
    var description: String {
        return self.title
    }
}

extension StylisticDevice: Hashable {
    var hashValue: Int {
        return title.utf16.count
    }
}

extension StylisticDevice: Equatable{}
func ==(lhs: StylisticDevice, rhs: StylisticDevice) -> Bool {
    return lhs.title == rhs.title && lhs.definition == rhs.definition && lhs.examples == rhs.examples
}

extension StylisticDevice: Comparable {}
func <(lhs: StylisticDevice, rhs: StylisticDevice) -> Bool {
    return lhs.title < rhs.title
}
