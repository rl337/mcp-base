//
//  Day6Tests.swift
//  AdventOfCode2019Tests
//
//  Created by Richard Lee on 12/5/19.
//  Copyright © 2019 Richard Lee. All rights reserved.
//

import Foundation
import XCTest
@testable import AdventOfCode2019

class Day6Tests: XCTestCase {

    
    func testOrbitalMap() throws {
        let input = """
COM)B
B)C
C)D
D)E
E)F
B)G
G)H
D)I
E)J
J)K
K)L
"""
        let map = try OrbitalMap(input)
        XCTAssertEqual(42, map.com.sumOfDepths())
    }
    
        func testOrbitalTransfers() throws {
            let input = """
    COM)B
    B)C
    C)D
    D)E
    E)F
    B)G
    G)H
    D)I
    E)J
    J)K
    K)L
    K)YOU
    I)SAN
    """
            let map = try OrbitalMap(input)
            XCTAssertEqual(4, try map.com.findMinimumOrbitalTransfers(a: "YOU", b: "SAN"))
        }
}
