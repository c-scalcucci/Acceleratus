//
//  File.swift
//  
//
//  Created by Chris Scalcucci on 3/21/22.
//

import XCTest
@testable import Acceleratus

fileprivate extension Array {

    init(count: Int, repeating fn: () -> Element) {
        self.init()

        for _ in 0..<count {
            self.append(fn())
        }
    }
}

final class ConcurrencyTests: XCTestCase {

    func testConcurrentHashMap() {
        let concurrentHashMap = ConcurrentHashMap<HashableObject, ConcurrentWeakHashTable>()

        let objectCount : Int = 6
        let ids : [HashableObject] = Array(count: objectCount, repeating: { return HashableObject() })
        let objs : [NSObject] = Array(count: objectCount, repeating: { return NSObject() })

        let dispatches : Int = 10_000
        let counter = AtomicInt(dispatches)
        let expectation = expectation(description: "ConcurrentHashMap Concurrent Tasks")

        for _ in 0...dispatches {
            DispatchQueue.global().async {
                // Sleep for some random duration between 50-200ms
                let randomSleep = Int.random(in: 50...200)
                usleep(useconds_t(randomSleep * 1000))

                let randomAction = Int.random(in: 0...10)
                let hashable = ids.randomElement()!
                let obj = objs.randomElement()!

                switch randomAction {
                case 0...6:
                    // Add If Absent
                    if !concurrentHashMap.containsKey(hashable) {
                        concurrentHashMap.put(ConcurrentWeakHashTable(), for: hashable)
                    }

                    (concurrentHashMap.get(hashable) ?? ConcurrentWeakHashTable()).add(obj)
                case 7...8:
                    // Remove If Present
                    concurrentHashMap[hashable]?.remove(hashable)

                    if concurrentHashMap[hashable]?.isEmpty ?? false {
                        concurrentHashMap.remove(hashable)
                    }
                default:
                    // Iterate
                    var i = 0
                    concurrentHashMap[hashable]?.forEach({ _ in i += 1 })
                    print("concurrentHashMap[\(hashable.hashValue)] iterated \(i) elements")
                }

                counter.decrementAndGet()
            }
        }

        DispatchQueue.global().async {
            while (counter.get() > 0) {
                usleep(useconds_t(200 * 1000)) // Sleep 200ms
            }
            expectation.fulfill()
        }

        // Timeout in 5 minutes
        wait(for: [expectation], timeout: 300)
    }

    func testConcurrentOrderedHashMap() {
        let concurrentOrderedHashMap = ConcurrentOrderedHashMap<HashableObject, ConcurrentWeakHashTable>()

        let objectCount : Int = 6
        let ids : [HashableObject] = Array(count: objectCount, repeating: { return HashableObject() })
        let objs : [NSObject] = Array(count: objectCount, repeating: { return NSObject() })

        let dispatches : Int = 10_000
        let counter = AtomicInt(dispatches)
        let expectation = expectation(description: "ConcurrentOrderedHashMap Concurrent Tasks")

        for _ in 0...dispatches {
            DispatchQueue.global().async {
                // Sleep for some random duration between 50-200ms
                let randomSleep = Int.random(in: 50...200)
                usleep(useconds_t(randomSleep * 1000))

                let randomAction = Int.random(in: 0...10)
                let hashable = ids.randomElement()!
                let obj = objs.randomElement()!

                switch randomAction {
                case 0...6:
                    // Add If Absent
                    if !concurrentOrderedHashMap.containsKey(hashable) {
                        concurrentOrderedHashMap.put(ConcurrentWeakHashTable(), for: hashable)
                    }
                    (concurrentOrderedHashMap.get(hashable) ?? ConcurrentWeakHashTable()).add(obj)
                case 7...8:
                    // Remove If Present
                    concurrentOrderedHashMap[hashable]?.remove(hashable)

                    if concurrentOrderedHashMap[hashable]?.isEmpty ?? false {
                        concurrentOrderedHashMap.remove(hashable)
                    }
                default:
                    // Iterate
                    var i = 0
                    concurrentOrderedHashMap[hashable]?.forEach({ _ in i += 1 })
                    print("concurrentOrderedHashMap[\(hashable.hashValue)] iterated \(i) elements")
                }

                counter.decrementAndGet()
            }
        }

        DispatchQueue.global().async {
            while (counter.get() > 0) {
                usleep(useconds_t(200 * 1000)) // Sleep 200ms
            }
            expectation.fulfill()
        }

        // Timeout in 5 minutes
        wait(for: [expectation], timeout: 300)
    }

