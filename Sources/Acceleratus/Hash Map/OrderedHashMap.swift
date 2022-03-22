//
//  OrderedHashMap.swift
//
//  Created by Chris Scalcucci on 2/22/21.
//

import Foundation
import AcceleratusObjCXX

public class OrderedHashMap<K: Hashable, V> {

    public var insertOrder : InsertOrder<K>
    public var _keys : OrderedSet<K>
    public var _dataSource : [K:V]

    public convenience init() {
        self.init(.temporal)
    }

    public init(_ insertOrder: InsertOrder<K>) {
        self.insertOrder = insertOrder
        self._keys = OrderedSet<K>(insertOrder)
        self._dataSource = [:]
    }

    public init(_ map: [K:V],
                _ insertOrder: InsertOrder<K> = .temporal) {
        self.insertOrder = insertOrder
        self._keys = OrderedSet<K>(map.keyArray, insertOrder)
        self._dataSource = map
    }

    public init(_ orderedMap: OrderedHashMap<K,V>) {
        self.insertOrder = orderedMap.insertOrder
        self._keys = orderedMap._keys
        self._dataSource = orderedMap._dataSource
    }

    public init(_ concurrentOrderedHashMap: ConcurrentOrderedHashMap<K,V>) {
        self.insertOrder = concurrentOrderedHashMap.insertOrder
        self._keys = concurrentOrderedHashMap._keys
        self._dataSource = concurrentOrderedHashMap._dataSource
    }

    @inlinable
    public subscript(_ k: K) -> V? {
        get {
            return self._dataSource[k]
        } set {
            if let value = newValue {
                if self._dataSource.containsKey(k) {
                    self._dataSource.updateValue(value, forKey: k)
                } else {
                    self._dataSource[k] = value
                    self._keys.insert(k)
                }
            } else {
                self._dataSource.removeValue(forKey: k)
                self._keys.remove(k)
            }
        }
    }

    @inlinable
    public var dataSource : Dictionary<K,V> {
        let newObj = self._dataSource
        return newObj
    }

    @inlinable
    public var count : Int {
        return self._dataSource.count
    }

    @inlinable
    public var isEmpty : Bool {
        return self._dataSource.isEmpty
    }

    @inlinable
    public var keyArray : [K] {
        self._keys.array
    }

    @inlinable
    public var keys : OrderedSet<K> {
        return OrderedSet<K>(self._keys)
    }

    @inlinable
    public var values : [V] {
        return self._keys.compactMap({
            return self._dataSource[$0]
        })
    }

    @inlinable
    public func index(of key: K) -> Int? {
        return self._keys.index(of: key)
    }

    @inlinable
    public var lastKey : K? {
        self._keys.last
    }

    @inlinable
    public var firstKey : K? {
        self._keys.first
    }

    @inlinable
    public var last : (K, V)? {
        if let lastKey = self._keys.last,
           let lastValue = self._dataSource[lastKey] {
            return (lastKey, lastValue)
        }
        return nil
    }

    @inlinable
    public var first : (K, V)? {
        if let firstKey = self._keys.first,
           let firstValue = self._dataSource[firstKey] {
            return (firstKey, firstValue)
        }
        return nil
    }

    @inlinable
    public func pair(at index: Int) -> (K,V)? {
        guard self._keys.count > index else { return nil }

        let key = self._keys[index]
        guard let value = self._dataSource[key] else { return nil }

        return (key, value)
    }

    @inlinable
    public func get(_ k: K) -> V? {
        return self._dataSource[k]
    }

    @inlinable
    public func put(_ v: V?, `for` key: K) {
        if let value = v {
            if self._dataSource.containsKey(key) {
                self._dataSource.updateValue(value, forKey: key)
            } else {
                self._dataSource[key] = value
                self._keys.insert(key)
            }
        } else {
            self._dataSource.removeValue(forKey: key)
            self._keys.remove(key)
        }
    }

    @inlinable
    public func putAll(_ c: [K:V]) {
        c.forEach({
            if self._dataSource.containsKey($0) {
                self._dataSource.updateValue($1, forKey: $0)
            } else {
                self._dataSource[$0] = $1
                self._keys.insert($0)
            }
        })
    }

    @inlinable
    public func putAll(_ c: ConcurrentHashMap<K,V>) {
        c.forEach({
            if self._dataSource.containsKey($0) {
                self._dataSource.updateValue($1, forKey: $0)
            } else {
                self._dataSource[$0] = $1
                self._keys.insert($0)
            }
        })
    }

    @inlinable
    public func containsKey(_ k: K) -> Bool {
        return self._dataSource[k] != nil
    }

    @inlinable @discardableResult
    public func computeIfAbsent(_ k: K, _ fn: () -> (V)) -> V {
        if let value = self._dataSource[k] {
            return value
        } else {
            self._keys.insert(k)
            return self._dataSource.computeIfAbsent(k, fn)
        }
    }

    /**
     Removes the entry for the specified key.
     */
    @inlinable @discardableResult
    public func remove(_ k: K) -> V? {
        self._keys.remove(k)
        return self._dataSource.removeValue(forKey: k)
    }

    /**
     Removes all elements from the map.
     */
    @inlinable
    public func removeAll() {
        self._keys.removeAll()
        self._dataSource.removeAll()
    }

    // MARK:- High Order

    @inlinable
    public func first(where predicate: ((K,V)) throws -> Bool) rethrows -> (K, V)? {
        for key in self._keys.array {
            if let value = self._dataSource[key] {
                if try predicate((key, value)) {
                    return (key, value)
                }
            }
        }
        return nil
    }

    @inlinable
    public func forEach(_ fn: (K,V) throws -> ()) rethrows {
        try self._keys.forEach({
            guard let value = self._dataSource[$0] else { throw CollectionError.badAccess }
            try fn($0, value)
        })
    }

    @inlinable
    public func reduce<T>(_ initialResult: T, _ nextPartialResult: (T, (K,V)) throws -> T) rethrows -> T {
        return try self._keys.reduce(initialResult, {
            guard let value = self._dataSource[$1] else { throw CollectionError.badAccess }
            return try nextPartialResult($0, ($1, value))
        })
    }

    @inlinable
    public func filter(_ fn: ((K,V)) throws -> Bool) rethrows -> [K:V] {
        return try self._dataSource.filter(fn)
    }

    @inlinable
    public func map<T>(_ fn: (K, V) throws -> T) rethrows -> [T] {
        try self._keys.map({
            guard let value = self._dataSource[$0] else { throw CollectionError.badAccess }
            return try fn($0, value)
        })
    }

    @inlinable
    public func mapKeys<T: Hashable>(_ fn: (K) throws -> T) rethrows -> [T:V] {
        return try self._dataSource.mapKeys(fn)
    }

    @inlinable
    public func compactMap<T>(_ fn: (K,V) throws -> T?) rethrows -> [T] {
        try self._keys.compactMap({
            guard let value = self._dataSource[$0] else { return nil }
            return try fn($0, value)
        })
    }
}

extension OrderedHashMap : CustomStringConvertible, CustomDebugStringConvertible {
    @inlinable
    public var description: String {
        var result = "{"
        self._keys.forEach({
            if let value = self._dataSource[$0] {
                result += "\($0):\(value)"
            }
        })
        result += "}"
        return result
    }

    @inlinable
    public var debugDescription: String {
        var result = "{\n"
        var i = 0
        self._keys.forEach({
            if let value = self._dataSource[$0] {
                result += "[\(i)]: \($0) => \(value)\n"
                i += 1
            }
        })
        result += "}"
        return result
    }
}
