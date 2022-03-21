//
//  File.swift
//  
//
//  Created by Chris Scalcucci on 3/21/22.
//

import Foundation

public class HashableObject : Hashable {
    var uuid = UUID()

    public static func ==(lhs: HashableObject, rhs: HashableObject) -> Bool {
        return lhs.uuid == rhs.uuid
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(uuid.uuidString)
    }
}
