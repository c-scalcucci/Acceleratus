//
//  OrderedSet.swift
//
//  Created by Chris Scalcucci on 5/6/20.
//

import Foundation

/// An ordered set is an ordered collection of instances of `Element` in which
/// uniqueness of the objects is guaranteed.
public class OrderedSet<E: Hashable>: Equatable,
                                      Collection,
                                      ExpressibleByArrayLiteral,
                                      RandomAccessCollection,
                                      RangeReplaceableCollection,
                                      MutableCollection {
    public typealias Element = E
    public typealias Index = Int
    public typealias Indices = Range<Int>
    public typealias SubSequence = Slice<OrderedSet<E>>
    public typealias Iterator = IndexingIterator<OrderedSet>

    // Do not set these properties from outside the class
    public var indexes : [E:Int]
    public var array: [Element]
    public var set: Set<Element>

    public var insertOrder : InsertOrder<E> {
        willSet {
            switch self.insertOrder {
            case .insertSort:
                switch newValue {
                case .temporal:
                    fatalError("Cannot switch to temporal from insertSort")
                case .insertSort(let fn):
                    self.array = self.array.sorted(by: fn)
                    self.indexes.removeAll()
                    self.array.enumerated().forEach({ index, element in
                        self.indexes[element] = index
                    })
                }
            case .temporal:
                switch newValue {
                case .temporal:
                    break
                case .insertSort(let fn):
                    self.array = self.array.sorted(by: fn)
                    self.indexes.removeAll()
                    self.array.enumerated().forEach({ index, element in
                        self.indexes[element] = index
                    })
                }
            }
        }
    }

    //
    // MARK: Initialization
    //

    public convenience required init() {
        self.init(.temporal)
    }

    /// Creates an empty ordered set.
    public init(_ insertOrder: InsertOrder<E>) {
        self.indexes = [:]
        self.array = []
        self.set = Set()
        self.insertOrder = insertOrder
    }

    public convenience required init<S>(_ elements: S) where S: Sequence, S.Element == Element {
        self.init()
        self.append(contentsOf: elements)
    }

    public init(_ set: OrderedSet<E>) {
        self.insertOrder = set.insertOrder
        self.indexes = set.indexes
        self.set = set.set
        self.array = set.array
    }

    public init(_ concurrentSet: ConcurrentOrderedSet<E>) {
        self.insertOrder = concurrentSet.insertOrder
        self.indexes = concurrentSet.indexes
        self.set = concurrentSet.set
        self.array = concurrentSet.array
    }

    public convenience required init(arrayLiteral elements: Element...) {
        self.init(elements)
    }

    public convenience init(slice: Array<Element>.SubSequence) {
        self.init()
        self.append(contentsOf: slice)
    }

    public convenience init<S>(_ elements: S,
                               _ insertOrder: InsertOrder<E>) where S: Sequence, S.Element == Element {
        self.init(insertOrder)
        self.append(contentsOf: elements)
    }

    public convenience init(_ array: [Element],
                            _ insertOrder: InsertOrder<E> = .temporal) {
        self.init(insertOrder)
        self.append(contentsOf: array)
    }

    public convenience init(_ set: Set<Element>,
                            _ insertOrder: InsertOrder<E> = .temporal) {
        self.init(insertOrder)
        self.append(contentsOf: set)
    }

    //
    // MARK: Subscripts
    //

    // Generic subscript to support `PartialRangeThrough`, `PartialRangeUpTo`, `PartialRangeFrom` and `FullRange`
    @inlinable
    public subscript<R>(r: R) -> OrderedSet<E>.SubSequence where R : RangeExpression, OrderedSet<E>.Index == R.Bound {
        return SubSequence(self.array[r])
    }

    @inlinable
    public subscript(bounds: Range<OrderedSet<E>.Index>) -> OrderedSet<E>.SubSequence {
        return SubSequence(self.array[bounds])
    }

    @inlinable
    public subscript(position: OrderedSet<E>.Index) -> OrderedSet<E>.Element {
        get {
            self.array[position]
        } set {
            self.set(newValue, at: position)
        }
    }

    @inlinable
    public subscript(x: (UnboundedRange_) -> ()) -> OrderedSet<E>.SubSequence {
        return SubSequence(self.array[x])
    }

    @inlinable
    public func set(_ element: Element, at position: Index) {
        guard let _ = self.set.update(with: element) else { return }
        self.array[position] = element
        self.indexes[element] = position
    }

    //
    // MARK: Range
    //

    @inlinable
    public var copy : Self {
        return Self(self.array)
    }

    @inlinable
    public var startIndex: Int {
        return self.array.startIndex
    }

    @inlinable
    public var endIndex: Int {
        return self.array.endIndex
    }

    @inlinable
    public func formIndex(after i: inout Index) {
        self.array.formIndex(after: &i)
    }

    @inlinable
    public func replaceSubrange<C: Collection, R: RangeExpression>(_ subrange: R, with newElements: C) where Element == C.Element, Index == R.Bound {
        self.array[subrange].forEach({
            self.indexes.removeValue(forKey: $0)
            self.set.remove($0)
        })

        self.array.replaceSubrange(subrange, with: newElements)
        newElements.forEach({
            if let index = self.array.firstIndex(of: $0) {
                self.indexes[$0] = index
                self.set.insert($0)
            }
        })
    }

    //
    // MARK: Get-Only
    //

    @inlinable
    public var count: Int {
        self.array.count
    }

    @inlinable
    public var isEmpty: Bool {
        self.array.isEmpty
    }

    @inlinable
    public var contents: [Element] {
        return Array<Element>(self.array)
    }

    @inlinable
    public func contains(_ member: Element) -> Bool {
        self.set.contains(member)
    }

    @inlinable
    public func index(of e: Element) -> Int? {
        return self.indexes[e]
    }

    @inlinable
    public func index(where fn: (Element) throws -> Bool) rethrows -> Int? {
        for element in self.array {
            if try fn(element) {
                return self.indexes[element]
            }
        }
        return nil
    }

    //
    // MARK: Mutators
    //

    @inlinable
    public func append(_ elements: [Element]) {
        self.append(contentsOf: elements)
    }

    @inlinable
    public func append<S>(contentsOf newElements: S) where S : Sequence, E == S.Element {
        switch self.insertOrder {
        case .temporal:
            newElements.forEach({
                if self.set.insert($0).inserted {
                    self.array.append($0)
                    self.indexes[$0] = self.array.count - 1
                }
            })
        case .insertSort(fn: let fn):
            let originalCount = self.set.count

            self.set.formUnion(newElements)

            if originalCount < self.set.count {
                self.array = Array(self.set).sorted(by: fn)
                self.indexes.removeAll()
                self.array.enumerated().forEach({ index, element in
                    self.indexes[element] = index
                })
            }
        }
    }

    @inlinable
    public func append(_ newElement: Element) {
        let inserted = self.set.insert(newElement).inserted

        switch self.insertOrder {
        case .temporal:
            if inserted {
                self.array.append(newElement)
                self.indexes[newElement] = self.array.count - 1
            }
        case .insertSort(let fn):
            if inserted {
                self.array.append(newElement)
                self.array = self.array.sorted(by: fn)
                self.indexes.removeAll()
                self.array.enumerated().forEach({ index, element in
                    self.indexes[element] = index
                })
            }
        }
    }

    @inlinable
    public func remove(_ elements: [OrderedSet<E>.Element]) {
        var removed : Bool = false
        elements.forEach({
            if let _ = self.set.remove($0) {
                self.array.removeFirstPresent($0)
                removed = true
            }
        })

        if removed {
            self.array.enumerated().forEach({ index, element in
                self.indexes[element] = index
            })
        }
    }

    @inlinable @discardableResult
    public func remove(at index: Int) -> E? {
        guard self.array.count > index else {
            return nil
        }
        let removed = self.array.remove(at: index)
        self.indexes.removeAll()
        self.array.enumerated().forEach({ index, element in
            self.indexes[element] = index
        })
        self.set.remove(removed)
        return removed
    }

    @inlinable @discardableResult
    public func remove(_ fn: (E) -> Bool) -> Bool {
        guard let found = self.array.first(where: { fn($0) }) else {
            return false
        }

        if let index = self.indexes.removeValue(forKey: found) {
            self.array.remove(at: index)
            self.indexes.removeAll()
            self.array.enumerated().forEach({ index, element in
                self.indexes[element] = index
            })
        } else {
            self.array.removeEqual(found)
            self.indexes.removeAll()
            self.array.enumerated().forEach({ index, element in
                self.indexes[element] = index
            })
        }
        self.set.remove(found)
        return true
    }

    /// Remove and return the element at the beginning of the ordered set.
    @inlinable @discardableResult
    public func removeFirst() -> Element {
        let firstElement = self.array.removeFirst()
        self.indexes.removeValue(forKey: firstElement)
        self.set.remove(firstElement)
        return firstElement
    }

    /// Remove and return the element at the end of the ordered set.
    @inlinable @discardableResult
    public func removeLast() -> Element {
        let lastElement = self.array.removeLast()
        self.indexes.removeValue(forKey: lastElement)
        self.set.remove(lastElement)
        return lastElement
    }

    /// Remove all elements and clear capacity
    @inlinable
    public func removeAll() {
        self.indexes.removeAll(keepingCapacity: false)
        self.array.removeAll(keepingCapacity: false)
        self.set.removeAll(keepingCapacity: false)
    }

    /// Remove all elements.
    @inlinable
    public func removeAll(keepingCapacity keepCapacity: Bool) {
        self.indexes.removeAll(keepingCapacity: keepCapacity)
        self.array.removeAll(keepingCapacity: keepCapacity)
        self.set.removeAll(keepingCapacity: keepCapacity)
    }

    /// Adds an element to the ordered set.
    ///
    /// If it already contains the element, then the element is removed and force appended at the end.
    ///
    /// - returns: True if the item was inserted.
    @inlinable @discardableResult
    public func forceAppend(_ newElement: Element) -> Bool {
        let inserted = self.set.insert(newElement).inserted
        if inserted {
            self.array.append(newElement)
            self.indexes[newElement] = array.count - 1
        } else {
            if let index = self.indexes[newElement] {
                self.array.remove(at: index)
                self.indexes.removeAll()
                self.array.enumerated().forEach({ index, element in
                    self.indexes[element] = index
                })
                self.set.remove(newElement)
            }
            self.append(newElement)
            return true
        }
        return inserted
    }

    /// Adds an element to the ordered set.
    ///
    /// If it already contains the element, then the element is removed and force appended at the end.
    ///
    /// - returns: The OrderedSet
    @inlinable
    public func forceAppending(_ newElement: Element) -> OrderedSet {
        self.forceAppend(newElement)
        return self
    }

    @inlinable @discardableResult
    public func updateInPlace(_ newElement: Element) -> Element? {
        if let index = self.array.firstIndex(of: newElement) {
            if self.set.remove(newElement) != nil {
                self.array.remove(at: indexes[newElement]!)
            }

            self.array.insert(newElement, at: index)
            self.indexes[newElement] = index
        } else {
            self.array.append(newElement)
            self.indexes[newElement] = array.count - 1
        }

        return set.update(with: newElement)
    }

    @inlinable
    public func updatingInPlace(_ newElement: Element) -> OrderedSet {
        self.updateInPlace(newElement)
        return self
    }

    @inlinable
    public func adding(_ newElement: Element) -> OrderedSet {
        self.append(newElement)
        return self
    }

    @inlinable
    public func removing(_ element: Element) -> OrderedSet {
        self.remove(element)
        return self
    }

    @inlinable
    public func inserting(_ element: Element) -> OrderedSet {
        self.insert(element)
        return self
    }

    /**
     Inserts the given element into the set unconditionally at the end.

     - parameter newElement: An element to insert into the set.
     - returns: The OrderedSet
     */
    @inlinable
    public func updating(_ newElement: Element) -> OrderedSet {
        self.update(newElement)
        return self
    }

    //
    // MARK: High-Order
    //

    @inlinable
    public func first(where predicate: (Element) throws -> Bool) rethrows -> Element? {
        return try self.array.first(where: predicate)
    }

    @inlinable
    public func forEach(_ fn: (Element) throws -> ()) rethrows {
        let tmp = self.array

        for i in tmp {
            try fn(i)
        }
    }

    @inlinable
    public func reduce<X>(_ initialResult: X, _ nextPartialResult: (X, Element) throws -> X) rethrows -> X {
        return try self.array.reduce(initialResult, nextPartialResult)
    }

    @inlinable
    public func reduce<X>(into initialResult: X, _ updateAccumulatingResult: (inout X, Element) throws -> ()) rethrows -> X {
        return try self.array.reduce(into: initialResult, updateAccumulatingResult)
    }

    @inlinable
    public func filter(_ fn: (Element) throws -> Bool) rethrows -> [Element] {
        return try self.array.filter(fn)
    }

    @inlinable
    public func map<X>(_ fn: (Element) throws -> X) rethrows -> [X] {
        return try self.array.map(fn)
    }

    @inlinable
    public func compactMap<X>(_ fn: (Element) throws -> X?) rethrows -> [X] {
        return try self.array.compactMap(fn)
    }
}

