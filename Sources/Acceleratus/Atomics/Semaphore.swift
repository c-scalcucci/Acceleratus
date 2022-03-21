//
//  Semaphore.swift
//  
//
//  Created by Chris Scalcucci on 3/16/22.
//

import Foundation

public class Semaphore {
    public enum SemaphoreError : Error {
        case waitFailed
    }

    public var count : Int

    public var lock = pthread_mutex_t()
    public var cv = pthread_cond_t()

    public init(_ val: Int = 0) {
        // iOS posix does not support pthread_condattr_setclock
        // and in general has stupid monotonic clock support
        // someone pls fix
        //            pthread_condattr_t condattr;
        //            pthread_condattr_init(&condattr);
        //            pthread_condattr_setclock(&condattr, CLOCK_MONOTONIC);
        //            pthread_cond_init(&cv, &condattr);

        self.count = val
        pthread_mutex_init(&lock, nil)
        pthread_cond_init(&cv, nil)
    }

    /// Acquire & Wait
    @inlinable
    public func wait() {
        pthread_mutex_lock(&lock)

        while count == 0 {
            pthread_cond_wait(&cv, &lock)
        }

        count -= 1

        pthread_mutex_unlock(&lock)
    }

    /// Acquire & Wait until timeout
    @inlinable
    public func waitNanos(_ duration: Int64) throws {
        pthread_mutex_lock(&lock)
        defer { pthread_mutex_unlock(&lock) }

        var timeToWait = timespec()

        // no great monotonic clock support...
        // clock_gettime(CLOCK_MONOTONIC, &timeToWait);

        if 0 != clock_gettime(CLOCK_REALTIME, &timeToWait) {
            print("Could not call clock_gettime - errno: \(errno)")
            throw SemaphoreError.waitFailed
        }

        // tv_nsec has to be less than 1bn (1 second's worth)
        // so determine what we add to sec
        timeToWait.tv_sec += __darwin_time_t(duration / 1_000_000_000)

        pthread_cond_timedwait(&cv, &lock, &timeToWait);
    }

    /// Acquire & Wait until timeout
    @inlinable
    public func waitNanos(_ duration: Int) throws {
        try waitNanos(Int64(duration))
    }

    /// Acquire & Signal
    public func signal() {
        pthread_mutex_lock(&lock)
        count += 1

        if count >= 1 {
            pthread_cond_signal(&cv)
        }

        pthread_mutex_unlock(&lock)
    }

    public func reset() {
        pthread_mutex_lock(&lock)

        if count >= 1 {
            pthread_cond_signal(&cv)
        }

        pthread_mutex_unlock(&lock)
    }
}
