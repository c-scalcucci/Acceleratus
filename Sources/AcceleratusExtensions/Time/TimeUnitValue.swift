//
//  TimeUnitValue.swift
//
//  Created by Chris Scalcucci on 4/21/20.
//

import Foundation

public protocol TimeUnitValue {
    func valueString() -> String
    func value() -> Self
}

public extension TimeUnitValue {
    func valueString() -> String { return String(describing: self) }
    func value() -> Self { return self }
}

extension Int    : TimeUnitValue {}
extension Int8   : TimeUnitValue {}
extension Int16  : TimeUnitValue {}
extension Int32  : TimeUnitValue {}
extension Int64  : TimeUnitValue {}
extension Double : TimeUnitValue {}
extension Float  : TimeUnitValue {}
