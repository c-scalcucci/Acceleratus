//
//  ConcurrentObject.swift
//  
//
//  Created by Chris Scalcucci on 3/16/22.
//

import Foundation
import AcceleratusObjCXX

public protocol ConcurrentObject {

    var mutex : SharedRecursiveMutex { get }

    func sharedReturn<T>(_ fn: () throws -> T) rethrows -> T

    func sharedAction(_ fn: () throws -> Void) rethrows

    func exclusiveReturn<T>(_ fn: () throws -> T) rethrows -> T

    func exclusiveAction(_ fn: () throws -> Void) rethrows
}

public extension ConcurrentObject {

    @inlinable
    func sharedReturn<T>(_ fn: () throws -> T) rethrows -> T {
        defer {
            self.mutex.unlock_shared()
        }
        self.mutex.lock_shared()

        return try fn()
    }

    @inlinable
    func sharedAction(_ fn: () throws -> Void) rethrows {
        defer {
            self.mutex.unlock_shared()
        }
        self.mutex.lock_shared()

        try fn()
    }

    @inlinable
    func exclusiveReturn<T>(_ fn: () throws -> T) rethrows -> T {
        defer {
            self.mutex.unlock()
        }
        self.mutex.lock()

        return try fn()
    }

    @inlinable
    func exclusiveAction(_ fn: () throws -> Void) rethrows {
        defer {
            self.mutex.unlock()
        }
        self.mutex.lock()

        try fn()
    }
}
