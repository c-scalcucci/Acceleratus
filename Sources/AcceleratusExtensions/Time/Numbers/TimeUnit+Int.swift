//
//  TimeUnit+Int.swift
//
//  Created by Chris Scalcucci on 4/20/20.
//

import Foundation

public extension Int64 {

    func nanoseconds(_ from: TimeUnit) -> Int64 {
        switch from {
        case .nanoseconds:
            return self
        case .microseconds:
            return Int64(us2ns(Double(self)))
        case .milliseconds:
            return Int64(ms2ns(Double(self)))
        case .seconds:
            return Int64(s2ns(Double(self)))
        case .minutes:
            return Int64(min2ns(Double(self)))
        case .hours:
            return Int64(hr2ns(Double(self)))
        case .days:
            return Int64(d2ns(Double(self)))
        }
    }

    func microseconds(_ from: TimeUnit) -> Int64 {
        switch from {
        case .nanoseconds:
            return Int64(ns2us(Double(self)))
        case .microseconds:
            return self
        case .milliseconds:
            return Int64(ms2us(Double(self)))
        case .seconds:
            return Int64(s2us(Double(self)))
        case .minutes:
            return Int64(min2us(Double(self)))
        case .hours:
            return Int64(hr2us(Double(self)))
        case .days:
            return Int64(d2us(Double(self)))
        }
    }

    func milliseconds(from: TimeUnit) -> Int64 {
        switch from {
        case .nanoseconds:
            return Int64(ns2ms(Double(self)))
        case .microseconds:
            return Int64(us2ms(Double(self)))
        case .milliseconds:
            return self
        case .seconds:
            return Int64(s2ms(Double(self)))
        case .minutes:
            return Int64(min2ms(Double(self)))
        case .hours:
            return Int64(hr2ms(Double(self)))
        case .days:
            return Int64(d2ms(Double(self)))
        }
    }

    func seconds(from: TimeUnit) -> Int64 {
        switch from {
        case .nanoseconds:
            return Int64(ns2s(Double(self)))
        case .microseconds:
            return Int64(us2s(Double(self)))
        case .milliseconds:
            return Int64(ms2s(Double(self)))
        case .seconds:
            return self
        case .minutes:
            return Int64(min2s(Double(self)))
        case .hours:
            return Int64(hr2s(Double(self)))
        case .days:
            return Int64(d2s(Double(self)))
        }
    }

    func minutes(from: TimeUnit) -> Int64 {
        switch from {
        case .nanoseconds:
            return Int64(ns2min(Double(self)))
        case .microseconds:
            return Int64(us2min(Double(self)))
        case .milliseconds:
            return Int64(ms2min(Double(self)))
        case .seconds:
            return Int64(s2min(Double(self)))
        case .minutes:
            return self
        case .hours:
            return Int64(hr2min(Double(self)))
        case .days:
            return Int64(d2min(Double(self)))
        }
    }

    func hours(from: TimeUnit) -> Int64 {
        switch from {
        case .nanoseconds:
            return Int64(ns2hr(Double(self)))
        case .microseconds:
            return Int64(us2hr(Double(self)))
        case .milliseconds:
            return Int64(ms2hr(Double(self)))
        case .seconds:
            return Int64(s2hr(Double(self)))
        case .minutes:
            return Int64(min2hr(Double(self)))
        case .hours:
            return self
        case .days:
            return Int64(d2hr(Double(self)))
        }
    }

    func days(from: TimeUnit) -> Int64 {
        switch from {
        case .nanoseconds:
            return Int64(ns2d(Double(self)))
        case .microseconds:
            return Int64(us2d(Double(self)))
        case .milliseconds:
            return Int64(ms2d(Double(self)))
        case .seconds:
            return Int64(s2d(Double(self)))
        case .minutes:
            return Int64(min2d(Double(self)))
        case .hours:
            return Int64(hr2d(Double(self)))
        case .days:
            return self
        }
    }
}

public extension Int {

    func nanoseconds(_ from: TimeUnit) -> Int {
        switch from {
        case .nanoseconds:
            return self
        case .microseconds:
            return Int(us2ns(Double(self)))
        case .milliseconds:
            return Int(ms2ns(Double(self)))
        case .seconds:
            return Int(s2ns(Double(self)))
        case .minutes:
            return Int(min2ns(Double(self)))
        case .hours:
            return Int(hr2ns(Double(self)))
        case .days:
            return Int(d2ns(Double(self)))
        }
    }

    func microseconds(_ from: TimeUnit) -> Int {
        switch from {
        case .nanoseconds:
            return Int(ns2us(Double(self)))
        case .microseconds:
            return self
        case .milliseconds:
            return Int(ms2us(Double(self)))
        case .seconds:
            return Int(s2us(Double(self)))
        case .minutes:
            return Int(min2us(Double(self)))
        case .hours:
            return Int(hr2us(Double(self)))
        case .days:
            return Int(d2us(Double(self)))
        }
    }

    func milliseconds(from: TimeUnit) -> Int {
        switch from {
        case .nanoseconds:
            return Int(ns2ms(Double(self)))
        case .microseconds:
            return Int(us2ms(Double(self)))
        case .milliseconds:
            return self
        case .seconds:
            return Int(s2ms(Double(self)))
        case .minutes:
            return Int(min2ms(Double(self)))
        case .hours:
            return Int(hr2ms(Double(self)))
        case .days:
            return Int(d2ms(Double(self)))
        }
    }

    func seconds(from: TimeUnit) -> Int {
        switch from {
        case .nanoseconds:
            return Int(ns2s(Double(self)))
        case .microseconds:
            return Int(us2s(Double(self)))
        case .milliseconds:
            return Int(ms2s(Double(self)))
        case .seconds:
            return self
        case .minutes:
            return Int(min2s(Double(self)))
        case .hours:
            return Int(hr2s(Double(self)))
        case .days:
            return Int(d2s(Double(self)))
        }
    }

    func minutes(from: TimeUnit) -> Int {
        switch from {
        case .nanoseconds:
            return Int(ns2min(Double(self)))
        case .microseconds:
            return Int(us2min(Double(self)))
        case .milliseconds:
            return Int(ms2min(Double(self)))
        case .seconds:
            return Int(s2min(Double(self)))
        case .minutes:
            return self
        case .hours:
            return Int(hr2min(Double(self)))
        case .days:
            return Int(d2min(Double(self)))
        }
    }

    func hours(from: TimeUnit) -> Int {
        switch from {
        case .nanoseconds:
            return Int(ns2hr(Double(self)))
        case .microseconds:
            return Int(us2hr(Double(self)))
        case .milliseconds:
            return Int(ms2hr(Double(self)))
        case .seconds:
            return Int(s2hr(Double(self)))
        case .minutes:
            return Int(min2hr(Double(self)))
        case .hours:
            return self
        case .days:
            return Int(d2hr(Double(self)))
        }
    }

    func days(from: TimeUnit) -> Int {
        switch from {
        case .nanoseconds:
            return Int(ns2d(Double(self)))
        case .microseconds:
            return Int(us2d(Double(self)))
        case .milliseconds:
            return Int(ms2d(Double(self)))
        case .seconds:
            return Int(s2d(Double(self)))
        case .minutes:
            return Int(min2d(Double(self)))
        case .hours:
            return Int(hr2d(Double(self)))
        case .days:
            return self
        }
    }
}
