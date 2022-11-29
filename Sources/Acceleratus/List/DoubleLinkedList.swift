//
//  DoubleDoubleLinkedList.swift
//  
//
//  Created by Chris Scalcucci on 11/29/22.
//

import Foundation

public class DoubleLinkedList<T> : Collection {
    public typealias Element = T
    public typealias Index = Int
    public typealias Indices = Range<Int>
    public typealias Iterator = IndexingIterator<DoubleLinkedList>
    public typealias SubSequence = Slice<DoubleLinkedList<T>>

    public final class Node<T> {
        public var value: T
        public var next: Node?
        public weak var previous: Node?

        public init(value: T) {
            self.value = value
        }
    }

    public final class DoubleLinkedListIterator : IteratorProtocol {
        public var current : Node<T>?

        public init(start: Node<T>?) {
            self.current = start
        }

        public func next() -> Node<T>? {
            let node = self.current
            self.current = self.current?.next
            return node
        }
    }

    //
    // MARK: Properties
    //

    public var head: Node<Element>?

    public var tail : Node<Element>?

    /// The number of elements in the collection
    public var count: Int = 0

    /// Computed property to check if the linked list is empty
    @inlinable public var isEmpty: Bool {
        return head == nil
    }

    //
    // MARK: Initialization
    //

    /// Default initializer
    public init() {}

    public convenience init(array: Array<T>) {
        self.init()

        array.forEach { append($0) }
        count = array.count
    }

    public convenience init(arrayLiteral elements: T...) {
        self.init()

        elements.forEach { append($0) }
        count = elements.count
    }

    //
    // MARK: Collection
    //

    /**
     Accesses the element at the specified position

     - parameter position: The position to subscript
     - returns: The element at the specified position
     */
    @inlinable public subscript(position: Index) -> Element {
        get {
            return self.node(at: position).value
        } set {
            self.insert(newValue, at: position)
        }
    }

    /**
     Removes and returns the first element of the collection

     - returns: The first element if it exists
     */
    @inlinable public func popFirst() -> Element? {
        guard self.count > 1 else { return nil }

        return self.remove(at: 0)
    }

    /**
     Removes and returns the first element of the collection

     Throws an error if the collection is empty

     - returns: the first element if it exists
     */
    @inlinable public func removeFirst() -> Element {
        assert(self.count >= 1)

        return self.remove(at: 0)
    }

    /**
     Removes and returns the specified number of elements from
     the beginning of the collection

     Throws an error if the number is out of bounds
     */
    @inlinable public func removeFirst(_ k: Int) {
        assert(self.count >= k)

        for i in 0..<k {
            self.remove(at: i)
        }
    }

    /**
     Removes and returns the last element of the collection

     Throws an error if the collection is empty

     - returns: the last element if it exists
     */
    @inlinable @discardableResult public func removeLast() -> Element {
        assert(self.count >= 1)

        let node : Node<T>? = tail

        tail?.previous?.next = nil
        tail = nil

        return node!.value
    }

    /**
     The position of the first element in a nonempty collection
     */
    @inlinable public var startIndex : Index {
        return 0
    }

    /**
     The collection's "past the end" position - that is, the position
     one greater than the last valid subscript argument
     */
    @inlinable public var endIndex : Index {
        return self.count
    }

    /**
     The indices that are valid for subscripting the collection, in ascending order.
     */
    @inlinable public var indices : Indices {
        return 0..<count
    }

    /**
     Returns the position immediately after the given index
     */
    @inlinable public func index(after i: Index) -> Index {
        return i + 1
    }

    /**
     Offsets the given index by the specified distance
     */
    @inlinable public func formIndex(_ i: inout Index,
                                     offsetBy distance: Index) {
        i += distance
    }

    /**
     Offsets the given index by the specified distance, or so that it equals the given limiting index.
     */
    @inlinable public func formIndex(_ i: inout Int,
                                     offsetBy distance: Int,
                                     limitedBy limit: Int) -> Bool {
        i = Swift.min(i + distance, limit)
        return i != limit
    }

    /**
     Returns an iterator over the elements of the collection.
     */
    @inlinable public func makeIterator() -> DoubleLinkedListIterator {
        return DoubleLinkedListIterator(start: head)
    }

    /**
        The first element of the collection
     */
    @inlinable public var first : Element? {
        return self.head?.value
    }

    /**
        The last element of the collection
     */
    @inlinable public var last : Element? {
        return self.tail?.value
    }

    /**
     Returns the distance between two indices.
     */
    @inlinable public func distance(from start: Index, to end: Index) -> Int {
        return end - start
    }

    //
    // MARK: Accessors
    //

