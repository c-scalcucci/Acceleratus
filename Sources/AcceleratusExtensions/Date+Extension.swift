//
//  Date+Extension.swift
//  
//
//  Created by Chris Scalcucci on 12/9/19.
//

import Foundation

public extension Date {
    /**
        Returns the current time in milliseconds from target date.
        Default is 1970.

        - returns: Time in milliseconds from current date
     */
    static func currentSystemTimeMillis() -> Int64 {
        var darwinTime : timeval = timeval(tv_sec: 0, tv_usec: 0)
        gettimeofday(&darwinTime, nil)
        return (Int64(darwinTime.tv_sec) * 1000) + Int64(darwinTime.tv_usec / 1000)
    }
}
