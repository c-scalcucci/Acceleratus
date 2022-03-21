//
//  TimeUnit+Hours.swift
//
//  Created by Chris Scalcucci on 4/20/20.
//

import Foundation

// =============================
// MARK:- Hours
// =============================

/**
    Converts hours to nanoseconds

    - parameter hr: Time in hours
    - returns: Time in nanoseconds
 */
public func hr2ns(_ hr: Double) -> Double {
    return hr * 3_600_000_000_000
}

/**
    Converts hours to microseconds

    - parameter hr: Time in hours
    - returns: Time in microseconds
 */
public func hr2us(_ hr: Double) -> Double {
    return hr * 3_600_000_000
}

/**
    Converts hours to milliseconds

    - parameter hr: Time in hours
    - returns: Time in milliseconds
 */
public func hr2ms(_ hr: Double) -> Double {
    return hr * 3_600_000
}

/**
    Converts hours to seconds

    - parameter hr: Time in hours
    - returns: Time in seconds
 */
public func hr2s(_ hr: Double) -> Double {
    return hr * 3_600
}

/**
    Converts hours to minutes

    - parameter hr: Time in hours
    - returns: Time in minutes
 */
public func hr2min(_ hr: Double) -> Double {
    return hr * 60
}

/**
    Converts hours to days

    - parameter hr: Time in hours
    - returns: Time in days
 */
public func hr2d(_ hr: Double) -> Double {
    return hr / 24
}
