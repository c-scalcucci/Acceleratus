//
//  Set+Extension.swift
//  
//
//  Created by Chris Scalcucci on 3/16/22.
//

import Foundation

public extension Set {
    /**
     Iterates over the specified collection, and adds
     each object returned by the interator.

     - parameter c: The collection of elements to add
     */
    @inlinable @discardableResult
    mutating func addAll<S>(_ elements: S?) -> Bool where S: Sequence, S.Element == Element {
        guard let elements = elements else { return false }
        let count = self.count
        self = self.union(elements)
        return self.count != count
    }

    @inlinable @discardableResult
    mutating func removeAll<S>(_ elements: S?) -> Bool where S: Sequence, S.Element == Element {
        guard let elements = elements else { return false }
        let count = self.count
        self = self.subtracting(elements)
        return self.count != count
    }
}
