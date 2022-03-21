//
//  LinkedBlockingDeque.swift
//  
//
//  Created by Chris Scalcucci on 3/16/22.
//

import Foundation

public enum QueueError : Error {
    case queueFull
}

public final class LinkedBlockingDeque<T: Equatable> {

    public final class Node<T: Equatable> : Equatable {
        public var item : T? = nil
        public var next : Node<T>? = nil

        public init(_ item: T? = nil) {
            self.item = item
        }

        public static func ==<T: Equatable>(lhs: Node<T>, rhs: Node<T>) -> Bool {
            return lhs.item == rhs.item && lhs.next == rhs.next
        }
    }

    //
    // MARK: Properties
    //

    /// Current number of elements
    private var _count : AtomicInt = AtomicInt(0)

    /// Lock held by take, poll, etc
    private var takeLock = pthread_mutex_t()

    /// Wait cond for waiting takes
    private var nFilled : Semaphore

    /// Lock held by put, offer, etc
    private var putLock = pthread_mutex_t()

    /// Wait cond for waiting puts
    private var nHoles : Semaphore

    /// The capacity bound, or Int.Max if none
    public private(set) var capacity : Int

    /// Head of the linked list
    public private(set) var head : Node<T>?

    /// Tail of linked list
    public private(set) var last : Node<T>?

    //
    // MARK: Computed Properties
    //

    /// Returns the number of elements in this queue
    public var count : Int {
        return _count.get()
    }

    /// Returns the number of additional elements that this queue can
    /// accept without blocking.
    public var remainingCapacity : Int {
        return capacity - count
    }

    /**
        A bool representing the empty status of the deque.
     */
    public var isEmpty : Bool {
        return count == 0
    }

    //
    // MARK: Initialization
    //

    public init(_ capacity: Int = Int.max) {
        self.capacity = capacity

        pthread_mutex_init(&takeLock, nil)
        pthread_mutex_init(&putLock, nil)

        nFilled = Semaphore(0)
        nHoles  = Semaphore(capacity)

        head = Node<T>()
        last = head
    }

    public convenience init(_ capacity: Int = Int.max, _
                            elements: [T]) throws {
        guard elements.count <= capacity else {
            throw QueueError.queueFull
        }

        self.init(capacity)

        elements.forEach({
            enqueue(Node<T>($0))
        })

        _count.set(elements.count)
    }

    /**
        Inserts the specific element at the tail of this queue,
        waiting if necessary for space to become available.

        - parameter element: The element to insert
     */
    public func put(_ element: T) {
        let node = Node<T>(element)

        nHoles.wait()

        pthread_mutex_lock(&putLock)

        enqueue(node)

        pthread_mutex_unlock(&putLock)

        nFilled.signal()
    }

    /**
        Inserts the specific element at the head of this queue,
        waiting if necessary for space to become available.

        - parameter element: The element to insert
     */
    public func putFirst(_ element: T) {
        let node = Node<T>(element)

        nHoles.wait()

        pthread_mutex_lock(&putLock)

        if head != nil {
            node.next = head
        }

        head = node

        _count.incrementAndGet()

        pthread_mutex_unlock(&putLock)

        nFilled.signal()
    }

    /**
        Attempts to insert an element into the deque, if space is available.

        This method does not block while the deque is at full capacity, instead
        it will return false immediately.

        - parameter element: The element to insert
        - returns: True if element was inserted, false otherwise
     */
    public func offer(_ element: T) -> Bool {
        var offered = false

        pthread_mutex_lock(&putLock)

        if remainingCapacity > 0 {
            let node = Node<T>(element)
            enqueue(node)
            offered = true
        }

        pthread_mutex_unlock(&putLock)

        if offered {
            nFilled.signal()
        }

        return offered
    }

    /**
        Iterates the deque looking for the specified element.

        - parameter element: The element to search for
        - returns: True if the deque contains element
     */
    public func contains(_ element: T) -> Bool {
        var hasValue = false

        forEach({
            hasValue = hasValue || ($0 == element)
        })

        return hasValue
    }

