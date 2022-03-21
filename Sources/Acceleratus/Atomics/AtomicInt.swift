//
//  AtomicInt.swift
//  
//
//  Created by Chris Scalcucci on 3/16/22.
//

import Foundation

public final class AtomicInt {

    private var mutex = pthread_mutex_t()
    private var counter: Int = 0

    public init(_ x: Int = 0) {
        pthread_mutex_init(&mutex, nil)

        self.counter = x
    }

    deinit {
        pthread_mutex_destroy(&mutex)
    }

    public func get() -> Int {
        pthread_mutex_lock(&mutex)
        defer { pthread_mutex_unlock(&mutex) }

        return counter
    }

    public func set(_ x: Int) {
        pthread_mutex_lock(&mutex)
        defer { pthread_mutex_unlock(&mutex) }

        counter = x
    }

    @discardableResult
    public func getAndSet(_ x: Int) -> Int {
        pthread_mutex_lock(&mutex)
        defer { pthread_mutex_unlock(&mutex) }

        let tmp = counter
        counter = x
        return tmp
    }

    @discardableResult
    public func incrementAndGet() -> Int {
        pthread_mutex_lock(&mutex)
        defer { pthread_mutex_unlock(&mutex) }

        counter += 1
        return counter
    }

    @discardableResult
    public func decrementAndGet() -> Int {
        pthread_mutex_lock(&mutex)
        defer { pthread_mutex_unlock(&mutex) }

        counter -= 1
        return counter
    }

    @discardableResult
    public func getAndIncrement() -> Int {
        pthread_mutex_lock(&mutex)
        defer { pthread_mutex_unlock(&mutex) }

        let x = counter
        counter += 1
        return x
    }

    @discardableResult
    public func getAndDecrement() -> Int {
        pthread_mutex_lock(&mutex)
        defer { pthread_mutex_unlock(&mutex) }

        let x = counter
        counter -= 1
        return x
    }
}
