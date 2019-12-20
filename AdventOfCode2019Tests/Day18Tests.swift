//
//  Day18Tests.swift
//  AdventOfCode2019Tests
//
//  Created by Richard Lee on 12/17/19.
//  Copyright © 2019 Richard Lee. All rights reserved.
//

import Foundation
import XCTest
@testable import AdventOfCode2019

class Day18Tests: XCTestCase {
    func testShortestPathInit() throws {
        let finder = try SlimeMoldShortestPath("""
#########
#b.A.@.a#
#########
""",
           ["#", "."].asIntArray()
        )
        XCTAssertEqual(BitmapPoint(1,1), finder.items[Character("b").asInt()])
    }
    
    func testIsTraversable() throws {
        let finder = try SlimeMoldShortestPath("""
#########
#b.A.@.a#
#########
""",
           ["#", "."].asIntArray()
        )
        let start = finder.items["@".asCharacterInt()]!
        let walls = ["#"].asIntArray()

        XCTAssertEqual(false,finder.isTraversable(p: start.north, walls: walls))
        XCTAssertEqual(false,finder.isTraversable(p: start.south, walls: walls))
        XCTAssertEqual(true,finder.isTraversable(p: start.east, walls: walls))
        XCTAssertEqual(true,finder.isTraversable(p: start.west, walls: walls))
    }
    
    
    func testShortestPathExample1() throws {
        let finder = try SlimeMoldShortestPath("""
#########
#b.A.@.a#
#########
""",
           ["#", "."].asIntArray()
        )
        
        let start = finder.items["@".asCharacterInt()]!
        let stop = finder.items["a".asCharacterInt()]!

        let actual = finder.shortestPath(start, stop, walls: ["#"].asIntArray())
        XCTAssertEqual(
            [BitmapPoint(5, 1), BitmapPoint(6, 1), BitmapPoint(7, 1)],
            actual
        )
    }
    
    func testDoorForKey() throws {
        let collector = try KeyCollector(rawMap: "")
        XCTAssertEqual("A".asCharacterInt(), collector.doorForKey(key: "a".asCharacterInt()))
        XCTAssertEqual("Z".asCharacterInt(), collector.doorForKey(key: "z".asCharacterInt()))
    }
    
        func testGetAllKeysExample1() throws {
            let collector = try KeyCollector(rawMap: """
            #########
            #b.A.@.a#
            #########
            """)
            let shortest = try collector.collectAllKeys()
            
            XCTAssertEqual(
                8,
                shortest?.distance
            )
        }
    

    
        func testGetAllKeysExample2() throws {
            let collector = try KeyCollector(rawMap: """
            ########################
            #f.D.E.e.C.b.A.@.a.B.c.#
            ######################.#
            #d.....................#
            ########################
            """)
            let shortest = try collector.collectAllKeys()
            
            XCTAssertEqual(
                86,
                shortest?.distance
            )
        }
    
        func testGetAllKeysExample3() throws {
            let collector = try KeyCollector(rawMap: """
            #################
            #i.G..c...e..H.p#
            ########.########
            #j.A..b...f..D.o#
            ########@########
            #k.E..a...g..B.n#
            ########.########
            #l.F..d...h..C.m#
            #################
            """)
            let shortest = try collector.collectAllKeys()

            
            XCTAssertEqual(
                132,
                shortest?.distance
            )
        }

}
