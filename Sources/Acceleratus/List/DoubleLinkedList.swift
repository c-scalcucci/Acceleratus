//
//  DoubleLinkedList.swift
//
//  Created by Christopher Scalcucci on 8/6/19.
//

import Foundation

public class DoubleLinkedList<T: Equatable> : NSObject {
    public typealias Element = T

    public class Node<T: Equatable> : Equatable {
        public var value: T
        public var next: Node?
        public var prev: Node?

        public init(value: T, next: Node? = nil, prev: Node? = nil) {
            self.value = value
            self.next = next
            self.prev = prev
        }

        public static func ==(lhs: Node<T>, rhs: Node<T>) -> Bool {
            return lhs.value == rhs.value
        }
    }

    public var head: Node<T>?
    public var tail: Node<T>?
    public var count: Int = 0

    @inlinable
    public var isEmpty : Bool {
        return count < 1
    }

    @inlinable
    public func indexOf(_ v: T) -> Int? {
        var currentPosition = 0
        var currentNode = head

        while currentNode != nil {
            if currentNode?.value == v {
                break
            }
            currentNode = currentNode?.next
            currentPosition += 1
        }

        if currentNode != nil {
            // Element was not found
            return nil
        }

        return currentPosition
    }

    @inlinable @discardableResult
    public func push(_ v: T) -> Node<T> {
        addFront(v)
    }

    @inlinable @discardableResult
    public func addFront(_ v: T) -> Node<T> {
        let n = Node<T>(value: v)

        if tail == nil {
            // This is the first element being placed, so both front and back need to point to it
            tail = n
        } else {
            // New node will be the new front, so the current front is now the success
            n.next = head
            head?.prev = n
        }

        head = n
        count += 1
        return n
    }

    @inlinable @discardableResult
    public func addLast(_ v: T) -> Node<T> {
        let n = Node<T>(value: v)

        if head == nil {
            // This is the first element being put into the list, front need to point to it
            head = n
        } else {
            // Since the new node is the new tail, previous node will be the old tail
            n.prev = tail
            tail?.next = n
        }

        tail = n
        count += 1
        return n
    }

    @inlinable
    public func insert(_ v: T, index: Int) throws {
        guard index > 0 && index < (count - 1) else {
            throw CollectionError.outOfBounds
        }

        switch index {
        case _ where index < 0:
            throw CollectionError.outOfBounds
        case _ where index > (count - 1):
            throw CollectionError.outOfBounds
        case 0:
            addFront(v)
        case (count - 1):
            addLast(v)
        default:
            var currentNode = head
            var currentIndex = 0

            // iterate to the node at the position where we want to insert
            while (currentIndex != index) {
                currentIndex += 1
                currentNode = currentNode?.next
            }

            // Current node stores the node currently at the position to insert
            let n = Node<T>(value: v)

            // Need to shift everything to the right by 1
            n.next = currentNode
            n.prev = currentNode?.prev
            currentNode?.prev?.next = n
            currentNode?.prev = n
            count += 1
        }
    }

    @inlinable
    public func get(at index: Int) throws -> T? {
        guard index > 0 && index < count else {
            throw CollectionError.outOfBounds
        }

        guard !isEmpty else {
            throw CollectionError.outOfBounds
        }

        var currentIndex = 0
        var currentNode = head

        while (currentIndex != index) {
            currentIndex += 1
            currentNode = currentNode?.next
        }

        return currentNode?.value
    }

    @inlinable @discardableResult
    public func dropFirst() -> T? {
        guard !isEmpty else {
            return nil
        }

        let oldHead = head

        if count == 1 {
            // Make sure to nil out tail if count is 1
            // Tail also points to the node to delete
            tail = nil
        } else {
            // Pointer to previous for the successor of the head
            // about to deleted needs to be nil
            oldHead?.next?.prev = nil
        }

        // Update head to point to successor
        head = head?.next

        count -= 1

        return oldHead?.value
    }

    @inlinable @discardableResult
    public func dropLast() -> T? {
        guard !isEmpty else {
            return nil
        }

        let oldTail = tail

        if count == 1 {
            // Make sure to nil out head if count is 1
            // Head also points to the node to delete
            head = nil
        } else {
            oldTail?.prev?.next = nil
        }

        // Move back to point to predecessor
        tail = tail?.prev

        count -= 1

        return oldTail?.value
    }

    @inlinable
    public func peek() -> Node<T>? {
        return head
    }

    @inlinable
    public func peekLast() -> Node<T>? {
        return tail
    }

    /// Removes the first node from the list that contains the specified value
    @inlinable
    public func remove(_ v: T) -> Bool {
        guard !isEmpty else {
            return false
        }

        if head?.value == v {
            dropFirst()
            return true
        } else if tail?.value == v {
            dropLast()
            return true
        } else {
            var currentNode = head

            while currentNode != nil {
                if currentNode?.value == v {
                    break
                } else {
                    currentNode = currentNode?.next
                }
            }

            if currentNode != nil {
                currentNode?.prev?.next = currentNode?.next
                currentNode?.next?.prev = currentNode?.prev
                count -= 1
                return true
            }
            return false
        }
    }

