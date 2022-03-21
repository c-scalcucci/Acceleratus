//
//  TimeUnit+Double.swift
//
//  Created by Chris Scalcucci on 4/20/20.
//

import Foundation

public extension Double {

    func nanoseconds(from: TimeUnit) -> Double {
        switch from {
        case .nanoseconds:
            return self
        case .microseconds:
            return us2ns(self)
        case .milliseconds:
            return ms2ns(self)
        case .seconds:
            return s2ns(self)
        case .minutes:
            return min2ns(self)
        case .hours:
            return hr2ns(self)
        case .days:
            return d2ns(self)
        }
    }

    func microseconds(from: TimeUnit) -> Double {
        switch from {
        case .nanoseconds:
            return ns2us(self)
        case .microseconds:
            return self
        case .milliseconds:
            return ms2us(self)
        case .seconds:
            return s2us(self)
        case .minutes:
            return min2us(self)
        case .hours:
            return hr2us(self)
        case .days:
            return d2us(self)
        }
    }

    func milliseconds(from: TimeUnit) -> Double {
        switch from {
        case .nanoseconds:
            return ns2ms(self)
        case .microseconds:
            return us2ms(self)
        case .milliseconds:
            return self
        case .seconds:
            return s2ms(self)
        case .minutes:
            return min2ms(self)
        case .hours:
            return hr2ms(self)
        case .days:
            return d2ms(self)
        }
    }

    func seconds(from: TimeUnit) -> Double {
        switch from {
        case .nanoseconds:
            return ns2s(self)
        case .microseconds:
            return us2s(self)
        case .milliseconds:
            return ms2s(self)
        case .seconds:
            return self
        case .minutes:
            return min2s(self)
        case .hours:
            return hr2s(self)
        case .days:
            return d2s(self)
        }
    }

    func minutes(from: TimeUnit) -> Double {
        switch from {
        case .nanoseconds:
            return ns2min(self)
        case .microseconds:
            return us2min(self)
        case .milliseconds:
            return ms2min(self)
        case .seconds:
            return s2min(self)
        case .minutes:
            return self
        case .hours:
            return hr2min(self)
        case .days:
            return d2min(self)
        }
    }

    func hours(from: TimeUnit) -> Double {
        switch from {
        case .nanoseconds:
            return ns2hr(self)
        case .microseconds:
            return us2hr(self)
        case .milliseconds:
            return ms2hr(self)
        case .seconds:
            return s2hr(self)
        case .minutes:
            return min2hr(self)
        case .hours:
            return self
        case .days:
            return d2hr(self)
        }
    }

    func days(from: TimeUnit) -> Double {
        switch from {
        case .nanoseconds:
            return ns2d(self)
        case .microseconds:
            return us2d(self)
        case .milliseconds:
            return ms2d(self)
        case .seconds:
            return s2d(self)
        case .minutes:
            return min2d(self)
        case .hours:
            return hr2d(self)
        case .days:
            return self
        }
    }
}
