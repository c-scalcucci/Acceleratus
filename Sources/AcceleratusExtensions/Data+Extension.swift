//
//  Data+Extension.swift
//  
//
//  Created by Chris Scalcucci on 3/17/22.
//

import Foundation

public extension Data {
    init<T>(from value: T) {
        self = Swift.withUnsafeBytes(of: value) { Data($0) }
    }

    func to<T>(_ type: T.Type) -> T? where T: ExpressibleByIntegerLiteral {
        var value: T = 0
        guard count >= MemoryLayout.size(ofValue: value) else { return nil }
        _ = Swift.withUnsafeMutableBytes(of: &value, { copyBytes(to: $0)} )
        return value
    }
    
    init(reading input: InputStream, bufferSize: Int = 1024) throws {
        self.init()

        input.open()
        defer { input.close() }

        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)
        defer { buffer.deallocate() }

        while input.hasBytesAvailable {
            let read = input.read(buffer, maxLength: bufferSize)
            if read < 0 {
                //Stream error occured
                throw input.streamError!
            } else if read == 0 {
                //EOF
                break
            }
            self.append(buffer, count: read)
        }
    }

    @inlinable
    func subdata(_ range: ClosedRange<Index>) -> Data {
        return subdata(in: range.lowerBound ..< range.upperBound + 1)
    }

    @inlinable
    var utf8String : String? {
        return String(data: self, encoding: .utf8)
    }

    @inlinable
    var byteArray : [UInt8] {
        return [UInt8](self)
    }

    @inlinable
    var hexDescription: String {
        return self.map { String(format: "%02hhx", $0) }.joined()
    }

}
