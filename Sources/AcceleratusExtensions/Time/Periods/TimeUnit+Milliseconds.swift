//
//  TimeUnit+Milliseconds.swift
//
//  Created by Chris Scalcucci on 4/20/20.
//

import Foundation

// =============================
// MARK:- Milliseconds
// =============================

/**
    Converts milliseconds to nanoseconds.

    - parameter ms: Time in milliseconds
    - returns: Time in nanoseconds
 */
public func ms2ns(_ ms: Double) -> Double {
    return ms * 1_000_000
}

/**
    Converts milliseconds to microseconds.

    - parameter ms: Time in milliseconds
    - returns: Time in microseconds
 */
public func ms2us(_ ms: Double) -> Double {
    return ms * 1_000
}

/**
    Converts milliseconds to seconds.

    - parameter ms: Time in milliseconds
    - returns: Time in seconds
 */
public func ms2s(_ ms: Double) -> Double {
    return ms / 1_000
}

/**
    Converts milliseconds to minutes.

    - parameter ms: Time in milliseconds
    - returns: Time in minutes
 */
public func ms2min(_ ms: Double) -> Double {
    return ms / 60_000
}

/**
    Converts milliseconds to hours.

    - parameter ms: Time in milliseconds
    - returns: Time in hours
 */
public func ms2hr(_ ms: Double) -> Double {
    return ms / 3_600_000
}

/**
    Converts milliseconds to days.

    - parameter ms: Time in milliseconds
    - returns: Time in days
 */
public func ms2d(_ ms: Double) -> Double {
    return ms / 86_400_000
}