    func testConcurrentWeakHashTable() {
        let concurrentWeakHashTable = ConcurrentWeakHashTable()

        let objectCount : Int = 6
        let ids : [HashableObject] = Array(count: objectCount, repeating: { return HashableObject() })

        let dispatches : Int = 10_000
        let counter = AtomicInt(dispatches)
        let expectation = expectation(description: "ConcurrentWeakHashTable Concurrent Tasks")

        for _ in 0...dispatches {
            DispatchQueue.global().async {
                // Sleep for some random duration between 50-200ms
                let randomSleep = Int.random(in: 50...200)
                usleep(useconds_t(randomSleep * 1000))

                let randomAction = Int.random(in: 0...10)
                let hashable = ids.randomElement()!

                switch randomAction {
                case 0...6:
                    concurrentWeakHashTable.add(hashable)
                case 7...8:
                    concurrentWeakHashTable.remove(hashable)
                default:
                    var i = 0
                    concurrentWeakHashTable.forEach({ _ in i += 1 })
                    print("concurrentWeakHashTable iterated \(i) elements")
                }

                counter.decrementAndGet()
            }
        }

        DispatchQueue.global().async {
            while (counter.get() > 0) {
                usleep(useconds_t(200 * 1000)) // Sleep 200ms
            }
            expectation.fulfill()
        }

        // Timeout in 5 minutes
        wait(for: [expectation], timeout: 300)
    }

    func testConcurrentArray() {
        let concurrentArray = ConcurrentArray<HashableObject>()

        let objectCount : Int = 6
        let ids : [HashableObject] = Array(count: objectCount, repeating: { return HashableObject() })

        let dispatches : Int = 10_000
        let counter = AtomicInt(dispatches)
        let expectation = expectation(description: "ConcurrentArray Concurrent Tasks")

        for _ in 0...dispatches {
            DispatchQueue.global().async {
                // Sleep for some random duration between 50-200ms
                let randomSleep = Int.random(in: 50...200)
                usleep(useconds_t(randomSleep * 1000))

                let randomAction = Int.random(in: 0...10)
                let hashable = ids.randomElement()!

                switch randomAction {
                case 0...6:
                    concurrentArray.append(hashable)
                case 7...8:
                    concurrentArray.remove(hashable)
                default:
                    var i = 0
                    concurrentArray.forEach({ _ in i += 1 })
                    print("concurrentArray iterated \(i) elements")
                }

                counter.decrementAndGet()
            }
        }

        DispatchQueue.global().async {
            while (counter.get() > 0) {
                usleep(useconds_t(200 * 1000)) // Sleep 200ms
            }
            expectation.fulfill()
        }

        // Timeout in 5 minutes
        wait(for: [expectation], timeout: 300)
    }

    func testConcurrentSet() {
        let concurrentSet = ConcurrentSet<HashableObject>()

        let objectCount : Int = 6
        let ids : [HashableObject] = Array(count: objectCount, repeating: { return HashableObject() })

        let dispatches : Int = 10_000
        let counter = AtomicInt(dispatches)
        let expectation = expectation(description: "ConcurrentSet Concurrent Tasks")

        for _ in 0...dispatches {
            DispatchQueue.global().async {
                // Sleep for some random duration between 50-200ms
                let randomSleep = Int.random(in: 50...200)
                usleep(useconds_t(randomSleep * 1000))

                let randomAction = Int.random(in: 0...10)
                let hashable = ids.randomElement()!

                switch randomAction {
                case 0...6:
                    concurrentSet.insert(hashable)
                case 7...8:
                    concurrentSet.remove(hashable)
                default:
                    var i = 0
                    concurrentSet.forEach({ _ in i += 1 })
                    print("concurrentSet iterated \(i) elements")
                }

                counter.decrementAndGet()
            }
        }

        DispatchQueue.global().async {
            while (counter.get() > 0) {
                usleep(useconds_t(200 * 1000)) // Sleep 200ms
            }
            expectation.fulfill()
        }

        // Timeout in 5 minutes
        wait(for: [expectation], timeout: 300)
    }

    func testConcurrentOrderedSet() {
        let concurrentOrderedSet = ConcurrentOrderedSet<HashableObject>()

        let objectCount : Int = 6
        let ids : [HashableObject] = Array(count: objectCount, repeating: { return HashableObject() })

        let dispatches : Int = 10_000
        let counter = AtomicInt(dispatches)
        let expectation = expectation(description: "ConcurrentOrderedSet Concurrent Tasks")

        for _ in 0...dispatches {
            DispatchQueue.global().async {
                // Sleep for some random duration between 50-200ms
                let randomSleep = Int.random(in: 50...200)
                usleep(useconds_t(randomSleep * 1000))

                let randomAction = Int.random(in: 0...10)
                let hashable = ids.randomElement()!

                switch randomAction {
                case 0...6:
                    concurrentOrderedSet.insert(hashable)
                case 7...8:
                    concurrentOrderedSet.remove(hashable)
                default:
                    var i = 0
                    concurrentOrderedSet.forEach({ _ in i += 1 })
                    print("concurrentOrderedSet iterated \(i) elements")
                }

                counter.decrementAndGet()
            }
        }

        DispatchQueue.global().async {
            while (counter.get() > 0) {
                usleep(useconds_t(200 * 1000)) // Sleep 200ms
            }
            expectation.fulfill()
        }

        // Timeout in 5 minutes
        wait(for: [expectation], timeout: 300)
    }

    static var allTests = [
        ("testConcurrentHashMap", testConcurrentHashMap),
        ("testConcurrentOrderedHashMap", testConcurrentOrderedHashMap),
        ("testConcurrentWeakHashTable", testConcurrentWeakHashTable),
        ("testConcurrentArray", testConcurrentArray),
        ("testConcurrentSet", testConcurrentSet),
        ("testConcurrentOrderedSet", testConcurrentOrderedSet)
    ]
}
