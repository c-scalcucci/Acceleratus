//
//  LinkedList.swift
//
//  Created by Chris Scalcucci on 3/22/20.
//

import Foundation

public class LinkedList<T> {
    public typealias Node = LinkedListNode<T>

    public class LinkedListNode<T> {
        public var value: T
        public var next: LinkedListNode?
        public weak var previous: LinkedListNode?

        public init(value: T) {
            self.value = value
        }
    }

    //
    // MARK: Properties
    //

    public var head: Node?

    /// Computed property to iterate through the linked list and return the last node in the list (if any)
    @inlinable
    public var last: Node? {
        guard var node = head else {
            return nil
        }

        while let next = node.next {
            node = next
        }
        return node
    }

    /// Computed property to check if the linked list is empty
    @inlinable
    public var isEmpty: Bool {
        return head == nil
    }

    /// Computed property to iterate through the linked list and return the total number of nodes
    @inlinable
    public var count: Int {
        guard var node = head else {
            return 0
        }

        var count = 1
        while let next = node.next {
            node = next
            count += 1
        }
        return count
    }

    //
    // MARK: Initialization
    //

    /// Default initializer
    public init() {}

    public convenience init(array: Array<T>) {
        self.init()

        array.forEach { append($0) }
    }

    public convenience init(arrayLiteral elements: T...) {
        self.init()

        elements.forEach { append($0) }
    }

    //
    // MARK: Accessors
    //


    /// Subscript function to return the node at a specific index
    ///
    /// - Parameter index: Integer value of the requested value's index
    @inlinable
    public subscript(index: Int) -> T {
        get {
            let node = self.node(at: index)
            return node.value
        }
    }

