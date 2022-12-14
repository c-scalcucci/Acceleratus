//
//  ConcurrentWeakOrderedSet.swift
//  
//
//  Created by Chris Scalcucci on 6/16/22.
//

import Foundation
import AcceleratusMutex

public class ConcurrentWeakOrderedSet<T: AnyObject & Hashable> : ConcurrentObject {
    public typealias Element = T

    public private(set) var mutex = SharedRecursiveMutex()

    public private(set) var indexes = [WeakHashablePointerContainer<Element>:Int]()
    public private(set) var array = [WeakHashablePointerContainer<Element>]()

    public init() {
    }

    public init<S: Sequence>(_ c: S) where S.Iterator.Element == T {
        c.forEach({
            self.array.append(WeakHashablePointerContainer($0))
        })
        self.array.enumerated().forEach({ index, element in
            self.indexes[element] = index
        })
    }

    private func sanitize() {
        let count = self.array.count
        self.array = self.array.filter({ $0.object != nil })

        if count != self.array.count {
            self.indexes.removeAll()
            self.array.enumerated().forEach({ index, element in
                self.indexes[element] = index
            })
        }
    }

    @inlinable
    public var count : Int {
        defer { self.mutex.unlock_shared() }
        self.mutex.lock_shared()

        return self.array.reduce(into: 0, {
            if $1.object != nil { $0 += 1 }
        })
    }

    @inlinable
    public var isEmpty : Bool {
        defer { self.mutex.unlock_shared() }
        self.mutex.lock_shared()

        return self.array.reduce(into: 0, {
            if $1.object != nil { $0 += 1 }
        }) == 0
    }

    @discardableResult
    public func insert(_ newMember: ConcurrentOrderedSet<Element>.Element) -> (inserted: Bool, memberAfterInsert: ConcurrentOrderedSet<Element>.Element) {
        defer { self.mutex.unlock() }
        self.mutex.lock()

        self.sanitize()

        if let key = self.indexes.firstKey(where: { $0.object?.hashValue == newMember.hashValue }),
           let index = self.indexes[key],
           let oldValue = self.array[index].object {
            return (false, oldValue)
        } else {
            let ptr = WeakHashablePointerContainer(newMember)
            self.array.append(ptr)
            self.indexes[ptr] = self.array.count - 1
            return (true, newMember)
        }
    }

    public func append<S>(contentsOf newElements: S) where S : Sequence, Element == S.Element {
        defer { self.mutex.unlock() }
        self.mutex.lock()

        self.sanitize()

        newElements.forEach({ element in
            if self.indexes.firstKey(where: { $0.object?.hashValue == element.hashValue }) == nil {
                let ptr = WeakHashablePointerContainer(element)
                self.array.append(ptr)
                self.indexes[ptr] = self.array.count - 1
            }
        })
    }

    /**
     Removes the entry for the specified key.
     */
    public func remove(_ object: Element) {
        defer { self.mutex.unlock() }
        self.mutex.lock()

        self.sanitize()

        if let key = self.indexes.firstKey(where: { $0.object?.hashValue == object.hashValue }),
           let index = self.indexes[key] {
            self.array.remove(at: index)
            self.indexes.removeAll()
            self.array.enumerated().forEach({ index, element in
                self.indexes[element] = index
            })
        }
    }

    /**
     Removes all elements from the map.
     */
    public func removeAll() {
        defer { self.mutex.unlock() }
        self.mutex.lock()

        self.array.removeAll()
        self.indexes.removeAll()
    }

    // MARK:- High Order

    @inlinable
    public func forEach(_ fn: (Element) throws -> ()) rethrows {
        self.mutex.lock_shared()
        let copyOut = self.array
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
        let copyOut = self.array
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
        let copyOut = self.array
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
        let copyOut = self.array
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
        let copyOut = self.array
        self.mutex.unlock_shared()

        return try copyOut.compactMap({
            if let object = $0.object {
                return try fn(object)
            }
            return nil
        })
    }
}


