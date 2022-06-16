//
//  WeakPointerContainer.swift
//  
//
//  Created by Chris Scalcucci on 6/16/22.
//

import Foundation

public class WeakPointerContainer<T: AnyObject> : NSObject {
    public typealias Element = T

    public private(set) weak var object : Element?

    public init(_ object: Element) {
        self.object = object
        super.init()
    }
}

extension WeakPointerContainer where Element : Equatable {
    static func ==(lhs: WeakPointerContainer<Element>, rhs: WeakPointerContainer<Element>) -> Bool {
        return lhs.object == rhs.object
    }
}

// Have to create an entirely separate class because hash cannot be overridden from
// an extension by doing 'extension WeakPointerContainer where Element : Hashable
// because NSObject's hash is @objc
public class WeakHashablePointerContainer<T: AnyObject & Hashable> : NSObject {
    public typealias Element = T

    public private(set) weak var object : Element?

    public init(_ object: Element) {
        self.object = object
        super.init()
    }

    public override var hash: Int {
        return object?.hashValue ?? self.hashValue
    }
}


