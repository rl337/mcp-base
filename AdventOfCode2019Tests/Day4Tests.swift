//
//  Day4Tests.swift
//  AdventOfCode2019Tests
//
//  Created by Richard Lee on 12/3/19.
//  Copyright © 2019 Richard Lee. All rights reserved.
//

import Foundation
import XCTest
@testable import AdventOfCode2019

class Day4Tests: XCTestCase {
    
    func testValidationPart1Examples() {
        XCTAssertEqual(true, DayFourSolution.validateNumberPart1(n: 111111))
        XCTAssertEqual(false, DayFourSolution.validateNumberPart1(n: 223450))
        XCTAssertEqual(false, DayFourSolution.validateNumberPart1(n: 123789))
    }
    
    func testValidationPart2Examples() {
        XCTAssertEqual(true, DayFourSolution.validateNumberPart2(n: 112233, enforceRange: false))
        XCTAssertEqual(false, DayFourSolution.validateNumberPart2(n: 123444, enforceRange: false))
        XCTAssertEqual(true, DayFourSolution.validateNumberPart2(n: 111122, enforceRange: false))
    }
}