    /// Function to return the node at a specific index. Crashes if index is out of bounds (0...self.count)
    ///
    /// - Parameter index: Integer value of the node's index to be returned
    /// - Returns: Node
    @inlinable
    public func node(at index: Index) -> Node<Element> {
        assert(index >= 0, "Index must be greater or equal to 0")
        assert(count > index, "Index out of bounds")

        if index == 0 {
            return head!
        } else {
            var node = head!.next
            var i = 0

            while i < index {
                node = node?.next
                i += 1
            }

            return node!
        }
    }

    /// Append a value to the end of the list
    ///
    /// - Parameter value: The data value to be appended
    @inlinable
    public func append(_ value: T) {
        let newNode = Node(value: value)
        append(newNode)
    }

    /// Append a copy of a Node to the end of the list.
    ///
    /// - Parameter node: The node containing the value to be appended
    @inlinable
    public func append(_ node: Node<Element>) {
        let newNode = node

        // There is a tail, append to it
        if let lastNode = tail {
            lastNode.next = newNode
            newNode.previous = lastNode
            tail = newNode
        } else {
            head = newNode
            tail = newNode
        }

        count += 1
    }

    /// Append a copy of a DoubleLinkedList to the end of the list.
    ///
    /// - Parameter list: The list to be copied and appended.
    @inlinable
    public func append(_ list: DoubleLinkedList<Element>) {
        var nodeToCopy = list.head

        while let node = nodeToCopy {
            append(node.value)
            nodeToCopy = node.next
        }
    }

    /// Insert a value at a specific index. Crashes if index is out of bounds (0...self.count)
    ///
    /// - Parameters:
    ///   - value: The data value to be inserted
    ///   - index: Integer value of the index to be insterted at
    @inlinable public func insert(_ value: T, at index: Index) {
        let newNode = Node(value: value)
        insert(newNode, at: index)
    }

    /// Insert a copy of a node at a specific index. Crashes if index is out of bounds (0...self.count)
    ///
    /// - Parameters:
    ///   - node: The node containing the value to be inserted
    ///   - index: Integer value of the index to be inserted at
    @inlinable
    public func insert(_ newNode: Node<Element>, at index: Index) {
        if index == 0 {
            // Adding to the head
            newNode.next = head
            newNode.previous = nil
            head = newNode
        } else if index == count - 1 {
            // Adding to the tail
            tail?.next = newNode
            newNode.previous = tail
            tail = newNode
        } else {
            let node = node(at: index)

            node.next?.previous = newNode
            newNode.previous = node
            newNode.next = node.next
            node.next = newNode
        }

        count += 1
    }

    /// Insert a copy of a DoubleLinkedList at a specific index. Crashes if index is out of bounds (0...self.count)
    ///
    /// - Parameters:
    ///   - list: The DoubleLinkedList to be copied and inserted
    ///   - index: Integer value of the index to be inserted at
    @inlinable
    public func insert(_ list: DoubleLinkedList<Element>, at index: Index) {
        for (i, element) in list.enumerated() {
            self.insert(element, at: i + index)
        }
    }

    /// Function to remove all nodes/value from the list
    @inlinable
    public func removeAll() {
        head = nil
        tail = nil
        count = 0
    }

    /// Function to remove a specific node.
    ///
    /// - Parameter node: The node to be deleted
    /// - Returns: The data value contained in the deleted node.
    @inlinable @discardableResult
    public func remove(node: Node<T>) -> T {
        assert(head != nil)

        if node === head {
            head = node.next
        } else {
            node.previous?.next = node.next
            node.next?.previous = node.previous
        }

        return node.value
    }

    /// Function to remove a node/value at a specific index. Crashes if index is out of bounds (0...self.count)
    ///
    /// - Parameter index: Integer value of the index of the node to be removed
    /// - Returns: The data value contained in the deleted node
    @inlinable @discardableResult
    public func remove(at index: Int) -> T {
        return remove(node: self.node(at: index))
    }
}

extension DoubleLinkedList: CustomStringConvertible {
    @inlinable
    public var description: String {
        var s = "["
        var node = head
        while let nd = node {
            s += "\(nd.value)"
            node = nd.next
            if node != nil { s += ", " }
        }
        return s + "]"
    }
}

extension DoubleLinkedList {
    public func reverse() {
        var current : Node<T>? = head
        var next : Node<T>?
        var prev : Node<T>?

        head = tail
        tail = current

        while current != nil {
            next = current?.next
            current?.next = prev
            prev = current
            current = next
        }
    }
}

extension DoubleLinkedList {
    @inlinable
    public func map<U>(transform: (T) -> U) -> DoubleLinkedList<U> {
        let result = DoubleLinkedList<U>()
        var node = head
        while let nd = node {
            result.append(transform(nd.value))
            node = nd.next
        }
        return result
    }

    @inlinable
    public func filter(predicate: (T) -> Bool) -> DoubleLinkedList<T> {
        let result = DoubleLinkedList<T>()
        var node = head
        while let nd = node {
            if predicate(nd.value) {
                result.append(nd.value)
            }
            node = nd.next
        }
        return result
    }
}
