//
//  ConcurrentHashMap.swift
//
//  Created by Chris Scalcucci on 7/22/20.
//

import Foundation
import AcceleratusMutex

public class ConcurrentHashMap<K: Hashable, V> : ConcurrentObject {

    public private(set) var mutex = SharedRecursiveMutex()

    public var _dataSource : Dictionary<K,V>

    @inlinable
    public init(_ c: Dictionary<K,V> = [:]) {
        self._dataSource = c
    }

    @inlinable
    public init(_ c: Dictionary<K,V>? = nil) {
        self._dataSource = c ?? [:]
    }

    @inlinable
    public subscript(_ k: K) -> V? {
        get {
            exclusiveReturn({
                return self._dataSource[k]
            })
        } set {
            exclusiveAction({
                self._dataSource[k] = newValue
            })
        }
    }

    @inlinable
    public var dataSource : Dictionary<K,V> {
        sharedReturn({
            let newObj = self._dataSource
            return newObj
        })
    }

    @inlinable
    public var count : Int {
        sharedReturn({
            return self._dataSource.count
        })
    }

    @inlinable
    public var isEmpty : Bool {
        sharedReturn({
            return self._dataSource.isEmpty
        })
    }

    @inlinable
    public var keys : [K] {
        sharedReturn({
            return self._dataSource.keyArray
        })
    }

    @inlinable
    public var values : [V] {
        sharedReturn({
            return self._dataSource.valueArray
        })
    }

    @inlinable
    public func get(_ k: K) -> V? {
        exclusiveReturn({
            return self._dataSource[k]
        })
    }

    @inlinable
    public func put(_ v: V?, `for` key: K) {
        exclusiveAction({
            self._dataSource[key] = v
        })
    }

    @inlinable
    public func putAll(_ c: [K:V]) {
        exclusiveAction({
            self._dataSource.putAll(c)
        })
    }

    @inlinable
    public func putAll(_ c: ConcurrentHashMap<K,V>) {
        exclusiveAction({
            self._dataSource.putAll(c.dataSource)
        })
    }

    @inlinable
    public func containsKey(_ k: K) -> Bool {
        exclusiveReturn({
            return self._dataSource[k] != nil
        })
    }

    @inlinable @discardableResult
    public func computeIfAbsent(_ k: K, _ fn: () -> (V)) -> V {
        exclusiveReturn({
            return self._dataSource.computeIfAbsent(k, fn)
        })
    }

    /**
     Removes the entry for the specified key.
     */
    @inlinable @discardableResult
    public func remove(_ k: K) -> V? {
        exclusiveReturn({
            return self._dataSource.removeValue(forKey: k)
        })
    }

    /**
     Removes all elements from the map.
     */
    @inlinable
    public func removeAll() {
        exclusiveAction({
            self._dataSource.removeAll()
        })
    }

    // MARK:- High Order

    @inlinable
    public func forEach(_ fn: (K,V) throws -> ()) rethrows {
        try sharedAction({
            try self._dataSource.forEach(fn)
        })
    }

    @inlinable
    public func reduce<T>(_ initialResult: T, _ nextPartialResult: (T, (K,V)) throws -> T) rethrows -> T {
        try sharedReturn({
            return try self._dataSource.reduce(initialResult, nextPartialResult)
        })
    }

    @inlinable
    public func filter(_ fn: ((K,V)) throws -> Bool) rethrows -> [K:V] {
        try sharedReturn({
            return try self._dataSource.filter(fn)
        })
    }

    @inlinable
    public func map<T>(_ fn: (K, V) throws -> T) rethrows -> [T] {
        try sharedReturn({
            return try self._dataSource.map(fn)
        })
    }

    @inlinable
    public func mapKeys<T: Hashable>(_ fn: (K) throws -> T) rethrows -> [T:V] {
        try sharedReturn({
            return try self._dataSource.mapKeys(fn)
        })
    }

    @inlinable
    public func compactMap<T>(_ fn: (K,V) throws -> T?) rethrows -> [T] {
        try sharedReturn({
            return try self._dataSource.compactMap(fn)
        })
    }
}

extension ConcurrentHashMap : CustomStringConvertible, CustomDebugStringConvertible {
    @inlinable
    public var description: String {
        sharedReturn({
            var result = "{"
            self._dataSource.forEach({
                result += "\($0):\($1)"
            })
            result += "}"
            return result
        })
    }

    @inlinable
    public var debugDescription: String {
        sharedReturn({
            var result = "{\n"
            var i = 0
            self._dataSource.forEach({
                result += "[\(i)]: \($0) => \($1)\n"
                i += 1
            })
            result += "}"
            return result
        })
    }
}

extension ConcurrentHashMap where V: Equatable {
    /**
     Removes the entry for the specified key only if it is currently
     mapped to the specified vcalue.
     */
    @inlinable
    public func remove(_ k: K, `if` value: V) -> Bool {
        exclusiveReturn({
            if self._dataSource[k] == value {
                self._dataSource.removeValue(forKey: k)
                return true
            }
            return false
        })
    }
}

extension ConcurrentHashMap where V: AnyObject {
    /**
     Removes the entry for the specified key only if it is currently
     mapped to the specified vcalue.
     */
    @inlinable
    public func remove(_ k: K, `if` value: V) -> Bool {
        exclusiveReturn({
            if self._dataSource[k] === value {
                self._dataSource.removeValue(forKey: k)
                return true
            }
            return false
        })
    }
}
