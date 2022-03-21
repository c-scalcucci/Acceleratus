//
//  Time.swift
//
//  Created by Chris Scalcucci on 4/21/20.
//

import Foundation

/**
    Supported initialization forms:

        - 'value unit' (e.g. '5 seconds' OR '5seconds')
        - 'value shortUnit' (e.g. '5 s' OR '5s')

    To create a custom type from rawValue, include the numeric value,
    unit value, and shortUnit value in that order.

    These provided custom values must be separated by a '*' character
    to be considered.

    NOTE: Custom values CANNOT use a unit or shortUnit already claimed by
    the native types. (For example, seconds already claimed 's' as a shortUnit).

    e.g. Time(rawValue: "5.75*Roman Years*ry")
        - rawValue called later would produce ("5.75 Roman Years")
        - shortValue called later would produce ("5.75ry")
 */
public enum Time : RawRepresentable {

    public typealias RawValue = String

    case nanoseconds  (TimeUnitValue)
    case microseconds (TimeUnitValue)
    case milliseconds (TimeUnitValue)
    case seconds      (TimeUnitValue)
    case minutes      (TimeUnitValue)
    case hours        (TimeUnitValue)
    case days         (TimeUnitValue)
    case custom       (unit:String, shortUnit: String, value: TimeUnitValue)

    public var rawValue: String {
        switch self {
        case .nanoseconds,
             .microseconds,
             .milliseconds,
             .seconds,
             .minutes,
             .hours,
             .days,
             .custom:
            return number.valueString() + " " + unit
        }
    }

    public var shortValue : String {
        switch self {
        case .nanoseconds,
             .microseconds,
             .milliseconds,
             .seconds,
             .minutes,
             .hours,
             .days,
             .custom:
            return number.valueString() + shortUnit
        }
    }

    public var number : TimeUnitValue {
        switch self {
        case .nanoseconds  (let x),
             .microseconds (let x),
             .milliseconds (let x),
             .seconds      (let x),
             .minutes      (let x),
             .hours        (let x),
             .days         (let x):
            return x
        case .custom (_, _, let value):
            return value
        }
    }

    public var unit : String {
        switch self {
        case .nanoseconds  : return "nanoseconds"
        case .microseconds : return "microseconds"
        case .milliseconds : return "milliseconds"
        case .seconds      : return "seconds"
        case .minutes      : return "minutes"
        case .hours        : return "hours"
        case .days         : return "days"

        case .custom (let unit, _, _):
            return unit
        }
    }

    public var shortUnit : String {
        switch self {
        case .nanoseconds  : return "ns"
        case .microseconds : return "us"
        case .milliseconds : return "ms"
        case .seconds      : return "s"
        case .minutes      : return "m"
        case .hours        : return "hr"
        case .days         : return "d"

        case .custom (_, let short, _):
            return short
        }
    }

    // ============================================
    // MARK:- Custom RawValue Initialization
    // ============================================

    /**
        Supported initialization forms:

            - 'value unit' (e.g. '5 seconds' OR '5seconds')
            - 'value shortUnit' (e.g. '5 s' OR '5s')

        To create a custom type from rawValue, include the numeric value,
        unit value, and shortUnit value in that order.

        These provided custom values must be separated by a '*' character
        to be considered.

        NOTE: Custom values CANNOT use a unit or shortUnit already claimed by
        the native types. (For example, seconds already claimed 's' as a shortUnit).

        e.g. Time(rawValue: "5.75*Roman Years*ry")
            - rawValue called later would produce ("5.75 Roman Years")
            - shortValue called later would produce ("5.75ry")

        - parameter rawValue: The raw string to attempt to create a Time from
        - returns: A valid native or custom Time object, or nil if invalid format
     */
    public init?(rawValue: String) {
        // First we split the provided value into the custom type separator
        let customComponents = rawValue.split(separator: "*")

        // If there are not 3 values, we may be dealing with a native type
        if customComponents.count != 3 {
            // First we check for a whitespace separated input
            let nativeComponents = rawValue.split(separator: " ")

            // If there are not 2 distinct values, our native type may be 'squished'
            if nativeComponents.count == 2 {
                // For a whitespace separated native value, the first value must be a number
                guard let doubleValue = Double(nativeComponents[0]) else {
                    return nil
                }
                // We have a valid numberic value, now check for a valid native unit or short unit
                if let time = Time.nativeInit(String(nativeComponents[1]), doubleValue) {
                    self = time
                }
                return nil
            } else {
                // Check for a 'squished' native type
                guard let time = Time.squishedInit(rawValue) else {
                    return nil
                }
                self = time
            }
        } else {
            // We parse the custom type starting with a valid numeric value
            guard let doubleValue = Double(customComponents[0]) else {
                return nil
            }
            // Whatever you passed in for the next two values will be used in the custom type
            self = Time.custom(unit: String(customComponents[1]),
                               shortUnit: String(customComponents[1]),
                               value: doubleValue)
        }
    }

    /**
        Attempts to parse a native Time object in the case that the provided
        rawValue does not use whitespace to separate numeric value from unit value.

        e.g. '5s' would return Time.seconds(5)

        - parameter input: The raw string to parse
        - returns: A valid native Time object, or nil
     */
    private static func squishedInit(_ input: String) -> Time? {
        var numericAccumulator : String = ""
        var hasDecimal : Bool = false
        var earlyInvalid : Bool = false

        parsing: for char in input {
            switch char {
            case ".":
                // We can only have one decimal in a native rawValue and it can't appear before a number
                if hasDecimal || numericAccumulator.count == 0 { earlyInvalid = true; break parsing }

                hasDecimal = true
            case "0", "1", "2", "3", "4", "5", "6", "7", "8", "9":
                numericAccumulator.append(char)
            default:
                // If we have hit a non-decimal, non-numeric value, we are done parsing
                break parsing
            }
        }

        // If the numeric parsing failed and returned early, return nil
        if earlyInvalid { return nil }

        // Now check that we can construct a valid numeric value from the accumulator
        guard let doubleValue = Double(numericAccumulator) else { return nil }

        // Drop the numeric value from the rawValue to get our unit value
        return nativeInit(String(input.dropFirst(numericAccumulator.count)), doubleValue)
    }

    /**
        Attempts to parse a native Time object from a given string when the
        numeric value is known.

        This function basically takes the unit string and attempts to match it
        to one of the native unit types.

        e.g. nativeInit("seconds", 5") would return Time.seconds(5)

        - parameter unit: The raw string to parse for a valid unit
        - parameter value: The known numeric value for the Time object
        - returns: A valid native Time object, or nil
     */
    private static func nativeInit(_ unit: String, _ value: TimeUnitValue) -> Time? {
        switch unit {
        // First the long unit values
        case "nanoseconds", "ns":
            return .nanoseconds(value)
        case "microseconds", "us":
            return .microseconds(value)
        case "milliseconds", "ms":
            return .milliseconds(value)
        case "seconds", "s":
            return .seconds(value)
        case "minutes", "mins", "min":
            return .minutes(value)
        case "hours", "hrs", "hr":
            return .hours(value)
        case "days", "d":
            return .days(value)
        default: return nil
        }
    }

}
