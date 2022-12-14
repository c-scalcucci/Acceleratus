//
//  ConcurrentArray.swift
//
//  Created by Chris Scalcucci on 3/11/20.
//

import Foundation
import AcceleratusMutex

public class ConcurrentArray<T> : ConcurrentObject {
    public typealias Element = T

    public private(set) var mutex = SharedRecursiveMutex()

    public var _dataSource : Array<T>

    public static var zero: ConcurrentArray<T> {
        return self.init()
    }

    public required init() {
        self._dataSource = []
    }

    public init(_ elements: [T]) {
        self._dataSource = elements
    }

    @inlinable
    public var isEmpty : Bool {
        sharedReturn({
            return self._dataSource.isEmpty
        })
    }

    @inlinable
    public var count : Int {
        sharedReturn({
            return self._dataSource.count
        })
    }

    @inlinable
    public var dataSource : [T] {
        sharedReturn({
            return Array(self._dataSource)
        })
    }

    @inlinable
    public func append(_ element: T) {
        exclusiveAction({
            self._dataSource.append(element)
        })
    }

    @inlinable
    public  func removeLast() -> T {
        exclusiveReturn({
            return self._dataSource.removeLast()
        })
    }

    @inlinable
    public  func removeFirst() -> T {
        exclusiveReturn({
            return self._dataSource.removeFirst()
        })
    }

    @inlinable
    public  func removeAtIndex(_ index: Int) -> T {
        exclusiveReturn({
            return self._dataSource.remove(at: index)
        })
    }

    @inlinable
    public  func removeAll(_ keepCapacity: Bool = false) {
        exclusiveReturn({
            self._dataSource.removeAll(keepingCapacity: keepCapacity)
        })
    }

    //
    // MARK: High Order
    //

    @inlinable
    public func first(where predicate: (T) throws -> Bool) rethrows -> Element? {
        try sharedReturn({
            return try self._dataSource.first(where: predicate)
        })
    }

    @inlinable
    public func forEach(_ fn: (T) throws -> ()) rethrows {
        try sharedAction({
            let tmp = self._dataSource

            for i in tmp {
                try fn(i)
            }
            //            try tmp.forEach(fn)
        })
    }

    @inlinable
    public func reduce<X>(_ initialResult: X, _ nextPartialResult: (X, Element) throws -> X) rethrows -> X {
        try sharedReturn({
            return try self._dataSource.reduce(initialResult, nextPartialResult)
        })
    }

    @inlinable
    public func reduce<X>(into initialResult: X, _ updateAccumulatingResult: (inout X, Element) throws -> ()) rethrows -> X {
        try sharedReturn({
            return try self._dataSource.reduce(into: initialResult, updateAccumulatingResult)
        })
    }

    @inlinable
    public func filter(_ fn: (T) throws -> Bool) rethrows -> [T] {
        try sharedReturn({
            return try self._dataSource.filter(fn)
        })
    }

    @inlinable
    public func map<X>(_ fn: (T) throws -> X) rethrows -> [X] {
        try sharedReturn({
            return try self._dataSource.map(fn)
        })
    }

    @inlinable
    public func compactMap<X>(_ fn: (T) throws -> X?) rethrows -> [X] {
        try sharedReturn({
            return try self._dataSource.compactMap(fn)
        })
    }
}

@inlinable
public func +<T>(lhs: ConcurrentArray<T>, rhs: ConcurrentArray<T>) -> ConcurrentArray<T> {
    return ConcurrentArray<T>(lhs.dataSource + rhs.dataSource)
}

@inlinable
public func +=<T>(lhs: inout ConcurrentArray<T>, rhs: ConcurrentArray<T>) {
    rhs.dataSource.forEach({
        lhs.append($0)
    })
}

@inlinable
public func -<T: Equatable>(lhs: ConcurrentArray<T>, rhs: ConcurrentArray<T>) -> ConcurrentArray<T> {
    let toRemove = rhs.dataSource
    return ConcurrentArray<T>(lhs.dataSource.filter({
        !toRemove.contains($0)
    }))
}

@inlinable
public func -=<T: Equatable>(lhs: inout ConcurrentArray<T>, rhs: ConcurrentArray<T>) {
    rhs.dataSource.forEach({
        lhs.remove($0)
    })
}

public extension ConcurrentArray where T: Equatable {

    @inlinable @discardableResult
    func remove(_ element: T) -> Bool {
        exclusiveReturn({
            let count = self._dataSource.count
            self._dataSource = self._dataSource.filter { $0 != element }
            let removed = count - self._dataSource.count
            return removed > 0
        })
    }

    /// Searches the collection and adds the element if it does not yet exist
    ///
    /// - parameter element: The element to append and check against the collection
    /// - parameter replacing: A boolean, true if you want to replace the equal existing element (if found) with the supplied one
    /// - returns: Tuple where new (Bool) is if added for the first time, replaced (Bool) if it had already existed and was replaced,
    ///          and memberAfterAppend returns either the input element, or (if found) the existing one.
    ///
    @inlinable @discardableResult
    func addIfAbsent(_ element: T, replacing: Bool = false) -> (new: Bool, replaced: Bool, memberAfterAppend: T) {
        exclusiveReturn({
            if let index = _dataSource.firstIndex(of: element) {
                if replacing {
                    let previous = self._dataSource[index]
                    self._dataSource.remove(at: index)
                    self._dataSource.insert(element, at: index)
                    return (false, true, previous)
                }
                return (false, false, _dataSource[index])
            } else {
                self._dataSource.append(element)
                return (true, false, element)
            }
        })
    }
}
