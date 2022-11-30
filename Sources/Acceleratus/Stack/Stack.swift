//
//  Stack.swift
//  
//
//  Created by Chris Scalcucci on 11/29/22.
//

import Foundation

public final class Stack<Element> {
    public enum StackStoreType {
        case array
        case contiguousArray
        case linkedList
    }

    public var backingStore : StackStore<Element>

    public init(storeType: StackStoreType = .contiguousArray) {
        switch storeType {
        case .array:
            self.backingStore = ArrayStore<Element>()
        case .contiguousArray:
            self.backingStore = ContiguousArrayStore<Element>()
        case .linkedList:
            self.backingStore = LinkedListStore<Element>()
        }
    }

    public init(store: StackStore<Element>) {
        self.backingStore = store
    }

    @inlinable public func push(_ element: Element) {
        self.backingStore.append(element)
    }

    @inlinable @discardableResult public func pop() -> Element? {
        guard self.backingStore.last != nil else { return nil }
        return self.backingStore.removeLast()
    }

    @inlinable public func peek() -> Element? {
        return self.backingStore.last
    }

    @inlinable public func removeAll(where shouldBeRemoved: @escaping (Element) throws -> Bool) rethrows {
        try self.backingStore.removeAll(where: shouldBeRemoved)
    }

    public class StackStore<Element> {

        @inlinable public func append(_ newElement: Element) {
            fatalError("MUST OVERRIDE IN SUBCLASS")
        }

        @inlinable public func removeLast() -> Element {
            fatalError("MUST OVERRIDE IN SUBCLASS")
        }

        @inlinable public var last : Element? {
            fatalError("MUST OVERRIDE IN SUBCLASS")
        }

        @inlinable public var count : Int {
            fatalError("MUST OVERRIDE IN SUBCLASS")
        }

        @inlinable public func removeAll(where shouldBeRemoved: @escaping (Element) throws -> Bool) rethrows {
            fatalError("MUST OVERRIDE IN SUBCLASS")
        }
    }

    public class ArrayStore<Element> : StackStore<Element> {
        public var base = Array<Element>()

        @inlinable public override func append(_ newElement: Element) {
            self.base.append(newElement)
        }

        @inlinable public override func removeLast() -> Element {
            return self.base.removeLast()
        }

        @inlinable public override var last : Element? {
            return self.base.last
        }

        @inlinable public override var count : Int {
            return self.base.count
        }

        @inlinable public override func removeAll(where shouldBeRemoved: @escaping (Element) throws -> Bool) rethrows {
            try self.base.removeAll(where: shouldBeRemoved)
        }
    }

    public class ContiguousArrayStore<Element> : StackStore<Element> {
        public var base = ContiguousArray<Element>()

        @inlinable public override func append(_ newElement: Element) {
            self.base.append(newElement)
        }

        @inlinable public override func removeLast() -> Element {
            return self.base.removeLast()
        }

        @inlinable public override var last : Element? {
            return self.base.last
        }

        @inlinable public override var count : Int {
            return self.base.count
        }

        @inlinable public override func removeAll(where shouldBeRemoved: @escaping (Element) throws -> Bool) rethrows {
            try self.base.removeAll(where: shouldBeRemoved)
        }
    }

    public class LinkedListStore<Element> : StackStore<Element> {
        public var base = DoubleLinkedList<Element>()

        @inlinable public override func append(_ newElement: Element) {
            self.base.append(newElement)
        }

        @inlinable public override func removeLast() -> Element {
            return self.base.removeLast()
        }

        @inlinable public override var last : Element? {
            return self.base.last
        }

        @inlinable public override var count : Int {
            return self.base.count
        }

        @inlinable public override func removeAll(where shouldBeRemoved: @escaping (Element) throws -> Bool) rethrows {
            try self.base.removeAll(where: shouldBeRemoved)
        }
    }
}
