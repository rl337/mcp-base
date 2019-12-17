//
//  Day16Tests.swift
//  AdventOfCode2019Tests
//
//  Created by Richard Lee on 12/15/19.
//  Copyright © 2019 Richard Lee. All rights reserved.
//

import Foundation
import XCTest
@testable import AdventOfCode2019

class Day16Tests: XCTestCase {
    
    func runRepeating(_ element: Int, _ count: Int) throws -> [Int] {
        let fft = try FlawedFrequencyTransmission(rawSignal: "123")
        var result: [Int] = []
        for i in 0..<count {
            result.append(fft.getRepeatingValue(forElement: element, atOffset: i))
        }
        
        return result
    }

    func testRepeating() throws {
        XCTAssertEqual([1, 0, -1, 0, 1, 0, -1, 0], try runRepeating(0, 8))
        XCTAssertEqual([0, 1, 1, 0, 0, -1, -1, 0], try runRepeating(1, 8))
        XCTAssertEqual([0, 0, 1, 1, 1, 0, 0, 0], try runRepeating(2, 8))
        
        XCTAssertEqual([0, 0, 0, 0, 0, 0, 0, 1], try runRepeating(7, 8))

    }
    
    func testPhase() throws {
        let fft = try FlawedFrequencyTransmission(rawSignal: "12345678")
        
        XCTAssertEqual([1, 2, 3, 4, 5, 6, 7, 8], try fft.phase(phase: 0))
        XCTAssertEqual([4, 8, 2, 2, 6, 1, 5, 8], try fft.phase(phase: 1))
        XCTAssertEqual([3, 4, 0, 4, 0, 4, 3, 8], try fft.phase(phase: 2))


    }
    
    func testPhaseExample2() throws {
        let fft = try FlawedFrequencyTransmission(rawSignal: "80871224585914546619083218645595")
        
        XCTAssertEqual([2, 4, 1, 7, 6, 1, 7, 6], try fft.phase(phase: 100)[0...7])
    }
}
