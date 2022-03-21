//
//  UUID+Extension.swift
//  
//
//  Created by Chris Scalcucci on 3/17/22.
//

import Foundation

public extension UUID {
    func getLeastSignificantBits() -> Int64 {
        let bytes = Array([uuid.8, uuid.9, uuid.10, uuid.11, uuid.12, uuid.13, uuid.14, uuid.15].reversed())
        return UnsafePointer(bytes).withMemoryRebound(to: Int64.self, capacity: 1) { $0.pointee }
    }
}