//
// MARK: Set Methods
//

extension OrderedSet {

    @inlinable
    public func insert(_ newElement: OrderedSet<E>.Element, at i: OrderedSet<E>.Index) {
        self.insert(newElement, i)
    }

    @inlinable
    public func insert(_ newElement: Element, _ index: Int) {
        switch self.insertOrder {
        case .temporal:
            if self.set.remove(newElement) != nil {
                self.array.remove(at: self.indexes[newElement]!)
            }
            self.array.insert(newElement, at: index)
            self.indexes.removeAll()
            self.array.enumerated().forEach({ index, element in
                self.indexes[element] = index
            })
            self.set.insert(newElement)
        case .insertSort:
            preconditionFailure("OrderedSet does not support inserting at an index when type is insertSort!")
        }
    }

    @inlinable @discardableResult
    public func insert(_ newMember: OrderedSet<Element>.Element) -> (inserted: Bool, memberAfterInsert: OrderedSet<Element>.Element) {
        let insertAction = self.set.insert(newMember)

        // If the object was already present, has no effect
        guard insertAction.inserted else { return insertAction }

        switch self.insertOrder {
        case .temporal:
            self.array.append(newMember)
            self.array.enumerated().forEach({ index, element in
                self.indexes[element] = index
            })
            return insertAction
        case .insertSort(let fn):
            self.array.append(newMember)
            self.array = array.sorted(by: fn)
            self.indexes.removeAll()
            self.array.enumerated().forEach({ index, element in
                self.indexes[element] = index
            })
            return insertAction
        }
    }

