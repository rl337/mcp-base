//
//  BinaryHeapTests.swift
//  AdventOfCode2019Tests
//
//  Created by Richard Lee on 1/12/20.
//  Copyright © 2020 Richard Lee. All rights reserved.
//

import Foundation

import XCTest
@testable import AdventOfCode2019

class BinaryHeapTests: XCTestCase {
    
    func testSimpleMaxScenario() throws {
        let heap: BinaryHeap<Int> = BinaryHeap<Int>() { $0 <= $1 }
        
        try heap.enqueue(5)
        try heap.enqueue(2)
        try heap.enqueue(7)
        try heap.enqueue(1)

        XCTAssertEqual(7, try heap.dequeue())
        XCTAssertEqual(5, try heap.dequeue())
        XCTAssertEqual(2, try heap.dequeue())
        XCTAssertEqual(1, try heap.dequeue())
    }
    
    func testResizedMaxScenario() throws {
        let heap: BinaryHeap<Int> = BinaryHeap<Int>(withReserveCapacity: 1) { $0 <= $1 }

        try heap.enqueue(5)
        try heap.enqueue(2)
        try heap.enqueue(7)
        try heap.enqueue(1)

        XCTAssertEqual(7, try heap.dequeue())
        XCTAssertEqual(5, try heap.dequeue())
        XCTAssertEqual(2, try heap.dequeue())
        XCTAssertEqual(1, try heap.dequeue())
    }
    
    func testFailPopFromEmptyHeap() throws {
        let heap: BinaryHeap<Int> = BinaryHeap<Int>() { $0 <= $1 }

        do {
            _ = try heap.dequeue()
            XCTFail()
        } catch BinaryHeap<Int>.BinaryHeapError.DequeueOfEmptyHeap {
            
        }
    }

}
