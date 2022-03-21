//
//  Casting.swift
//  
//
//  Created by Chris Scalcucci on 3/17/22.
//

import Foundation

public struct CastingError: Error {
    public let fromType: Any.Type
    public let toType: Any.Type

    public init<FromType, ToType>(from fromType: FromType.Type,
                                  to toType: ToType.Type) {
        self.fromType = fromType
        self.toType = toType
    }
}

extension CastingError: LocalizedError {
    public var localizedDescription: String {
        return "Can not cast from \(fromType) to \(toType)"
    }
}

extension CastingError: CustomStringConvertible {
    public var description: String {
        return localizedDescription
    }
}


// MARK: - Dictionary cast extensions

public extension Dictionary {
    func toData(_ options: JSONSerialization.WritingOptions = []) throws -> Data {
        return try JSONSerialization.data(withJSONObject: self, options: options)
    }
}

// MARK: - Data cast extensions

public extension Data {
    func toDictionary(_ options: JSONSerialization.ReadingOptions = []) throws -> [String: Any] {
        return try to([String: Any].self, options)
    }

    func to<T>(_ type: T.Type, _ options: JSONSerialization.ReadingOptions = []) throws -> T {
        guard let result = try JSONSerialization.jsonObject(with: self, options: options) as? T else {
            throw CastingError(from: type, to: T.self)
        }
        return result
    }
}

// MARK: - String cast extensions

public extension String {
    func asJSON<T>(_ type: T.Type, using encoding: String.Encoding = .utf8) throws -> T {
        guard let data = data(using: encoding) else { throw CastingError(from: type, to: T.self) }
        return try data.to(T.self)
    }

    func asJSONToDictionary(using encoding: String.Encoding = .utf8) throws -> [String: Any] {
        return try asJSON([String: Any].self, using: encoding)
    }
}
