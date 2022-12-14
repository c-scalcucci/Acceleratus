//
//  ByteLimitLRUCache.swift
//  
//
//  Created by Chris Scalcucci on 6/10/22.
//

import Foundation
import AcceleratusMutex

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
        defer { self.mutex.unlock_shared() }
        self.mutex.lock_shared()

        return self._dataSource.count
    }

    @inlinable
    public var isEmpty : Bool {
        defer { self.mutex.unlock_shared() }
        self.mutex.lock_shared()

        return self._dataSource.isEmpty
    }

    @inlinable
    public var keyArray : [K] {
        defer { self.mutex.unlock_shared() }
        self.mutex.lock_shared()

        return self._keys.array
    }

    @inlinable
    public var keys : OrderedSet<K> {
        self.mutex.lock_shared()
        let copyOut = self._keys
        self.mutex.unlock_shared()

        return OrderedSet<K>(copyOut)
    }

    @inlinable
    public var values : [V] {
        self.mutex.lock_shared()
        let copyOutKeys = self._keys.array
        let copyOutSource = self._dataSource
        self.mutex.unlock_shared()

        return copyOutKeys.compactMap({ copyOutSource[$0] })
    }

    @inlinable
    public func index(of key: K) -> Int? {
        defer { self.mutex.unlock_shared() }
        self.mutex.lock_shared()

        return self._keys.index(of: key)
    }

    @inlinable
    public var lastKey : K? {
        defer { self.mutex.unlock_shared() }
        self.mutex.lock_shared()

        return self._keys.last
    }

    @inlinable
    public var firstKey : K? {
        defer { self.mutex.unlock_shared() }
        self.mutex.lock_shared()

        return self._keys.first
    }

    @inlinable
    public var last : (K, V)? {
        defer { self.mutex.unlock_shared() }
        self.mutex.lock_shared()

        if let lastKey = self._keys.last,
           let lastValue = self._dataSource[lastKey] {
            return (lastKey, lastValue)
        }
        return nil
    }

    @inlinable
    public var first : (K, V)? {
        defer { self.mutex.unlock_shared() }
        self.mutex.lock_shared()

        if let firstKey = self._keys.first,
           let firstValue = self._dataSource[firstKey] {
            return (firstKey, firstValue)
        }
        return nil
    }

    @inlinable
    public func get(_ k: K) -> V? {
        defer { self.mutex.unlock() }
        self.mutex.lock()

        let value = self._dataSource[k]

        // Make the key recent
        self._keys.remove(k)
        self._keys.insert(k)

        return value
    }

    @inlinable
    public func storageSize(of element: V) -> Int {
        // If know for sure the size of the object
        // or can only go based off pointer storage
        return (element as? DeclarativeByteStorage)?.storageEstimate ?? MemoryLayout.size(ofValue: element)
    }

    public func put(_ v: V?, `for` key: K) {
        defer { self.mutex.unlock() }
        self.mutex.lock()

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
                    let oldestKey = self._keys.removeFirst()
                    if let oldestValue = self._dataSource.removeValue(forKey: oldestKey) {
                        self.currentCapacity -= self.storageSize(of: oldestValue)
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

                // Remove eldest entry if we actually emplaced a new value
                if oldValue == nil {
                    while self.currentCapacity + 1 > amount {
                        let oldestKey = self._keys.removeFirst()
                        if let oldestValue = self._dataSource.removeValue(forKey: oldestKey) {
                            self.currentCapacity -= self.storageSize(of: oldestValue)
                        }
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

    }

    @inlinable
    public func containsKey(_ k: K) -> Bool {
        sharedReturn({
            return self._dataSource[k] != nil
        })
    }

    @inlinable @discardableResult
    public  func computeIfAbsent(_ k: K, _ fn: () -> (V)) -> V {
        defer { self.mutex.unlock() }
        self.mutex.lock()

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
    @discardableResult
    public func remove(_ k: K) -> V? {
        defer { self.mutex.unlock() }
        self.mutex.lock()

        self._keys.remove(k)
        if let value = self._dataSource.removeValue(forKey: k) {
            self.currentCapacity -= self.isCountBased ? 1 : self.storageSize(of:  value)
        }
        return nil
    }

    /**
     Removes all elements from the map.
     */
    public func removeAll() {
        defer { self.mutex.unlock() }
        self.mutex.lock()

        self._keys.removeAll()
        self._dataSource.removeAll()
        self.currentCapacity = 0
    }

    //
    // MARK: High Order
    //

    @inlinable
    public  func first(where predicate: ((K,V)) throws -> Bool) rethrows -> (K, V)? {
        defer { self.mutex.unlock() }
        self.mutex.lock()

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
    }

    @inlinable
    public func forEach(_ fn: (K,V) throws -> ()) rethrows {
        self.mutex.lock_shared()
        let copyOutKeys = self._keys
        let copyOutSource = self._dataSource
        self.mutex.unlock_shared()

        try copyOutKeys.forEach({
            guard let value = copyOutSource[$0] else { throw CollectionError.badAccess }
            try fn($0, value)
        })
    }

    @inlinable
    public func reduce<T>(_ initialResult: T, _ nextPartialResult: (T, (K,V)) throws -> T) rethrows -> T {
        self.mutex.lock_shared()
        let copyOutKeys = self._keys
        let copyOutSource = self._dataSource
        self.mutex.unlock_shared()

        return try copyOutKeys.reduce(initialResult, {
            guard let value = copyOutSource[$1] else { throw CollectionError.badAccess }
            return try nextPartialResult($0, ($1, value))
        })
    }

    @inlinable
    public func filter(_ fn: ((K,V)) throws -> Bool) rethrows -> [K:V] {
        self.mutex.lock_shared()
        let copyOutSource = self._dataSource
        self.mutex.unlock_shared()

        return try copyOutSource.filter(fn)
    }

    @inlinable
    public func map<T>(_ fn: (K, V) throws -> T) rethrows -> [T] {
        self.mutex.lock_shared()
        let copyOutKeys = self._keys
        let copyOutSource = self._dataSource
        self.mutex.unlock_shared()

        return try copyOutKeys.map({
            guard let value = copyOutSource[$0] else { throw CollectionError.badAccess }
            return try fn($0, value)
        })
    }

    @inlinable
    public func mapKeys<T: Hashable>(_ fn: (K) throws -> T) rethrows -> [T:V] {
        self.mutex.lock_shared()
        let copyOutSource = self._dataSource
        self.mutex.unlock_shared()

        return try copyOutSource.mapKeys(fn)
    }

    @inlinable
    public func compactMap<T>(_ fn: (K,V) throws -> T?) rethrows -> [T] {
        self.mutex.lock_shared()
        let copyOutKeys = self._keys
        let copyOutSource = self._dataSource
        self.mutex.unlock_shared()

        return try copyOutKeys.compactMap({
            guard let value = copyOutSource[$0] else { return nil }
            return try fn($0, value)
        })
    }

    //
    // MARK: String Convertibles
    //

    @inlinable
    public var description: String {
        self.mutex.lock_shared()
        let copyOutKeys = self._keys
        let copyOutSource = self._dataSource
        self.mutex.unlock_shared()

        var result = "{"
        copyOutKeys.forEach({
            if let value = copyOutSource[$0] {
                result += "\($0):\(value)"
            }
        })
        result += "}"
        return result

    }

    @inlinable
    public var debugDescription: String {
        self.mutex.lock_shared()
        let copyOutKeys = self._keys
        let copyOutSource = self._dataSource
        self.mutex.unlock_shared()

        var result = "{\n"
        var i = 0
        copyOutKeys.forEach({
            if let value = copyOutSource[$0] {
                result += "[\(i)]: \($0) => \(value)\n"
                i += 1
            }
        })
        result += "}"
        return result
    }
}
