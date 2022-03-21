//
//  TimeUnit+Nanoseconds.swift
//
//  Created by Chris Scalcucci on 4/20/20.
//

import Foundation

// =============================
// MARK:- Nanoseconds
// =============================

/**
    Converts nanoseconds to microseconds.

    - parameter ns: Time in nanoseconds
    - returns: Time in microseconds
 */
public func ns2us(_ ns: Double) -> Double {
    return ns / 1_000
}

/**
    Converts nanoseconds to milliseconds.

    - parameter ns: Time in nanoseconds
    - returns: Time in milliseconds
 */
public func ns2ms(_ ns: Double) -> Double {
    return ns / 1_000_000
}

/**
   Converts nanoseconds to seconds.

   - parameter ns: Time in nanoseconds
   - returns: Time in seconds
*/
public func ns2s(_ ns: Double) -> Double {
    return ns / 1_000_000_000
}

/**
    Converts nanoseconds to minutes.

    - parameter ns: Time in nanoseconds
    - returns: Time in minutes
 */
public func ns2min(_ ns: Double) -> Double {
    return ns / 60_000_000_000
}

/**
    Converts nanoseconds to hours.

    - parameter ns: Time in nanoseconds
    - returns: Time in hours
 */
public func ns2hr(_ ns: Double) -> Double {
    return ns / 3_600_000_000_000
}

/**
    Converts nanoseconds to days.

    - parameter ns: Time in nanoseconds
    - returns: Time in days
 */
public func ns2d(_ ns: Double) -> Double {
    return ns / 86_400_000_000_000
}
