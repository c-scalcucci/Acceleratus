//
//  Decimal+Extension.swift
//  
//
//  Created by Chris Scalcucci on 3/17/22.
//

import Foundation

public extension Decimal {

    static let one = Decimal(1)

    // MARK: Operations

    @inlinable
    mutating func round(_ scale: Int, _ roundingMode: NSDecimalNumber.RoundingMode) {
        var localCopy = self
        NSDecimalRound(&self, &localCopy, scale, roundingMode)
    }

    // Non-mutating to protect reference

    @inlinable
    func rounded(_ scale: Int, _ roundingMode: NSDecimalNumber.RoundingMode) -> Decimal {
        var result = Decimal()
        var localCopy = self
        NSDecimalRound(&result, &localCopy, scale, roundingMode)
        return result
    }

    @inlinable
    func divided(_ divisor: Decimal, _ scale: Int, _ roundingMode: NSDecimalNumber.RoundingMode) -> Decimal {
        var result = Decimal()
        var localCopy = self
        var localDivisor = divisor
        NSDecimalDivide(&result, &localCopy, &localDivisor, roundingMode)
        return result.rounded(scale, roundingMode)
    }

    // Mutating to avoid double references

    @inlinable
    mutating func roundedLocal(_ scale: Int, _ roundingMode: NSDecimalNumber.RoundingMode) -> Decimal {
        var result = Decimal()
        NSDecimalRound(&result, &self, scale, roundingMode)
        return result
    }

    @inlinable
    mutating func divided(_ divisor: inout Decimal, _ scale: Int, _ roundingMode: NSDecimalNumber.RoundingMode) -> Decimal {
        var result = Decimal()
        NSDecimalDivide(&result, &self, &divisor, roundingMode)
        return result.rounded(scale, roundingMode)
    }

    // MARK: Values

    @inlinable
    var doubleValue : Double {
        return NSDecimalNumber(decimal: self).doubleValue
    }

    @inlinable
    var floatValue : Float {
        return NSDecimalNumber(decimal: self).floatValue
    }

    @inlinable
    var boolValue : Bool {
        return NSDecimalNumber(decimal: self).boolValue
    }

    // MARK: Signed Integers

    @inlinable
    var intValue : Int {
        return NSDecimalNumber(decimal: self).intValue
    }

    @inlinable
    var int8Value : Int8 {
        return NSDecimalNumber(decimal: self).int8Value
    }

    @inlinable
    var int16Value : Int16 {
        return NSDecimalNumber(decimal: self).int16Value
    }

    @inlinable
    var int32Value : Int32 {
        return NSDecimalNumber(decimal: self).int32Value
    }

    @inlinable
    var int64Value : Int64 {
        return NSDecimalNumber(decimal: self).int64Value
    }

    // MARK: Unsigned Integers

    @inlinable
    var uIntValue : UInt {
        return NSDecimalNumber(decimal: self).uintValue
    }

    @inlinable
    var uInt8Value : UInt8 {
        return NSDecimalNumber(decimal: self).uint8Value
    }

    @inlinable
    var uInt16Value : UInt16 {
        return NSDecimalNumber(decimal: self).uint16Value
    }

    @inlinable
    var uInt32Value : UInt32 {
        return NSDecimalNumber(decimal: self).uint32Value
    }

    @inlinable
    var uInt64Value : UInt64 {
        return NSDecimalNumber(decimal: self).uint64Value
    }
}