    /// Removes the element from the ordered set.
    ///
    /// - returns: The existing element if there was one, or nil
    @inlinable @discardableResult
    public func remove(_ member: Element) -> Element? {
        guard let removed = self.set.remove(member) else { return nil }

        self.array.remove(at: self.indexes[member]!)
        self.indexes.removeAll()
        self.array.enumerated().forEach({ index, element in
            self.indexes[element] = index
        })

        return removed
    }

    /// Removes the element from the ordered set.
    ///
    /// - returns: The existing element if there was one, or nil
    @inlinable
    public func removeAll(where shouldBeRemoved: (Element) throws -> Bool) rethrows {
        let count = self.array.count
        try self.set = self.set.filter({ try !shouldBeRemoved($0) })
        try self.array = self.array.filter({ try !shouldBeRemoved($0) })

        if count != self.array.count {
            self.indexes.removeAll()
            self.array.enumerated().forEach({ index, element in
                self.indexes[element] = index
            })
        }
    }

    /**
     Inserts the given element into the set unconditionally.

     - parameter newElement: An element to insert into the set.

     - returns: For ordinary sets, an element equal to newMember if the set already contained such a member; otherwise, nil. In some cases, the      returned element may be distinguishable from newMember by identity comparison or some other means.
     For sets where the set type and element type are the same, like OptionSet types, this method returns any intersection between the set and [newMember], or nil if the intersection is empty.
     */
    @inlinable @discardableResult
    public func update(with newMember: Element) -> Element? {
        if self.set.remove(newMember) != nil {
            self.array.remove(at: self.indexes[newMember]!)
        }

        switch self.insertOrder {
        case .temporal:
            self.array.append(newMember)
            self.indexes.removeAll()
            self.array.enumerated().forEach({ index, element in
                self.indexes[element] = index
            })
            return self.set.update(with: newMember)
        case .insertSort(let fn):
            self.array.append(newMember)
            self.array = array.sorted(by: fn)
            self.indexes.removeAll()
            self.array.enumerated().forEach({ index, element in
                self.indexes[element] = index
            })
            return self.set.update(with: newMember)
        }
    }

