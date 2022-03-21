//
//  ConcurrentWeakHashTable.swift
//  
//  Created by Chris Scalcucci on 3/3/22.
//

import Foundation
import AcceleratusObjCXX

public class ConcurrentWeakHashTable : ConcurrentObject {

    public private(set) var mutex = SharedRecursiveMutex()

    public private(set) var _dataSource = NSHashTable<AnyObject>.weakObjects()

    public init() {
    }

    public init<S: Sequence>(_ c: S) where S.Iterator.Element == AnyObject {
        c.forEach({
            self._dataSource.add($0)
        })
    }

    public var dataSource : NSHashTable<AnyObject> {
        sharedReturn({
            let newSource = NSHashTable<AnyObject>.weakObjects()

            self._dataSource.allObjects.forEach({
                newSource.add($0)
            })
            return newSource
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
            return self._dataSource.count == 0
        })
    }

    @inlinable
    public func add(_ object: AnyObject?) {
        exclusiveAction({
            self._dataSource.add(object)
        })
    }

    @inlinable
    public func putAll<S: Sequence>(_ c: S?) where S.Iterator.Element == AnyObject {
        exclusiveAction({
            c?.forEach({
                self._dataSource.add($0)
            })
        })
    }

    /**
     Removes the entry for the specified key.
     */
    @inlinable
    public func remove(_ object: AnyObject?) {
        exclusiveAction({
            self._dataSource.remove(object)
        })
    }

    /**
     Removes all elements from the map.
     */
    @inlinable
    public func removeAll() {
        exclusiveAction({
            self._dataSource.removeAllObjects()
        })
    }

    // MARK:- High Order

    @inlinable
    public func forEach(_ fn: (AnyObject) throws -> ()) rethrows {
        try sharedAction({
            try self._dataSource.allObjects.forEach({
                try fn($0)
            })
        })
    }

    @inlinable
    public func reduce<X>(_ initialResult: X, _ nextPartialResult: (X, (AnyObject)) throws -> X) rethrows -> X {
        try sharedReturn({
            return try self._dataSource.allObjects.reduce(initialResult, {
                return try nextPartialResult($0, $1)
            })
        })
    }

    @inlinable
    public func filter(_ fn: (AnyObject) throws -> Bool) rethrows -> [AnyObject] {
        try sharedReturn({
            return try self._dataSource.allObjects.filter({
                return try fn($0)
            })
        })
    }

    @inlinable
    public func map<X>(_ fn: (AnyObject) -> X) -> [X] {
        sharedReturn({
            return self._dataSource.allObjects.compactMap({
                return fn($0)
            })
        })
    }

    @inlinable
    public func compactMap<X>(_ fn: (AnyObject) throws -> X?) rethrows -> [X] {
        try sharedReturn({
            return try self._dataSource.allObjects.compactMap({
                return try fn($0)
            })
        })
    }
}
