//
//  Dictionary+Extension.swift
//  
//
//  Created by Chris Scalcucci on 3/16/22.
//

import Foundation

public extension Dictionary {
    @inlinable
    var keyArray : [Self.Key] {
        return Array(self.keys)
    }

    @inlinable
    var valueArray : [Self.Value] {
        return Array(self.values)
    }

    /**
     Associates the specified value with the specified key in this map.

     If the map previously contained a mapping for the key, the old value
     is replaced by the specified value.

     - parameter key: Key with which the specified value is to be associated
     - parameter value: Value to be associated with the specified key
     - returns: The previous value if there is one, nil if there was none
     */
    @inlinable @discardableResult
    mutating func put(_ value: Self.Value, for key: Self.Key) -> Self.Value? {
        let tmp : Self.Value? = self[key]
        self[key] = value
        return tmp
    }

    func mapValues<T>(_ transform: (Value) throws -> T) rethrows -> Dictionary<Key,T> {
        return Dictionary<Key,T>(uniqueKeysWithValues: zip(self.keys, try self.values.map(transform)))
    }

    func mapKeys<T: Hashable>(_ transform:(Key) throws -> T) rethrows -> Dictionary<T, Value> {
        return Dictionary<T,Value>(uniqueKeysWithValues: zip(try self.keys.map(transform), self.values))
    }

    /**
     Attempts to fetch an element at the target key, if
     there is no present value, runs the provided function
     and associated the generated value with that key

     NOTE: If a value exists, fn does NOT run

     - parameter key: The key to search against
     - parameter fn: A function that generates a value to be placed
     - returns: The generated value, or the original value if found
     */
    @inlinable @discardableResult
    mutating func computeIfAbsent(_ key: Key, _ fn: () -> (Value)) -> Value {
        if let element = self[key] {
            return element
        } else {
            let element = fn()
            self[key] = element
            return element
        }
    }

    @inlinable
    func compact<K: Hashable, V>(_ fn: (Key, Value) -> (K,V)?) -> [K:V] {
        var transformed : [K:V] = [:]
        // Iterates the map and only returns values that are not nil from the input fn
        self.forEach({
            if let nv = fn($0.key, $0.value) {
                transformed[nv.0] = nv.1
            }
        })
        return transformed
    }

    @inlinable
    func containsKey(_ k: Key) -> Bool {
        return self[k] != nil
    }

    @inlinable
    mutating func putAll(_ map: [Key:Value]) {
        self.merge(map, uniquingKeysWith: { return $1 })
    }

    @inlinable
    func firstKey(where fn: (Key) -> Bool) -> Key? {
        return self.first(where: { fn($0.key) })?.key
    }

    @inlinable
    mutating func removeFirstKey(where fn: (Key) -> Bool) -> Value? {
        var found : Key?
        for e in self {
            if fn(e.key) {
                found = e.key
                break
            }
        }

        if let found = found {
            return self.removeValue(forKey: found)
        }
        return nil 
    }
}

