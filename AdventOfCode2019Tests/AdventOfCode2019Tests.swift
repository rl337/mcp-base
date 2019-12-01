//
//  AdventOfCode2019Tests.swift
//  AdventOfCode2019Tests
//
//  Created by Richard Lee on 11/30/19.
//  Copyright © 2019 Richard Lee. All rights reserved.
//

import XCTest
@testable import AdventOfCode2019

class AdventOfCode2019Tests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testIntFileIterator() throws {
        let testFile = URL(fileURLWithPath: "/tmp/omg.txt")
        try "1\n2\n3\n".write(
            to:testFile,
            atomically: false,
            encoding: .utf8
        )
        var i = IntFileIterator(contentsOf: testFile)
        XCTAssertEqual(1, i.next()!, "First value should be 1")
        XCTAssertEqual(2, i.next()!, "Second value should be 2")
        XCTAssertEqual(3, i.next()!, "Third value should be 3")
        XCTAssertNil(i.next(), "Should only be 3 values")

        let j = IntFileIterator(contentsOf: testFile)
        var sum = 0
        for x in j {
            sum = sum + x
        }

        XCTAssertEqual(6, sum, "Iteratoring over thing didn't sum to 6")
    }

    func testFuelCalculator() {
        
        XCTAssertEqual(2, calculateFuel(ofMass: 12), "mass 12 should have fuel 2")
        XCTAssertEqual(2, calculateFuel(ofMass: 14), "mass 14 should have fuel 2")
        XCTAssertEqual(654, calculateFuel(ofMass: 1969), "mass 1969 should have fuel 654")
        XCTAssertEqual(33583, calculateFuel(ofMass: 100756), "mass 100756 should have fuel 33583")
    }

}
