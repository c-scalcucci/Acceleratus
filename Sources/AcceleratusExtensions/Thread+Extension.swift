//
//  Thread+Extension.swift
//  
//
//  Created by Chris Scalcucci on 3/17/22.
//

import Foundation

public extension Thread {

    @available(OSX 10.12, *)
    convenience init(_ name: String,
                     _ priority: Double? = nil,
                     _ block: @escaping () -> Void) {
        self.init(block: block)
        self.name = name

        if let priority = priority {
            self.threadPriority = priority
        }
    }
}