    /// Removes an element from the list at a given index
    @inlinable
    public func remove(at index: Int) throws -> T {
        guard !isEmpty else {
            throw CollectionError.outOfBounds
        }

        var v : T?

        switch index {
        case _ where index < 0:
            throw CollectionError.outOfBounds
        case _ where index > (count - 1):
            throw CollectionError.outOfBounds
        case 0:
            v = dropFirst()
        case (count - 1):
            v = dropLast()
        default:
            var currentIndex = 0
            var currentNode = head

            while (currentIndex != index) {
                currentIndex += 1
                currentNode = currentNode?.next
            }

            v = currentNode?.value
            currentNode?.next?.prev = currentNode?.prev
            currentNode?.prev?.next = currentNode?.next
            count -= 1
        }

        guard let v = v else {
            throw CollectionError.outOfBounds
        }
        return v
    }

    /// Returns a new DoubleLinkedList from the provided node
    /// all the way to the tail
    @inlinable
    public func subList(_ node: Node<T>) -> DoubleLinkedList<T> {
        let list = DoubleLinkedList<T>()
        list.addLast(node.value)

        var currentNode = node.next

        while currentNode != nil {
            list.addLast(currentNode!.value)
            currentNode = currentNode?.next
        }

        return list
    }

    /// Returns a new DoubleLinkedList starting from the first node
    /// that contains the prescribed value until to tail
    @inlinable
    public func subList(_ v: T) -> DoubleLinkedList<T> {
        var currentNode = head

        while currentNode != nil {
            if currentNode?.value == v {
                return subList(currentNode!)
            }
            currentNode = currentNode?.next
        }

        return DoubleLinkedList<T>()
    }

    /// Returns a new DoubleLinkedList starting AFTER the first node
    /// that contains the prescribed value until to tail
    @inlinable
    public func after(_ v: T) -> DoubleLinkedList<T> {
        var currentNode = head

        while currentNode != nil {
            if currentNode?.value == v, let next = currentNode?.next{
                return subList(next)
            }
            currentNode = currentNode?.next
        }

        return DoubleLinkedList<T>()
    }

    /// Returns a new DoubleLinkedList starting FROM the first node
    /// that contains the prescribed value until to tail
    @inlinable
    public func from(_ v: T) -> DoubleLinkedList<T> {
        return subList(v)
    }

    /// Returns a new DoubleLinkedList starting BEFORE the first node
    /// that contains the prescribed value until to tail
    @inlinable
    public func before(_ v: T) -> DoubleLinkedList<T> {
        var currentNode = head

        while currentNode != nil {
            if currentNode?.value == v, let prev = currentNode?.prev {
                return subList(prev)
            }
            currentNode = currentNode?.next
        }

        return DoubleLinkedList<T>()
    }

    /// Returns a new DoubleLinkedList starting n elements
    /// after the head, returns an empty list if count
    /// is greater than the number of nodes
    ///
    /// So for list [0 -> 1 -> 2 -> 3] calling advanced(by: 2)
    /// would return [2 -> 3]
    @inlinable
    public func advanced(by count: Int) -> DoubleLinkedList<T> {
        guard count <= self.count else { return DoubleLinkedList<T>() }
        var currentIndex = 1
        var currentNode = head

        while currentNode != nil && currentIndex <= count {
            currentNode = currentNode?.next
            currentIndex += 1
        }

        return subList(currentNode!)
    }

    /// Removes the node from its current location
    /// and places it at the head
    @inlinable
    public func moveToHead(_ node: Node<T>) {
        guard head != node else {
            return
        }

        if tail == node {
            tail = node.prev
        }

        node.prev?.next = node.next
        node.next?.prev = node.prev

        node.next = head
        node.prev = nil

        head?.prev = node
        head = node
    }

    @inlinable
    public func forEach(_ fn: (T) -> ()) {
        var currentNode = head

        while currentNode != nil {
            fn(currentNode!.value)
            currentNode = currentNode!.next
        }
    }

    @inlinable
    public func reduce<E>(into result: E, _ fn: @escaping (inout E, T) throws -> Void) rethrows -> E {
        var currentNode = head
        var result = result

        while currentNode != nil {
            try fn(&result, currentNode!.value)
            currentNode = currentNode!.next
        }

        return result
    }

    @inlinable
    public func removeAll() {
        while !isEmpty {
            dropFirst()
        }
    }

    public override var description: String {
        var result = "["
        self.forEach({
            result += "\($0)"
        })
        if self.count > 0 {
            result.removeLast()
        }
        result += "]"
        return result

    }

    public override var debugDescription: String {
        var result = "[\n"
        var i = 0
        self.forEach({
            result += "[\(i)] : \($0)\n"
            i += 1
        })
        result += "]"
        return result
    }
}

extension DoubleLinkedList where T: CustomStringConvertible {
    @inlinable
    public var description: String {
        var result = "["
        self.forEach({
            result += "\($0.description)"
        })
        if self.count > 0 {
            result.removeLast()
        }
        result += "]"
        return result
    }
}

extension DoubleLinkedList where T: CustomDebugStringConvertible {
    @inlinable
    public var debugDescription: String {
        var result = "[\n"
        var i = 0
        self.forEach({
            result += "[\(i)] : \($0.debugDescription)\n"
            i += 1
        })
        result += "]"
        return result
    }
}
