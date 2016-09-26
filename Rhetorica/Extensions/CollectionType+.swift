//
//  CollectionType+.swift
//  Rhetorica
//
//  Created by Nick Podratz on 22.10.15.
//  Copyright © 2015 Nick Podratz. All rights reserved.
//

import Foundation

extension Collection where Index == Int {
    /// Return a copy of `self` with its elements shuffled
    func shuffled() -> [Iterator.Element] {
        var list = Array(self)
        list.shuffle()
        return list
    }
}

extension MutableCollection where Index == Int {
    /// Shuffle the elements of `self` in-place.
    mutating func shuffle() {
        // empty and single-element collections don't shuffle
        guard count >= 2 else { return }
        
        for i in 0..<endIndex {
            let j = Int(arc4random_uniform(UInt32(endIndex)))
            guard i != j else { continue }
            swap(&self[i], &self[j])
        }
    }
}
