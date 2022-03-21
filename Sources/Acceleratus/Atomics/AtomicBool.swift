//
//  AtomicBool.swift
//  
//
//  Created by Chris Scalcucci on 3/17/22.
//

import Foundation

public final class AtomicBool {

    private var mutex = pthread_mutex_t()
    private var value: Bool = false

    public init(_ x: Bool) {
        pthread_mutex_init(&mutex, nil)

        self.value = x
    }

    deinit {
        pthread_mutex_destroy(&mutex)
    }

    public func get() -> Bool {
        pthread_mutex_lock(&mutex)
        defer { pthread_mutex_unlock(&mutex) }

        return value
    }

    public func set(_ x: Bool) {
        pthread_mutex_lock(&mutex)
        defer { pthread_mutex_unlock(&mutex) }

        value = x
    }

    public func getAndSet(_ x: Bool) -> Bool {
        pthread_mutex_lock(&mutex)
        defer { pthread_mutex_unlock(&mutex) }

        let tmp = value
        value = x
        return tmp
    }

    /**
        Atomically sets the new value, if the current value equals the expected value.

        - parameter expect: The expected value to compare against
        - parameter newValue: The new value to set to if the comparison succeeds
        - returns: True if successful, false indicates that the actualy value was not equal
        to the expected value
     */
    public func compareAndExchange(_ expect: Bool, _ newValue: Bool) -> Bool {
        pthread_mutex_lock(&mutex)
        defer { pthread_mutex_unlock(&mutex) }

        if self.value == expect {
            self.value = newValue
            return true
        } else { return false }
    }
}
