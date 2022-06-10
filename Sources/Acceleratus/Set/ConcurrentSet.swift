//
//  ConcurrentSet.swift
//
//  Created by Chris Scalcucci on 8/17/20.
//

import Foundation
import AcceleratusObjCXX

/// An ordered set is an ordered collection of instances of `Element` in which
/// uniqueness of the objects is guaranteed.
public class ConcurrentSet<E: Hashable>: ConcurrentObject,
                                         Equatable,
                                         ExpressibleByArrayLiteral {
    public typealias Element = E

    public private(set) var mutex = SharedRecursiveMutex()

    // Do not set these properties from outside the class
    public var set: Set<Element>

    //
    // MARK: Initialization
    //

    public required init() {
        self.set = Set()
    }

    public convenience required init<S>(_ elements: S) where S: Sequence, S.Element == Element {
        self.init()
        self.insert(contentsOf: elements)
    }

    public init(_ set: OrderedSet<E>) {
        self.set = set.set
    }

    public init(_ concurrentSet: ConcurrentOrderedSet<E>) {
        self.set = concurrentSet.set
    }

    public convenience required init(arrayLiteral elements: Element...) {
        self.init(elements)
    }

    //
    // MARK: Get-Only
    //

    @inlinable
    public var copy : Self {
        sharedReturn({
            return Self(self.set)
        })
    }

    @inlinable
    public var count: Int {
        sharedReturn({
            self.set.count
        })
    }

    @inlinable
    public var isEmpty: Bool {
        sharedReturn({
            self.set.isEmpty
        })
    }

    @inlinable
    public var contents: [Element] {
        sharedReturn({
            return Array<Element>(self.set)
        })
    }

    @inlinable
    public func contains(_ member: Element) -> Bool {
        sharedReturn({
            self.set.contains(member)
        })
    }

    //
    // MARK: Mutators
    //

    @inlinable
    public func remove<S>(_ elements: S) where S: Sequence, S.Element == Element  {
        exclusiveAction({
            self.set.removeAll(elements)
        })
    }

    @inlinable @discardableResult
    public func remove(_ fn: (E) throws -> Bool) rethrows -> Bool {
        try exclusiveReturn({
            let count = self.set.count
            try self.set = self.set.filter({ try !fn($0) })
            return self.set.count != count
        })
    }

    /// Remove all elements and clear capacity
    @inlinable
    public func removeAll() {
        exclusiveAction({
            self.set.removeAll(keepingCapacity: false)
        })
    }

    /// Remove all elements.
    @inlinable
    public func removeAll(keepingCapacity keepCapacity: Bool) {
        exclusiveAction({
            self.set.removeAll(keepingCapacity: keepCapacity)
        })
    }

    @inlinable
    public func filter(_ fn: (E) throws -> Bool) rethrows -> Set<E> {
        try exclusiveReturn({
            return try self.set.filter(fn)
        })
    }

    @inlinable
    public func removing(_ element: Element) -> ConcurrentSet<E> {
        exclusiveReturn({
            self.remove(element)
            return self
        })
    }

    @inlinable
    public func inserting(_ element: Element) -> ConcurrentSet<E> {
        exclusiveReturn({
            self.insert(element)
            return self
        })
    }

    /**
     Inserts the given element into the set unconditionally at the end.

     - parameter newElement: An element to insert into the set.
     - returns: The OrderedSet
     */
    @inlinable
    public func updating(_ newElement: Element) -> ConcurrentSet<E> {
        exclusiveReturn({
            self.update(newElement)
            return self
        })
    }

    //
    // MARK: High-Order
    //

    @inlinable
    public func first(where predicate: (Element) throws -> Bool) rethrows -> Element? {
        try sharedReturn({
            return try self.set.first(where: predicate)
        })
    }

    @inlinable
    public func forEach(_ fn: (Element) throws -> ()) rethrows {
        try sharedAction({
            let tmp = self.set

            for i in tmp {
                try fn(i)
            }
        })
    }

    @inlinable
    public func reduce<X>(_ initialResult: X, _ nextPartialResult: (X, Element) throws -> X) rethrows -> X {
        try sharedReturn({
            return try self.set.reduce(initialResult, nextPartialResult)
        })
    }

    @inlinable
    public func reduce<X>(into initialResult: X, _ updateAccumulatingResult: (inout X, Element) throws -> ()) rethrows -> X {
        try sharedReturn({
            return try self.set.reduce(into: initialResult, updateAccumulatingResult)
        })
    }

    @inlinable
    public func filter(_ fn: (Element) throws -> Bool) rethrows -> [Element] {
        try sharedReturn({
            return try self.set.filter(fn)
        })
    }

    @inlinable
    public func map<X>(_ fn: (Element) throws -> X) rethrows -> [X] {
        try sharedReturn({
            return try self.set.map(fn)
        })
    }

    @inlinable
    public func compactMap<X>(_ fn: (Element) throws -> X?) rethrows -> [X] {
        try sharedReturn({
            return try self.set.compactMap(fn)
        })
    }
}

//
// MARK: Set Methods
//

extension ConcurrentSet {

