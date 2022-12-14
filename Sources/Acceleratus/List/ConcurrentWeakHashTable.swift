//
//  ConcurrentWeakHashTable.swift
//  
//  Created by Chris Scalcucci on 3/3/22.
//

import Foundation
import AcceleratusMutex

public class ConcurrentWeakHashTable {

    public private(set) var mutex = SharedRecursiveMutex()

    public private(set) var _dataSource = NSHashTable<AnyObject>.weakObjects()

    public init() {
    }

    public init<S: Sequence>(_ c: S) where S.Iterator.Element == AnyObject {
        c.forEach({
            self._dataSource.add($0)
        })
    }

    @inlinable
    public var count : Int {
        defer { self.mutex.unlock() }
        self.mutex.lock()
        return self._dataSource.allObjects.count
    }

    @inlinable
    public var isEmpty : Bool {
        defer { self.mutex.unlock() }
        self.mutex.lock()
        return self._dataSource.allObjects.count == 0
    }

    @inlinable
    public func add(_ object: AnyObject?) {
        defer { self.mutex.unlock() }
        self.mutex.lock()

        self._dataSource.add(object)
    }

    @inlinable
    public func putAll<S: Sequence>(_ c: S?) where S.Iterator.Element == AnyObject {
        defer { self.mutex.unlock() }
        self.mutex.lock()

        c?.forEach({ self._dataSource.add($0) })
    }

    /**
     Removes the entry for the specified key.
     */
    @inlinable
    public func remove(_ object: AnyObject?) {
        defer { self.mutex.unlock() }
        self.mutex.lock()

        self._dataSource.remove(object)
    }

    /**
     Removes all elements from the map.
     */
    @inlinable
    public func removeAll() {
        defer { self.mutex.unlock() }
        self.mutex.lock()

        self._dataSource.removeAllObjects()
    }

    // MARK:- High Order

    @inlinable
    public func forEach(_ fn: (AnyObject) throws -> ()) rethrows {
        self.mutex.lock()
        let copyOut = self._dataSource.allObjects
        self.mutex.unlock()

        try copyOut.forEach({
            try fn($0)
        })
    }

    @inlinable
    public func reduce<X>(_ initialResult: X, _ nextPartialResult: (X, (AnyObject)) throws -> X) rethrows -> X {
        self.mutex.lock()
        let copyOut = self._dataSource.allObjects
        self.mutex.unlock()

        return try copyOut.reduce(initialResult, {
            return try nextPartialResult($0, $1)
        })
    }

    @inlinable
    public func filter(_ fn: (AnyObject) throws -> Bool) rethrows -> [AnyObject] {
        self.mutex.lock()
        let copyOut = self._dataSource.allObjects
        self.mutex.unlock()

        return try copyOut.filter({
            return try fn($0)
        })
    }

    @inlinable
    public func map<X>(_ fn: (AnyObject) -> X) -> [X] {
        self.mutex.lock()
        let copyOut = self._dataSource.allObjects
        self.mutex.unlock()

        return copyOut.compactMap({
            return fn($0)
        })
    }

    @inlinable
    public func compactMap<X>(_ fn: (AnyObject) throws -> X?) rethrows -> [X] {
        self.mutex.lock()
        let copyOut = self._dataSource.allObjects
        self.mutex.unlock()

        return try copyOut.compactMap({
            return try fn($0)
        })
    }

    @inlinable
    public  func first(where predicate: (AnyObject) throws -> Bool) rethrows -> AnyObject? {
        self.mutex.lock()
        let copyOut = self._dataSource.allObjects
        self.mutex.unlock()

        return try copyOut.first(where: { try predicate($0) })
    }
}
