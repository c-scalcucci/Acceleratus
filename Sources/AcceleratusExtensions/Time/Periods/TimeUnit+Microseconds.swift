//
//  TimeUnit+Microseconds.swift
//
//  Created by Chris Scalcucci on 4/20/20.
//

import Foundation

// =============================
// MARK:- Microseconds
// =============================

/**
    Converts microseconds to nanoseconds.

    - parameter ns: Time in microseconds
    - returns: Time in nanoseconds
 */
public func us2ns(_ us: Double) -> Double {
    return us * 1_000
}

/**
    Converts microseconds to milliseconds.

    - parameter ns: Time in microseconds
    - returns: Time in milliseconds
 */
public func us2ms(_ us: Double) -> Double {
    return us / 1_000
}

/**
   Converts microseconds to seconds.

   - parameter ns: Time in microseconds
   - returns: Time in seconds
*/
public func us2s(_ us: Double) -> Double {
    return us / 1_000_000
}

/**
    Converts microseconds to minutes.

    - parameter ns: Time in microseconds
    - returns: Time in minutes
 */
public func us2min(_ us: Double) -> Double {
    return us / 60_000_000
}

/**
    Converts microseconds to hours.

    - parameter ns: Time in microseconds
    - returns: Time in hours
 */
public func us2hr(_ us: Double) -> Double {
    return us / 3_600_000_000
}

/**
    Converts microseconds to days.

    - parameter ns: Time in microseconds
    - returns: Time in days
 */
public func us2d(_ us: Double) -> Double {
    return us / 86_400_000_000
}
