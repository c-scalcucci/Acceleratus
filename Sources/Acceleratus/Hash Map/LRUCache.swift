//
//  ByteLimitLRUCache.swift
//  
//
//  Created by Chris Scalcucci on 6/10/22.
//

import Foundation
import AcceleratusObjCXX

public enum CapacityType {
    case bytes (Int)
    case count (Int)
}

public class LRUCache<K: Hashable, V> : ConcurrentObject,
                                        CustomStringConvertible,
                                        CustomDebugStringConvertible {

    public private(set) var mutex = SharedRecursiveMutex()

    // How much the cache holds
    public let maxCapacity : CapacityType
    public private(set) var currentCapacity : Int = 0

    private var isCountBased : Bool = false

    public var _keys : OrderedSet<K>
    public var _dataSource : [K:V]

    public init(capacity: CapacityType) {
        self.maxCapacity = capacity
        self._keys = OrderedSet<K>(.temporal)
        self._dataSource = [:]

        switch capacity {
        case .bytes:
            self.isCountBased = false
        case .count:
            self.isCountBased = true
        }
    }

    @inlinable
    public subscript(_ k: K) -> V? {
        get {
            return self.get(k)
        } set {
            self.put(newValue, for: k)
        }
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
    public func get(_ k: K) -> V? {
        exclusiveReturn({
            let value = self._dataSource[k]

            // Make the key recent
            self._keys.remove(k)
            self._keys.insert(k)

            return value
        })
    }

    @inlinable
    public func storageSize(of element: V) -> Int {
        // If know for sure the size of the object
        // or can only go based off pointer storage
        return (element as? DeclarativeByteStorage)?.storageEstimate ?? MemoryLayout.size(ofValue: element)
    }

    public func put(_ v: V?, `for` key: K) {
        exclusiveAction({
            if let newValue = v {
                switch self.maxCapacity {
                case .bytes(let amount):
                    let newSize = self.storageSize(of: newValue)
                    var delta = newSize

                    if let oldValue = self._dataSource[key] {
                        guard newSize < amount else { return }

                        delta -= self.storageSize(of: oldValue)
                    }

                    // Remove the old key
                    self._keys.remove(key)
                    self._dataSource.removeValue(forKey: key)

                    // Remove eldest entries until we're below capacity
                    while self.currentCapacity + delta > amount {
                        if let lastKey = self._keys.first,
                           let lastValue = self._dataSource.removeValue(forKey: lastKey) {
                            self._keys.removeFirst()
                            self.currentCapacity -= self.storageSize(of: lastValue)
                        }
                    }

                    // Finally, add the new value
                    self._keys.insert(key)
                    self._dataSource[key] = newValue
                    self.currentCapacity += delta
                case .count(let amount):
                    // Remove the old key
                    self._keys.remove(key)
                    let oldValue = self._dataSource.removeValue(forKey: key)

                    // Remove eldest entry
                    if oldValue == nil && self.currentCapacity + 1 > amount {
                        if let lastKey = self._keys.first,
                           let lastValue = self._dataSource.removeValue(forKey: lastKey) {
                            self._keys.removeFirst()
                            self.currentCapacity -= self.storageSize(of: lastValue)
                        }
                    }

                    // Finally, add the new value
                    self._keys.insert(key)
                    self._dataSource[key] = newValue
                }
            } else {
                self._keys.remove(key)

                if let oldValue = self._dataSource.removeValue(forKey: key) {
                    self.currentCapacity -= self.isCountBased ? 1 : self.storageSize(of:  oldValue)
                }
            }
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
    @discardableResult
    public func remove(_ k: K) -> V? {
        exclusiveReturn({
            self._keys.remove(k)
            if let value = self._dataSource.removeValue(forKey: k) {
                self.currentCapacity -= self.isCountBased ? 1 : self.storageSize(of:  value)
            }
            return nil
        })
    }

    /**
     Removes all elements from the map.
     */
    public func removeAll() {
        exclusiveAction({
            self._keys.removeAll()
            self._dataSource.removeAll()
            self.currentCapacity = 0
        })
    }

    //
    // MARK: High Order
    //

    @inlinable
    public  func first(where predicate: ((K,V)) throws -> Bool) rethrows -> (K, V)? {
        try exclusiveReturn({
            for key in self._keys.array {
                if let value = self._dataSource[key] {
                    if try predicate((key, value)) {
                        // Make the key recent
                        self._keys.remove(key)
                        self._keys.insert(key)

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

    //
    // MARK: String Convertibles
    //

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
