//
//  Day24Tests.swift
//  AdventOfCode2019Tests
//
//  Created by Richard Lee on 12/23/19.
//  Copyright © 2019 Richard Lee. All rights reserved.
//

import Foundation
import XCTest
@testable import AdventOfCode2019


class Day24Tests: XCTestCase {
    
    
    func testInitAndAsString() throws {
        let grid = BugGrid(5, """
        ....#
        #..#.
        #..##
        ..#..
        #....
        """)
        XCTAssertEqual(
            """
            ....#
            #..#.
            #..##
            ..#..
            #....
            """,
            grid.asString()
        )
    }
    
    func testComputeBiodiversity() throws {
        let grid = BugGrid(5, """
        .....
        .....
        .....
        #....
        .#...
        """)
        XCTAssertEqual(
            2129920,
            grid.computeBiodiversity()
        )
    }
    
    func testStepsForExample1() throws {
        let grid = BugGrid(5, """
        ....#
        #..#.
        #..##
        ..#..
        #....
        """)
        
        grid.step()
        XCTAssertEqual(
            """
            #..#.
            ####.
            ###.#
            ##.##
            .##..
            """,
            grid.asString()
        )
        
        grid.step()
        XCTAssertEqual(
            """
            #####
            ....#
            ....#
            ...#.
            #.###
            """,
            grid.asString()
        )
        
        grid.step()
        XCTAssertEqual(
            """
            #....
            ####.
            ...##
            #.##.
            .##.#
            """,
            grid.asString()
        )

        grid.step()
        XCTAssertEqual(
            """
            ####.
            ....#
            ##..#
            .....
            ##...
            """,
            grid.asString()
        )
    }

}
