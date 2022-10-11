//
//  ConcurrentOrderedHashMap.swift
//  
//  Created by Chris Scalcucci on 2/22/21.
//

import Foundation
import AcceleratusObjCXX

public class ConcurrentOrderedHashMap<K: Hashable, V> : ConcurrentObject {

    public private(set) var mutex = SharedRecursiveMutex()

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
            exclusiveReturn({
                return self._dataSource[k]
            })
        } set {
            exclusiveAction({
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
    public var keyArray : [K] {
        sharedReturn({
            self._keys.array
        })
    }

    @inlinable
    public var keys : OrderedSet<K> {
        sharedReturn({
            return OrderedSet<K>(self._keys)
        })
    }

    @inlinable
    public var values : [V] {
        sharedReturn({
            return self._keys.compactMap({
                return self._dataSource[$0]
            })
        })
    }

    @inlinable
    public func index(of key: K) -> Int? {
        sharedReturn({
            return self._keys.index(of: key)
        })
    }

    @inlinable
    public var lastKey : K? {
        sharedReturn({
            self._keys.last
        })
    }

    @inlinable
    public var firstKey : K? {
        sharedReturn({
            self._keys.first
        })
    }

    @inlinable
    public var last : (K, V)? {
        sharedReturn({
            if let lastKey = self._keys.last,
               let lastValue = self._dataSource[lastKey] {
                return (lastKey, lastValue)
            }
            return nil
        })
    }

    @inlinable
    public var first : (K, V)? {
        sharedReturn({
            if let firstKey = self._keys.first,
               let firstValue = self._dataSource[firstKey] {
                return (firstKey, firstValue)
            }
            return nil
        })
    }

    @inlinable
    public func pair(at index: Int) -> (K,V)? {
        sharedReturn({
            guard index >= 0 else { return nil }
            guard self._keys.count > index else { return nil }

            let key = self._keys[index]
            guard let value = self._dataSource[key] else { return nil }

            return (key, value)
        })
    }

    @inlinable
    public func get(_ k: K) -> V? {
        sharedReturn({
            return self._dataSource[k]
        })
    }

    @inlinable
    public  func put(_ v: V?, `for` key: K) {
        exclusiveAction({
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
        })
    }

    @inlinable
    public  func putAll(_ c: [K:V]) {
        exclusiveAction({
            c.forEach({
                if self._dataSource.containsKey($0) {
                    self._dataSource.updateValue($1, forKey: $0)
                } else {
                    self._dataSource[$0] = $1
                    self._keys.insert($0)
                }
            })
        })
    }

    @inlinable
    public  func putAll(_ c: ConcurrentHashMap<K,V>) {
        exclusiveAction({
            c.forEach({
                if self._dataSource.containsKey($0) {
                    self._dataSource.updateValue($1, forKey: $0)
                } else {
                    self._dataSource[$0] = $1
                    self._keys.insert($0)
                }
            })
        })
    }

    @inlinable
    public func containsKey(_ k: K) -> Bool {
        sharedReturn({
            return self._dataSource[k] != nil
        })
    }

    @inlinable @discardableResult
    public  func computeIfAbsent(_ k: K, _ fn: () -> (V)) -> V {
        exclusiveReturn({
            if let value = self._dataSource[k] {
                return value
            } else {
                self._keys.insert(k)
                return self._dataSource.computeIfAbsent(k, fn)
            }
        })
    }

    /**
     Removes the entry for the specified key.
     */
    @inlinable @discardableResult
    public  func remove(_ k: K) -> V? {
        exclusiveReturn({
            self._keys.remove(k)
            return self._dataSource.removeValue(forKey: k)
        })
    }

    /**
     Removes all elements from the map.
     */
    @inlinable
    public  func removeAll() {
        exclusiveAction({
            self._keys.removeAll()
            self._dataSource.removeAll()
        })
    }

    // MARK:- High Order

    @inlinable
    public  func first(where predicate: ((K,V)) throws -> Bool) rethrows -> (K, V)? {
        try exclusiveReturn({
            for key in self._keys.array {
                if let value = self._dataSource[key] {
                    if try predicate((key, value)) {
                        return (key, value)
                    }
                }
            }
            return nil
        })
    }

    @inlinable
    public func forEach(_ fn: (K,V) throws -> ()) rethrows {
        try sharedAction({
            try self._keys.forEach({
                guard let value = self._dataSource[$0] else { throw CollectionError.badAccess }
                try fn($0, value)
            })
        })
    }

    @inlinable
    public func reduce<T>(_ initialResult: T, _ nextPartialResult: (T, (K,V)) throws -> T) rethrows -> T {
        try sharedReturn({
            return try self._keys.reduce(initialResult, {
                guard let value = self._dataSource[$1] else { throw CollectionError.badAccess }
                return try nextPartialResult($0, ($1, value))
            })
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
            try self._keys.map({
                guard let value = self._dataSource[$0] else { throw CollectionError.badAccess }
                return try fn($0, value)
            })
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
            try self._keys.compactMap({
                guard let value = self._dataSource[$0] else { return nil }
                return try fn($0, value)
            })
        })
    }
}

extension ConcurrentOrderedHashMap : CustomStringConvertible, CustomDebugStringConvertible {
    @inlinable
    public var description: String {
        sharedReturn({
            var result = "{"
            self._keys.forEach({
                if let value = self._dataSource[$0] {
                    result += "\($0):\(value)"
                }
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
            self._keys.forEach({
                if let value = self._dataSource[$0] {
                    result += "[\(i)]: \($0) => \(value)\n"
                    i += 1
                }
            })
            result += "}"
            return result
        })
    }
}
