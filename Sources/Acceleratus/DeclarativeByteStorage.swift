//
//  DeclarativeByteStorage.swift
//  
//
//  Created by Chris Scalcucci on 6/10/22.
//

import Foundation

/**
     An object that conforms to DeclarativeByteStorage will estimate how
     many bytes it believes it occupies on the heap.

     For example, an NSData would take up the size of its pointer and the amount
     of data it contains, same with an NSString.

     For a class with properties (and those recursive properties of properties) it is
     important that when adhering to this protocol it considers those properties and their
     estimated byte size in its calculation.

     Consider the classes
     class A : NSObject, DeclarativeByteStorage {
        var someData : Data
        var someInt: Int

        var storageEstimate : Int {
            // Data and Int conform to DeclarativeByteStorage
            return someData.storageEstimate + someInt.storageEstimate
        }
     }

     class B : NSObject, DeclarativeByteStorage {
        var someData : Data
        var someClass : A

         var storageEstimate : Int {
            // Data and A conform to DeclarativeByteStorage
            return someData.storageEstimate + someClass.storageEstimate
         }
     }
 */
public protocol DeclarativeByteStorage {
    // The estimated amount of bytes this object takes in memory
    var storageEstimate : Int { get }
}

extension Data : DeclarativeByteStorage {
    public var storageEstimate: Int {
        return MemoryLayout<Self>.size + self.count
    }
}

extension NSData : DeclarativeByteStorage {
    public var storageEstimate: Int {
        return MemoryLayout<Self>.size + self.count
    }
}

extension String : DeclarativeByteStorage {
    public var storageEstimate: Int {
        return MemoryLayout<Self>.size + self.utf8.count
    }
}

extension NSString : DeclarativeByteStorage {
    public var storageEstimate: Int {
        return MemoryLayout<Self>.size + self.lengthOfBytes(using: String.Encoding.utf8.rawValue)
    }
}

//
// MARK: UIKit
//

#if canImport(UIKit)

import UIKit

extension UIImage : DeclarativeByteStorage {
    public var storageEstimate: Int {
        let baseSize = MemoryLayout<Self>.size
        guard let cgImage = self.cgImage else { return baseSize }
        return baseSize + (cgImage.height * cgImage.bytesPerRow)
    }
}
#endif

//
// MARK: Fixed Width Integers
//

extension Int : DeclarativeByteStorage {
    public var storageEstimate: Int {
        return MemoryLayout<Self>.size
    }
}

extension Int8 : DeclarativeByteStorage {
    public var storageEstimate: Int {
        return MemoryLayout<Self>.size
    }
}

extension Int16 : DeclarativeByteStorage {
    public var storageEstimate: Int {
        return MemoryLayout<Self>.size
    }
}

extension Int32 : DeclarativeByteStorage {
    public var storageEstimate: Int {
        return MemoryLayout<Self>.size
    }
}

extension Int64 : DeclarativeByteStorage {
    public var storageEstimate: Int {
        return MemoryLayout<Self>.size
    }
}

extension UInt : DeclarativeByteStorage {
    public var storageEstimate: Int {
        return MemoryLayout<Self>.size
    }
}

extension UInt8 : DeclarativeByteStorage {
    public var storageEstimate: Int {
        return MemoryLayout<Self>.size
    }
}

extension UInt16 : DeclarativeByteStorage {
    public var storageEstimate: Int {
        return MemoryLayout<Self>.size
    }
}

extension UInt32 : DeclarativeByteStorage {
    public var storageEstimate: Int {
        return MemoryLayout<Self>.size
    }
}

extension UInt64 : DeclarativeByteStorage {
    public var storageEstimate: Int {
        return MemoryLayout<Self>.size
    }
}

//
// MARK: Other Numbers
//

extension Double : DeclarativeByteStorage {
    public var storageEstimate: Int {
        return MemoryLayout<Self>.size
    }
}

extension CGFloat : DeclarativeByteStorage {
    public var storageEstimate: Int {
        return MemoryLayout<Self>.size
    }
}

extension Float : DeclarativeByteStorage {
    public var storageEstimate: Int {
        return MemoryLayout<Self>.size
    }
}

@available(iOS 14, *)
extension Float16 : DeclarativeByteStorage {
    public var storageEstimate: Int {
        return MemoryLayout<Self>.size
    }
}

//
// MARK: Other Primitives
//

extension CGPoint : DeclarativeByteStorage {
    public var storageEstimate: Int {
        return MemoryLayout<Self>.size
    }
}

//
// MARK: Collections
//

extension Array : DeclarativeByteStorage where Element : DeclarativeByteStorage {
    public var storageEstimate: Int {
        return MemoryLayout<Self>.size + self.reduce(into: 0) { $0 += $1.storageEstimate }
    }
}

extension NSArray : DeclarativeByteStorage {
    public var storageEstimate: Int {
        return MemoryLayout<Self>.size + self.reduce(into: 0) {
            $0 += ($1 as? DeclarativeByteStorage)?.storageEstimate ?? 0
        }
    }
}

extension Set : DeclarativeByteStorage where Element : DeclarativeByteStorage {
    public var storageEstimate : Int {
        return MemoryLayout<Self>.size + self.reduce(into: 0) { $0 += $1.storageEstimate }
    }
}

extension NSSet : DeclarativeByteStorage {
    public var storageEstimate : Int {
        return MemoryLayout<Self>.size + self.reduce(into: 0) {
            $0 += ($1 as? DeclarativeByteStorage)?.storageEstimate ?? 0
        }
    }
}

extension ConcurrentArray where Element : DeclarativeByteStorage {
    public var storageEstimate: Int {
        return MemoryLayout<Self>.size + self.reduce(into: 0) {
            $0 += $1.storageEstimate
        }
    }
}

extension DoubleLinkedList where Element : DeclarativeByteStorage {
    public var storageEstimate: Int {
        return MemoryLayout<Self>.size + self.reduce(into: 0) {
            $0 += $1.storageEstimate
        }
    }
}

extension ConcurrentOrderedSet where Element : DeclarativeByteStorage {
    public var storageEstimate: Int {
        // Multiply reduction by 3 because element (hopefully pointers) are replicated
        // in the indexes, the array, and the set
        return MemoryLayout<Self>.size + (self.reduce(into: 0, {
            $0 += $1.storageEstimate
        }) * 3)
    }
}


extension ConcurrentSet where Element : DeclarativeByteStorage {
    public var storageEstimate: Int {
        return MemoryLayout<Self>.size + self.reduce(into: 0) {
            $0 += $1.storageEstimate
        }
    }
}

extension OrderedSet where Element : DeclarativeByteStorage {
    public var storageEstimate: Int {
        // Multiply reduction by 3 because element (hopefully pointers) are replicated
        // in the indexes, the array, and the set
        return MemoryLayout<Self>.size + (self.reduce(into: 0, {
            $0 += $1.storageEstimate
        }) * 3)
    }
}