    /// Function to return the node at a specific index. Crashes if index is out of bounds (0...self.count)
    ///
    /// - Parameter index: Integer value of the node's index to be returned
    /// - Returns: LinkedListNode
    @inlinable
    public func node(at index: Int) -> Node {
        assert(head != nil, "List is empty")
        assert(index >= 0, "index must be greater or equal to 0")

        if index == 0 {
            return head!
        } else {
            var node = head!.next
            var i = 0

            while i < index {
                node = node?.next
                if node == nil {
                    break
                }
                i += 1
            }

            assert(node != nil, "index is out of bounds.")
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

    /// Append a copy of a LinkedListNode to the end of the list.
    ///
    /// - Parameter node: The node containing the value to be appended
    @inlinable
    public func append(_ node: Node) {
        let newNode = node
        if let lastNode = last {
            newNode.previous = lastNode
            lastNode.next = newNode
        } else {
            head = newNode
        }
    }

    /// Append a copy of a LinkedList to the end of the list.
    ///
    /// - Parameter list: The list to be copied and appended.
    @inlinable
    public func append(_ list: LinkedList) {
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
    @inlinable
    public func insert(_ value: T, at index: Int) {
        let newNode = Node(value: value)
        insert(newNode, at: index)
    }

    /// Insert a copy of a node at a specific index. Crashes if index is out of bounds (0...self.count)
    ///
    /// - Parameters:
    ///   - node: The node containing the value to be inserted
    ///   - index: Integer value of the index to be inserted at
    @inlinable
    public func insert(_ newNode: Node, at index: Int) {
        if index == 0 {
            newNode.next = head
            head?.previous = newNode
            head = newNode
        } else {
            let prev = node(at: index - 1)
            let next = prev.next
            newNode.previous = prev
            newNode.next = next
            next?.previous = newNode
            prev.next = newNode
        }
    }

    /// Insert a copy of a LinkedList at a specific index. Crashes if index is out of bounds (0...self.count)
    ///
    /// - Parameters:
    ///   - list: The LinkedList to be copied and inserted
    ///   - index: Integer value of the index to be inserted at
    @inlinable
    public func insert(_ list: LinkedList, at index: Int) {
        guard !list.isEmpty else { return }

        if index == 0 {
            list.last?.next = head
            head = list.head
        } else {
            let prev = node(at: index - 1)
            let next = prev.next

            prev.next = list.head
            list.head?.previous = prev

            list.last?.next = next
            next?.previous = list.last
        }
    }

    /// Function to remove all nodes/value from the list
    @inlinable
    public func removeAll() {
        head = nil
    }

    /// Function to remove a specific node.
    ///
    /// - Parameter node: The node to be deleted
    /// - Returns: The data value contained in the deleted node.
    @inlinable @discardableResult
    public func remove(node: Node) -> T {
        let prev = node.previous
        let next = node.next

        if let prev = prev {
            prev.next = next
        } else {
            head = next
        }
        next?.previous = prev

        node.previous = nil
        node.next = nil
        return node.value
    }

    /// Function to remove the last node/value in the list. Crashes if the list is empty
    ///
    /// - Returns: The data value contained in the deleted node.
    @inlinable @discardableResult
    public func removeLast() -> T {
        assert(!isEmpty)
        return remove(node: last!)
    }

    /// Function to remove a node/value at a specific index. Crashes if index is out of bounds (0...self.count)
    ///
    /// - Parameter index: Integer value of the index of the node to be removed
    /// - Returns: The data value contained in the deleted node
    @inlinable @discardableResult
    public func remove(at index: Int) -> T {
        let node = self.node(at: index)
        return remove(node: node)
    }
}

extension LinkedList: CustomStringConvertible {
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

extension LinkedList {
    @inlinable
    public func reverse() {
        var node = head
        while let currentNode = node {
            node = currentNode.next
            swap(&currentNode.next, &currentNode.previous)
            head = currentNode
        }
    }
}

extension LinkedList {
    @inlinable
    public func map<U>(transform: (T) -> U) -> LinkedList<U> {
        var result = LinkedList<U>()
        var node = head
        while let nd = node {
            result.append(transform(nd.value))
            node = nd.next
        }
        return result
    }

    @inlinable
    public func filter(predicate: (T) -> Bool) -> LinkedList<T> {
        var result = LinkedList<T>()
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

extension LinkedList: Collection {

    public typealias Index = LinkedListIndex<T>

    /// The position of the first element in a nonempty collection.
    ///
    /// If the collection is empty, `startIndex` is equal to `endIndex`.
    /// - Complexity: O(1)
    @inlinable
    public var startIndex: Index {
        get {
            return LinkedListIndex<T>(node: head, tag: 0)
        }
    }

    /// The collection's "past the end" position---that is, the position one
    /// greater than the last valid subscript argument.
    /// - Complexity: O(n), where n is the number of elements in the list. This can be improved by keeping a reference
    ///   to the last node in the collection.
    @inlinable
    public var endIndex: Index {
        get {
            if let h = self.head {
                return LinkedListIndex<T>(node: h, tag: count)
            } else {
                return LinkedListIndex<T>(node: nil, tag: startIndex.tag)
            }
        }
    }

    @inlinable
    public subscript(position: Index) -> T {
        get {
            return position.node!.value
        }
    }

    public func index(after idx: Index) -> Index {
        return LinkedListIndex<T>(node: idx.node?.next, tag: idx.tag + 1)
    }
}

// MARK: - Collection Index
/// Custom index type that contains a reference to the node at index 'tag'
public struct LinkedListIndex<T>: Comparable {
    public let node: LinkedList<T>.LinkedListNode<T>?
    public let tag: Int

    public init(node: LinkedList<T>.LinkedListNode<T>?, tag: Int) {
        self.node = node
        self.tag = tag
    }

    public static func==<T>(lhs: LinkedListIndex<T>, rhs: LinkedListIndex<T>) -> Bool {
        return (lhs.tag == rhs.tag)
    }

    public static func< <T>(lhs: LinkedListIndex<T>, rhs: LinkedListIndex<T>) -> Bool {
        return (lhs.tag < rhs.tag)
    }
}

