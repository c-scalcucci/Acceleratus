//
//  Collection+Extension.swift
//  
//
//  Created by Chris Scalcucci on 3/16/22.
//

import Foundation

public extension Collection {
    @inlinable
    subscript(safe index: Index) -> Iterator.Element? {
        return self.indices.contains(index) ? self[index] : nil
    }
}

public extension Set {
    @inlinable
    mutating func removeFirst(where fn: (Element) -> Bool) {
        var found : Element?
        for e in self {
            if fn(e) {
                found = e
                break
            }
        }

        if let found = found {
            self.remove(found)
        }
    }
}

public extension Array {

    @inlinable
    subscript(safe range: Range<Index>) -> ArraySlice<Element>? {
        if range.endIndex > endIndex {
            if range.startIndex >= endIndex {
                return nil

            } else {
                return self[range.startIndex..<endIndex]
            }
        } else {
            return self[range]
        }
    }

    /// Returns the array after having appended an element
    ///
    /// - parameter element: The element to add to the collection
    ///
    @inlinable @discardableResult
    mutating func adding(_ element: Element) -> Self {
        self.append(element)
        return self
    }

    @inlinable
    mutating func filterInPlace(_ isIncluded: (Element) throws -> Bool) rethrows {
        var writeIndex = self.startIndex
        var i = 0
        let c = indices.count

        while i < c {
            let readIndex = indices[i]
            let element = self[readIndex]
            let include = try isIncluded(element)
            if include {
                if writeIndex != readIndex {
                    self[writeIndex] = element
                }
                writeIndex = self.index(after: writeIndex)
            }
            i += 1
        }
        self.removeLast(self.distance(from: writeIndex, to: self.endIndex))
    }

    @inlinable
    mutating func removeFirst(where fn: (Element) -> Bool) {
        var i = 0

        while i < self.count {
            if fn(self[i]) {
                self.remove(at: i)
                return
            }
            i += 1
        }
    }
}

public extension Array where Element : Equatable {

    /// Returns the collection after having removed all instances of a provided element.
    ///
    @inlinable @discardableResult
    mutating func removing(_ element: Element) -> Self {
        self.removeFirstPresent(element)
        return self
    }

    /// Searches the collection and removes only the first instance of an equal element (if found)
    ///
    /// - parameter element: The element to append and check against the collection
    /// - returns: Tuple where removed (Bool) is true if an element was found and removed, and memberRemoved returns either the input element, or (if found) the existing element that was removed.
    ///
    @inlinable @discardableResult
    mutating func removeFirstPresent(_ element: Element) -> (removed: Bool, memberRemoved: Element) {
        var temp = self
        if let index = temp.firstIndex(of: element) {
            let item = temp[index]
            temp.remove(at: index)
            self = temp
            return (true, item)
        }
        return (false, element)
    }
}

public extension Array where Element: AnyObject  {
    /**
     Removes the first occurrence of the specified element from this list,
     if it is present.

     If this list does not contain the element, it is unchanged.

     More formally, removes the element with the lowest index, 'i', such that
     i === element.

     - parameter e: The element to be removed from this list, if present
     - returns: True if this list contained the specified element
     */
    @inlinable @discardableResult
    mutating func remove(_ e: Element) -> Bool {
        let originalCount = self.count
        self.removeAll(where: { $0 === e })

        return originalCount != self.count
    }

    /**
     Removes from this list all of its elements that are contained
     in the specified collection (optional operation).

     - parameter c: The collection containing elements to be removed from this list
     - returns: True if this list changed as a result of the call
     */
    @inlinable @discardableResult
    mutating func removeAll(_ c: [Element]) -> Bool {
        let originalCount = self.count

        c.forEach({ self.remove($0) })

        return originalCount != self.count
    }
}

public extension RangeReplaceableCollection where Element: Equatable {
    /// Searches the collection for an element and returns the Int value of the first index found
    ///
    /// - parameter element: The element to search against the collection
    /// - returns: The optional Integer value of the first index found
    ///
    @inlinable
    func indexDistance(_ element: Element) -> Int? {
        if let index = firstIndex(of: element) {
            return distance(from: startIndex, to: index)
        }
        return nil
    }

    /// Searches the collection and adds the element if it does not yet exist
    ///
    /// - parameter element: The element to append and check against the collection
    /// - parameter replacing: A boolean, true if you want to replace the equal existing element (if found) with the supplied one
    /// - returns: Tuple where new (Bool) is if added for the first time, replaced (Bool) if it had already existed and was replaced,
    ///          and memberAfterAppend returns either the input element, or (if found) the existing one.
    ///
    @inlinable @discardableResult
    mutating func addIfAbsent(_ element: Element,
                              replacing: Bool = false) -> (new: Bool, replaced: Bool, memberAfterAppend: Element) {
        if let index = firstIndex(of: element) {
            if replacing {
                let previous = self[index]
                remove(at: index)
                insert(element, at: index)
                return (false, true, previous)
            }
            return (false, false, self[index])
        } else {
            append(element)
            return (true, false, element)
        }
    }

