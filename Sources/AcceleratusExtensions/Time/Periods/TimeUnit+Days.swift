//
//  TimeUnit+Days.swift
//
//  Created by Chris Scalcucci on 4/20/20.
//

import Foundation

// =============================
// MARK:- Days
// =============================

/**
    Converts days to nanoseconds.

    - parameter d: Time in days
    - returns: Time in nanoseconds
 */
public func d2ns(_ d: Double) -> Double {
    return d * 86_400_000_000_000
}

/**
    Converts days to microseconds.

    - parameter d: Time in days
    - returns: Time in microseconds
 */
public func d2us(_ d: Double) -> Double {
    return d * 86_400_000_000
}

/**
    Converts days to milliseconds.

    - parameter d: Time in days
    - returns: Time in milliseconds
 */
public func d2ms(_ d: Double) -> Double {
    return d * 86_400_000
}

/**
    Converts days to seconds.

    - parameter d: Time in days
    - returns: Time in seconds
 */
public func d2s(_ d: Double) -> Double {
    return d * 86_400
}

/**
    Converts days to minutes.

    - parameter d: Time in days
    - returns: Time in minutes
 */
public func d2min(_ d: Double) -> Double {
    return d * 1_440
}

/**
    Converts days to hours.

    - parameter d: Time in days
    - returns: Time in hours
 */
public func d2hr(_ d: Double) -> Double {
    return d * 24
}
