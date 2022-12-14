//
//  ConcurrentWeakArray.swift
//  
//
//  Created by Chris Scalcucci on 6/16/22.
//

import Foundation
import AcceleratusMutex

public class ConcurrentWeakArray<T: AnyObject> : ConcurrentObject {
    public typealias Element = T

    public private(set) var mutex = SharedRecursiveMutex()

    public private(set) var _dataSource = Array<WeakPointerContainer<Element>>()

    public init() {
    }

    public init<S: Sequence>(_ c: S) where S.Iterator.Element == T {
        c.forEach({
            self._dataSource.append(WeakPointerContainer($0))
        })
    }

    private func sanitize() {
        self._dataSource = self._dataSource.filter({
            $0.object != nil
        })
    }

    @inlinable
    public var count : Int {
        defer { self.mutex.unlock_shared() }
        self.mutex.lock_shared()

        return self._dataSource.reduce(into: 0, {
            if $1.object != nil { $0 += 1 }
        })
    }

    @inlinable
    public var isEmpty : Bool {
        defer { self.mutex.unlock_shared() }
        self.mutex.lock_shared()

        return self._dataSource.reduce(into: 0, {
            if $1.object != nil { $0 += 1 }
        }) == 0
    }

    public func add(_ object: Element) {
        defer { self.mutex.unlock() }
        self.mutex.lock()

        self.sanitize()
        self._dataSource.append(WeakPointerContainer(object))
    }

    public func putAll<S: Sequence>(_ c: S?) where S.Iterator.Element == Element {
        defer { self.mutex.unlock() }
        self.mutex.lock()

        self.sanitize()
        c?.forEach({ self._dataSource.append(WeakPointerContainer($0)) })
    }

    /**
        Removes the entry for the specified key.
     */
    public func remove(_ object: Element) {
        defer { self.mutex.unlock() }
        self.mutex.lock()

        self.sanitize()
        self._dataSource.removeFirst(where: {
            $0.object === object
        })
    }

    /**
        Removes all elements from the map.
     */
    public func removeAll() {
        defer { self.mutex.unlock() }
        self.mutex.lock()

        self._dataSource.removeAll()
    }

    // MARK:- High Order

    @inlinable
    public func forEach(_ fn: (Element) throws -> ()) rethrows {
        self.mutex.lock_shared()
        let copyOut = self._dataSource
        self.mutex.unlock_shared()

        try copyOut.forEach({
            if let object = $0.object {
                try fn(object)
            }
        })
    }

    @inlinable
    public func reduce<X>(_ initialResult: X, _ nextPartialResult: (X, (Element)) throws -> X) rethrows -> X {
        self.mutex.lock_shared()
        let copyOut = self._dataSource
        self.mutex.unlock_shared()

        return try copyOut.reduce(initialResult, {
            if let object = $1.object {
                return try nextPartialResult($0, object)
            }
            return $0
        })
    }

    @inlinable
    public func filter(_ fn: (Element) throws -> Bool) rethrows -> [Element] {
        self.mutex.lock_shared()
        let copyOut = self._dataSource
        self.mutex.unlock_shared()

        return try copyOut.compactMap({
            if let object = $0.object, try fn(object) {
                return object
            }
            return nil
        })
    }

    @inlinable
    public func map<X>(_ fn: (Element) -> X) -> [X] {
        self.mutex.lock_shared()
        let copyOut = self._dataSource
        self.mutex.unlock_shared()

        return copyOut.compactMap({
            if let object = $0.object {
                return fn(object)
            }
            return nil
        })
    }

    @inlinable
    public func compactMap<X>(_ fn: (Element) throws -> X?) rethrows -> [X] {
        self.mutex.lock_shared()
        let copyOut = self._dataSource
        self.mutex.unlock_shared()

        return try copyOut.compactMap({
            if let object = $0.object {
                return try fn(object)
            }
            return nil
        })
    }
}
