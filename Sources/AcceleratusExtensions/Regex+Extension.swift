//
//  Regex+Extension.swift
//  
//
//  Created by Chris Scalcucci on 3/17/22.
//

import Foundation

public extension NSRegularExpression {
    func matches(_ text: String) -> Bool {
        return !self.matches(in: text, range: NSRange(location: 0, length: text.utf16.count)).isEmpty
    }
}