    /**
        Attempts to take a node's item from the head of the queue,
        returning null if there are no elements.

        Unlike take, this method will NOT block.

        - returns: The head of the deque
     */
    public func poll() -> T? {
        var x : T?

        pthread_mutex_lock(&takeLock)

        if count > 0 {
            x = dequeue()
        }

        pthread_mutex_unlock(&takeLock)

        if x != nil {
            nHoles.signal()
        }

        return x
    }

    /**
        Attempts to take a node's item from the queue.

        - returns: An optional element
     */
    public func take() -> T? {
        var x : T?

        nFilled.wait()

        pthread_mutex_lock(&takeLock)

        x = dequeue()

        pthread_mutex_unlock(&takeLock)

        nHoles.signal()

        return x
    }

    /**
        Removes every node from the queue.

        NOTE: The puts and takes are locked during this time.
     */
    public func clear() {
        fullyLock()

        var p : Node<T>?
        var h : Node<T>? = head

        while h?.next != nil {
            p = h?.next
            h?.next = h
            p?.item = nil
            h = p
        }

        head = last

        _count.set(0)
        
        nHoles.reset()

        fullyUnlock()
    }

    public func unlink(node: Node<T>?, predecessor: Node<T>?) {
        fullyLock()

        node?.item = nil
        predecessor?.next = node?.next

        if last == node {
            last = predecessor
        }

        _count.getAndDecrement()

        if count < capacity {
            nFilled.signal()
        }

        fullyUnlock()
    }

    /**
        Links node at the end of the queue.

        - parameter node: The node to be linked
     */
    private func enqueue(_ node: Node<T>) {
        last?.next = node
        last = node
        _count.incrementAndGet()
    }

    /**
        Removes a node from head of queue.

        - returns: A node
     */
    private func dequeue() -> T? {
        let h = head
        let first = h?.next

        head = first

        let x = first?.item
        first?.item = nil

        _count.decrementAndGet()

        return x
    }

    /**
        Locks to prevent both puts and takes.
     */
    private func fullyLock() {
        pthread_mutex_lock(&putLock)
        pthread_mutex_lock(&takeLock)
    }

    /**
        Unlocks to allow both puts and takes.
     */
    private func fullyUnlock() {
        pthread_mutex_unlock(&takeLock)
        pthread_mutex_unlock(&putLock)
    }

    public func forEach(_ fn: (T) throws -> ()) rethrows {
        fullyLock()
        defer { fullyUnlock() }

        var optionalCurrent : Node<T>? = head

        while optionalCurrent != nil {
            let current = optionalCurrent
            let item = current?.item

            if let item = item {
                try fn(item)
            }

            optionalCurrent = current?.next
        }
    }

    public func reduce<X>(_ initialResult: X, _ nextPartialResult: (X, T) throws -> X) rethrows -> X {
        fullyLock()
        defer { fullyUnlock() }

        var optionalCurrent : Node<T>? = head
        var result = initialResult

        while optionalCurrent != nil {
            let current = optionalCurrent
            let item = current?.item

            if let item = item {
                result = try nextPartialResult(result, item)
            }

            optionalCurrent = current?.next
        }

        return result
    }

    public func filter(_ fn: (T) throws -> Bool) rethrows -> [T] {
        fullyLock()
        defer { fullyUnlock() }

        var optionalCurrent : Node<T>? = head
        var result = [T]()

        while optionalCurrent != nil {
            let current = optionalCurrent
            let item = current?.item

            if let item = item {
                if try fn(item) {
                    result.append(item)
                }
            }

            optionalCurrent = current?.next
        }

        return result
    }

    public func map<X>(_ fn: (T) throws -> X) rethrows -> [X] {
        fullyLock()
        defer { fullyUnlock() }

        var optionalCurrent : Node<T>? = head
        var result = [X]()

        while optionalCurrent != nil {
            let current = optionalCurrent
            let item = current?.item

            if let item = item {
                result.append(try fn(item))
            }

            optionalCurrent = current?.next
        }

        return result
    }

    public func compactMap<X>(_ fn: (T) throws -> X?) rethrows -> [X] {
        fullyLock()
        defer { fullyUnlock() }

        var optionalCurrent : Node<T>? = head
        var result = [X]()

        while optionalCurrent != nil {
            let current = optionalCurrent
            let item = current?.item

            if let item = item {
                if let x = try fn(item) {
                    result.append(x)
                }
            }

            optionalCurrent = current?.next
        }

        return result
    }
}