    @inlinable @discardableResult
    public func insert(_ newMember: Element) -> (inserted: Bool, memberAfterInsert: Element) {
        exclusiveReturn({
            return self.set.insert(newMember)
        })
    }

    @inlinable
    public func insert<S>(contentsOf elements: S) where S: Sequence, S.Element == Element {
        exclusiveReturn({
            elements.forEach({
                self.set.insert($0)
            })
        })
    }

    /// Removes the element from the ordered set.
    ///
    /// - returns: The existing element if there was one, or nil
    @inlinable @discardableResult
    public func remove(_ member: Element) -> Element? {
        exclusiveReturn({
            return self.set.remove(member)
        })
    }

    /// Removes the element from the ordered set.
    ///
    /// - returns: The existing element if there was one, or nil
    @inlinable
    public func removeAll(where shouldBeRemoved: (Element) throws -> Bool) rethrows {
        try exclusiveAction({
            try self.set = self.set.filter({ try !shouldBeRemoved($0) })
        })
    }

    /**
     Inserts the given element into the set unconditionally.

     - parameter newElement: An element to insert into the set.

     - returns: For ordinary sets, an element equal to newMember if the set already contained such a member; otherwise, nil. In some cases, the      returned element may be distinguishable from newMember by identity comparison or some other means.
     For sets where the set type and element type are the same, like OptionSet types, this method returns any intersection between the set and [newMember], or nil if the intersection is empty.
     */
    @inlinable @discardableResult
    public func update(with newMember: Element) -> Element? {
        exclusiveReturn({
            return self.set.update(with: newMember)
        })
    }

    @inlinable @discardableResult
    public func update(_ newMember: Element) -> Element? {
        return self.update(with: newMember)
    }

    @inlinable
    public func union(_ other: ConcurrentSet<E>) -> ConcurrentSet<E> {
        let orderedSet = self.copy
        orderedSet.formIntersection(other)
        return orderedSet
    }

    @inlinable
    public func subtract(_ other: ConcurrentSet<E>) -> ConcurrentSet<E> {
        let orderedSet = self.copy
        orderedSet.subtracting(other)
        return orderedSet
    }

    @inlinable
    public func intersection(_ other: ConcurrentSet<E>) -> ConcurrentSet<E> {
        let orderedSet = self.copy
        orderedSet.formIntersection(other)
        return orderedSet
    }

    @inlinable
    public func symmetricDifference(_ other: ConcurrentSet<E>) -> ConcurrentSet<E> {
        let orderedSet = self.copy
        orderedSet.formSymmetricDifference(other)
        return orderedSet
    }

    @inlinable
    public func formUnion(_ other: ConcurrentSet<E>) {
        exclusiveAction({
            other.set.forEach({ insert($0) })
        })
    }

    @inlinable
    public func formIntersection(_ other: ConcurrentSet<E>) {
        self.removeAll(where: { !other.contains($0) })
    }

    @inlinable
    public func subtracting(_ other: ConcurrentSet<E>) {
        self.removeAll(where: { other.contains($0) })
    }

    @inlinable
    public func formSymmetricDifference(_ other: ConcurrentSet<E>) {
        exclusiveAction({
            self.set.formSymmetricDifference(other.set)
        })
    }
}

// Conformance for AdditiveArithmetic, can't formally
// conform because Apple defined += and -= with Self constraints
// instead of redirecting through an associated type of Self
extension ConcurrentSet /*: AdditiveArithmetic*/ {
    public static var zero: Self { .init() }

    @inlinable
    public static func +<E: Hashable>(lhs: ConcurrentSet<E>, rhs: ConcurrentSet<E>) -> ConcurrentSet<E> {
        return ConcurrentSet<E>(lhs.set.union(rhs.set))
    }

    @inlinable
    public static func +=<E: Hashable>(lhs: inout ConcurrentSet<E>, rhs: ConcurrentSet<E>) {
        lhs.insert(contentsOf: rhs.set)
    }

    @inlinable
    public static func -<E: Hashable>(lhs: ConcurrentSet<E>, rhs: ConcurrentSet<E>) -> ConcurrentSet<E> {
        return ConcurrentSet<E>(Array(lhs.set.subtracting(rhs.set)))
    }

    @inlinable
    public static func -=<E: Hashable>(lhs: inout ConcurrentSet<E>, rhs: ConcurrentSet<E>) {
        lhs.remove(rhs.set)
    }

    @inlinable
    public func isEqual(_ rhs: ConcurrentSet<Element>) -> Bool {
        sharedReturn({
            return rhs.isEqual(self.set)
        })
    }

    @inlinable
    public func isEqual(_ rhs: Set<Element>) -> Bool {
        sharedReturn({
            return self.set == rhs
        })
    }
}

@inlinable
public func ==<T>(lhs: ConcurrentSet<T>,
                  rhs: ConcurrentSet<T>) -> Bool {
    return lhs.isEqual(rhs)
}

extension ConcurrentSet: Hashable where Element: Hashable {
    @inlinable
    public func hash(into hasher: inout Hasher) {
        sharedReturn({
            hasher.combine(self.set)
        })
    }
}
