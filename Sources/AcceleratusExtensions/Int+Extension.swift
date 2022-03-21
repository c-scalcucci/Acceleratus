//
//  Int+Extension.swift
//  
//
//  Created by Chris Scalcucci on 3/17/22.
//

import Foundation

public extension Int {
    func hexString(_ padding: Int = 2) -> String {
        return String(format: "%0\(padding)X", self)
    }

    static func hexString(_ int: Int, _ padding: Int = 2) -> String {
        return String(format: "%0\(padding)X", int)
    }
}

public extension UInt16 {
    func hexString(_ padding: Int = 2) -> String {
        return String(format: "%0\(padding)X", self)
    }

    static func hexString(_ uint: UInt16, _ padding: Int = 2) -> String {
        return String(format: "%0\(padding)X", uint)
    }
}