    @inlinable @discardableResult
    mutating func addingIfAbsent(_ element: Element,
                                 _ replacing: Bool = false) -> Self {
        self.addIfAbsent(element, replacing: replacing)
        return self
    }

    /// Searches the collection and adds each element from the supplied array if it does not already exist in the collection.
    /// This prevents duplicates from being added, and ensures each element is unique.
    ///
    /// - parameter elements: The elements to add to the collection if they do not already exist there
    /// - returns: The number of elements added
    ///
    @inlinable @discardableResult
    mutating func addAllAbsent(_ elements: [Element],
                               replacing: Bool = false) -> Int {
        let originalCount = self.count

        elements.forEach({ addIfAbsent($0, replacing: replacing) })

        return self.count - originalCount
    }

    /// Returns the collection after having removed all instances of a provided element.
    ///
    @inlinable @discardableResult
    mutating func removing(_ element: Element?) -> Self {
        self.removeAllPresent(element)
        return self
    }


    /// Wrapper for self.removeFirstPresent
    ///
    /// Searches the collection and removes only the first instance of an equal element (if found)
    ///
    /// - parameter element: The element to append and check against the collection
    /// - returns: True if the element existed and was removed
    ///
    @inlinable @discardableResult
    mutating func removeIfPresent(_ element: Element) -> Bool {
        return removeFirstPresent(element).removed
    }

    /// Seaches the collection and removes all instances of each element in the supplied array if it exists.
    ///
    /// - parameter elements: The elements to check against the collection and removing where present
    /// - returns: A tuple where removed(Bool) is whether at least one element was removed, and amount(Int) is the total of all removed elements.
    ///
    @inlinable @discardableResult
    mutating func removeAllPresent(_ elements: [Element]) -> (removed: Bool, amount: Int) {
        let originalCount = self.count

        elements.forEach({ element in removeAll(where: { $0 == element }) })

        let removed = originalCount - self.count

        return (removed > 0, removed)
    }

    /// Searches the collection and removes the element if it exists
    ///
    /// - parameter element: The element to check against the collection and removing where present
    /// - returns: A boolean represe
    ///
    @inlinable @discardableResult
    mutating func removeAllPresent(_ element: Element?) -> (removed: Bool, amount: Int) {
        let originalCount = self.count

        self.removeAll(where: { $0 == element })

        let removed = originalCount - self.count
        return (removed > 0, removed)

    }

    /// Wrapper for self.removeFirstPresent
    ///
    /// Searches the collection and removes only the first instance of an equal element (if found)
    ///
    /// - parameter element: The element to append and check against the collection
    /// - returns: Tuple where removed (Bool) is true if an element was found and removed, and memberRemoved returns either the input element, or (if found) the existing element that was removed.
    ///
    @inlinable @discardableResult
    mutating func removeEqual(_ element: Element) -> (removed: Bool, memberRemoved: Element) {
        return removeFirstPresent(element)
    }

    /// Searches the collection and removes only the first instance of an equal element (if found)
    ///
    /// - parameter element: The element to append and check against the collection
    /// - returns: Tuple where removed (Bool) is true if an element was found and removed, and memberRemoved returns either the input element, or (if found) the existing element that was removed.
    ///
    @inlinable @discardableResult
    mutating func removeFirstPresent(_ element: Element) -> (removed: Bool, memberRemoved: Element) {
        if let index = firstIndex(of: element) {
            let item = self[index]
            remove(at: index)
            return (true, item)
        }
        return (false, element)
    }

    /// Searches the collection and removes only the last instance of an equal element (if found)
    ///
    /// - parameter element: The element to append and check against the collection
    /// - returns: Tuple where remove (Bool) is true if an element was found and removed, and memberRemoved returns either the input element, or (if found) the existing element that was removed.
    ///
    @inlinable @discardableResult
    mutating func removeLastPresent(_ element: Element) -> (removed: Bool, memberRemoved: Element) {
        if let index = self.reversed().indexDistance(element) {
            let inverted = self.index(startIndex, offsetBy: count - (index + 1))
            let item = self[inverted]
            remove(at: inverted)
            return (true, item)
        }
        return (false, element)
    }

    /**
     Returns true if this collection contains all of the elements
     of the specified collection.

     - parameter c: Collection to be checked for containment in this list
     - returns: True if this list contains all of the elements of tjhe
     specified collection
     */
    @inlinable
    func containsAll(_ c: [Element]) -> Bool {
        return c.allSatisfy(self.contains)
        // return self.allSatisfy(c.contains)
        /*
         c.forEach { if !self.contains($0) { return false }; return true
         */
    }
}

public extension Collection where Element : Hashable {
    @inlinable
    func containsAll(_ elements: [Element]) -> Bool {
        return Set(elements).isSubset(of: Set(self))
    }
}