    @inlinable @discardableResult
    public func update(_ newMember: Element) -> Element? {
        return self.update(with: newMember)
    }

    @inlinable
    public func union(_ other: OrderedSet<E>) -> Self {
        let orderedSet = self.copy
        orderedSet.formIntersection(other)
        return orderedSet
    }

    @inlinable
    public func subtract(_ other: OrderedSet<E>) -> Self {
        let orderedSet = self.copy
        orderedSet.subtracting(other)
        return orderedSet
    }

    @inlinable
    public func intersection(_ other: OrderedSet<E>) -> Self {
        let orderedSet = self.copy
        orderedSet.formIntersection(other)
        return orderedSet
    }

    @inlinable
    public func symmetricDifference(_ other: OrderedSet<E>) -> Self {
        let orderedSet = self.copy
        orderedSet.formSymmetricDifference(other)
        return orderedSet
    }

    @inlinable
    public func formUnion(_ other: OrderedSet<E>) {
        other.array.forEach({ append($0) })
    }

    @inlinable
    public func formIntersection(_ other: OrderedSet<E>) {
        self.removeAll(where: { !other.contains($0) })
    }

    @inlinable
    public func subtracting(_ other: OrderedSet<E>) {
        self.removeAll(where: { other.contains($0) })
    }

    @inlinable
    public func formSymmetricDifference(_ other: OrderedSet<Element>) {
        var newSet = Set<Element>()
        var newArray = [Element]()
        var changed = false

        // Find elements in my set that aren't in the other set
        // Use array to maintain order
        self.array.forEach({
            if !other.set.contains($0) {
                // Retain this element
                newSet.insert($0)
                newArray.append($0)
            } else {
                // Remove this element
                changed = true
            }
        })

        // Find elements in the other set that aren't in my set
        other.set.forEach({
            if !self.set.contains($0) {
                // Retain this element
                newSet.insert($0)
                newArray.append($0)
            } else {
                // Remove this element
                changed = true
            }
        })

        self.set = newSet
        self.array = newArray

        if changed {
            // Rebuild the indexes
            self.indexes.removeAll()
            self.array.enumerated().forEach({ index, element in
                self.indexes[element] = index
            })
        }
    }
}

