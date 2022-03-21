//
//  TimeUnit+Minutes.swift
//
//  Created by Chris Scalcucci on 4/20/20.
//

import Foundation

// =============================
// MARK:- Minutes
// =============================

/**
    Converts minutes to nanoseconds.

    - parameter min: Time in minutes
    - returns: Time in nanoseconds
 */
public func min2ns(_ min: Double) -> Double {
    return min * 60_000_000_000
}

/**
    Converts minutes to microseconds.

    - parameter min: Time in minutes
    - returns: Time in microseconds
 */
public func min2us(_ min: Double) -> Double {
    return min * 60_000_000
}

/**
    Converts minutes to milliseconds.

    - parameter min: Time in minutes
    - returns: Time in milliseconds
 */
public func min2ms(_ min: Double) -> Double {
    return min * 60_000
}

/**
   Converts minutes to seconds.

   - parameter min: Time in minutes
   - returns: Time in seconds
*/
public func min2s(_ min: Double) -> Double {
    return min * 60
}

/**
   Converts minutes to hours.

   - parameter mins: Time in minutes
   - returns: Time in hours
*/
public func min2hr(_ min: Double) -> Double {
    return min / 60
}

/**
   Converts minutes to days.

   - parameter mins: Time in minutes
   - returns: Time in days
*/
public func min2d(_ min: Double) -> Double {
    return min / 1_440
}
