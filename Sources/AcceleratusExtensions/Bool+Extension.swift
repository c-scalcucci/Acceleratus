//
//  Bool+Extension.swift
//  
//
//  Created by Chris Scalcucci on 3/16/22.
//

import Foundation

@inlinable
public func |= (lhs: inout Bool, rhs: Bool) {
    lhs = lhs || rhs
}

@inlinable
public func &= (lhs: inout Bool, rhs: Bool) {
    lhs = lhs && rhs
}

@inlinable
public func ^= (lhs: inout Bool, rhs: Bool) {
    lhs = lhs != rhs
}