// Conformance for AdditiveArithmetic, can't formally
// conform because Apple defined += and -= with Self constraints
// instead of redirecting through an associated type of Self
extension OrderedSet /*: AdditiveArithmetic*/ {
    public static var zero: Self { .init() }

    @inlinable
    public static func +<E: Hashable>(lhs: OrderedSet<E>, rhs: OrderedSet<E>) -> OrderedSet<E> {
        return OrderedSet<E>(lhs.array + rhs.array, lhs.insertOrder)
    }

    @inlinable
    public static func +=<E: Hashable>(lhs: inout OrderedSet<E>, rhs: OrderedSet<E>) {
        lhs.append(rhs.array)
    }

    @inlinable
    public static func -<E: Hashable>(lhs: OrderedSet<E>, rhs: OrderedSet<E>) -> OrderedSet<E> {
        return OrderedSet<E>(Array(lhs.set.subtracting(rhs.set)), lhs.insertOrder)
    }

    @inlinable
    public static func -=<E: Hashable>(lhs: inout OrderedSet<E>, rhs: OrderedSet<E>) {
        lhs.remove(rhs.array)
    }

    @inlinable
    public func isEqual(_ rhs: OrderedSet<Element>) -> Bool {
        return rhs.isEqual(self.array)
    }

    @inlinable
    public func isEqual(_ rhs: Array<Element>) -> Bool {
        return self.array == rhs
    }
}

@inlinable
public func ==<T>(lhs: OrderedSet<T>,
                  rhs: OrderedSet<T>) -> Bool {
    return lhs.isEqual(rhs)
}

extension OrderedSet: Hashable {
    @inlinable
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.array)
    }
}
