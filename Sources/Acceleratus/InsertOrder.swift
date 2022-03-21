//
//  InsertOrder.swift
//  
//
//  Created by Chris Scalcucci on 3/3/22.
//

import Foundation

public enum InsertOrder<T> {
    case temporal // New elements are added to the tail
    case insertSort (fn: (T, T) -> Bool)
}
