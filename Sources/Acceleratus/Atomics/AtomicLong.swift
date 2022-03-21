//
//  AtomicLong.swift
//  
//
//  Created by Chris Scalcucci on 3/16/22.
//

import Foundation

public final class AtomicLong {

    private var mutex = pthread_mutex_t()
    private var counter: Int64 = 0

    public init(_ x: Int) {
        pthread_mutex_init(&mutex, nil)

        self.counter = Int64(x)
    }

    public init(_ x: Int64 = 0) {
        pthread_mutex_init(&mutex, nil)

        self.counter = x
    }

    deinit {
        pthread_mutex_destroy(&mutex)
    }

    public func get() -> Int64 {
        pthread_mutex_lock(&mutex)
        defer { pthread_mutex_unlock(&mutex) }

        return counter
    }

    public func set(_ x: Int64) {
        pthread_mutex_lock(&mutex)
        defer { pthread_mutex_unlock(&mutex) }

        counter = x
    }

    public func getAndSet(_ x: Int64) -> Int64 {
        pthread_mutex_lock(&mutex)
        defer { pthread_mutex_unlock(&mutex) }

        let tmp = counter
        counter = x
        return tmp
    }

    public func incrementAndGet() -> Int64 {
        pthread_mutex_lock(&mutex)
        defer { pthread_mutex_unlock(&mutex) }

        counter += 1
        return counter
    }

    public func decrementAndGet() -> Int64 {
        pthread_mutex_lock(&mutex)
        defer { pthread_mutex_unlock(&mutex) }

        counter -= 1
        return counter
    }

    public func getAndIncrement() -> Int64 {
        pthread_mutex_lock(&mutex)
        defer { pthread_mutex_unlock(&mutex) }

        let x = counter
        counter += 1
        return x
    }

    public func getAndDecrement() -> Int64 {
        pthread_mutex_lock(&mutex)
        defer { pthread_mutex_unlock(&mutex) }

        let x = counter
        counter -= 1
        return x
    }

}
