//
//  Character+Extension.swift
//  
//
//  Created by Chris Scalcucci on 3/17/22.
//

import Foundation

public extension Int {
    @inlinable
    static func char(_ char: Character) -> Int? {
        return Int(char.unicodeScalars[char.unicodeScalars.startIndex].value)
    }
}

public extension Character {
    @inlinable
    func int() -> Int {
        return Int.char(self)!
    }
}

@inlinable
public func -(left: Character, right: Character) -> Int {
    return left.int() - right.int()
}

@inlinable
public func +(left: Character, right: Character) -> Int {
    return left.int() + right.int()
}

@inlinable
public func +=(left: inout String, right: Int) {
    left += "\(UnicodeScalar(right)!)"
}

@inlinable
public func +=(left: inout Character, right: Int) {
    left = left + right
}

@inlinable
public func +(left: Character, right: Int) -> Character {
    return Character(UnicodeScalar(Int(left.unicodeScalars[left.unicodeScalars.startIndex].value) + right) ?? left.unicodeScalars[left.unicodeScalars.startIndex])
}

@inlinable
public func -=(left: inout Character, right: Int) {
    left = left - right
}

@inlinable
public func -(left: Character, right: Int) -> Character {
    return Character(UnicodeScalar(Int(left.unicodeScalars[left.unicodeScalars.startIndex].value) - right) ?? left.unicodeScalars[left.unicodeScalars.startIndex])
}

@inlinable
public func >(left: Character, right: Int) -> Bool {
    return left.int() > right
}

@inlinable
public func >=(left: Character, right: Int) -> Bool {
    return left.int() >= right
}

@inlinable
public func <(left: Character, right: Int) -> Bool {
    return left.int() < right
}

@inlinable
public func <=(left: Character, right: Int) -> Bool {
    return left.int() <= right
}
