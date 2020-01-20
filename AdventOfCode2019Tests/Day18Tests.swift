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
        let finder = try KeyMap("""
#########
#b.A.@.a#
#########
""",
           ["#", "."].asIntArray()
        )
        XCTAssertEqual(BitmapPoint(1,1), finder.items[Character("b").asInt()])
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
            shortest.distance
        )
    }
    
    func testGetItemDistanceMapExample1() throws {
        let map = try KeyMap("""
        #########
        #b.A.@.a#
        #########
        """)
        let distances = map.getItemDistanceMap()
        let path = distances[ItemPair(a: "a".asCharacterInt(), b: "b".asCharacterInt())]!
        XCTAssertEqual(6, path.path.count)
        
        XCTAssertEqual(BitmapPoint(7, 1), path.path[0])
        XCTAssertEqual(BitmapPoint(6, 1), path.path[1])
        XCTAssertEqual(BitmapPoint(5, 1), path.path[2])
        XCTAssertEqual(BitmapPoint(4, 1), path.path[3])
        XCTAssertEqual(BitmapPoint(3, 1), path.path[4])
        XCTAssertEqual(BitmapPoint(2, 1), path.path[5])
    }
    
    func testGetItemDistanceMapExample2() throws {
        let map = try KeyMap("""
              ########################
              #f.D.E.e.C.b.A.@.a.B.c.#
              ######################.#
              #d.....................#
              ########################
              """)
        let distances = map.getItemDistanceMap()
        
        XCTAssertEqual(
            6,
            distances[ItemPair(a: "a".asCharacterInt(), b: "b".asCharacterInt())]?.path.count
        )
        XCTAssertEqual(
            20,
            distances[ItemPair(a: "c".asCharacterInt(), b: "f".asCharacterInt())]?.path.count
        )
        XCTAssertEqual(
            6,
            distances[ItemPair(a: "e".asCharacterInt(), b: "f".asCharacterInt())]?.path.count
        )
    }
    
    func testGetItemDistanceMapExample3() throws {
        let map = try KeyMap("""
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
        let distances = map.getItemDistanceMap()
        
        XCTAssertEqual(
            6,
            distances[ItemPair(a: "a".asCharacterInt(), b: "b".asCharacterInt())]?.path.count
        )
        XCTAssertEqual(
            20,
            distances[ItemPair(a: "l".asCharacterInt(), b: "p".asCharacterInt())]?.path.count
        )
        XCTAssertEqual(
            16,
            distances[ItemPair(a: "o".asCharacterInt(), b: "p".asCharacterInt())]?.path.count
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
                shortest.distance
            )
        }
    
    
    func testGetAllKeysExample3() throws {
        let collector = try KeyCollector(rawMap: """
        ########################
        #...............b.C.D.f#
        #.######################
        #.....@.a.B.c.d.A.e.F.g#
        ########################
        """)
        let shortest = try collector.collectAllKeys()

        XCTAssertEqual(
            132,
            shortest.distance
        )
    }
    
        func testGetAllKeysExample4() throws {
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
                136,
                shortest.distance
            )
        }
    
    func testGetAllKeysExample5() throws {
        let collector = try KeyCollector(rawMap: """
        ########################
        #@..............ac.GI.b#
        ###d#e#f################
        ###A#B#C################
        ###g#h#i################
        ########################
        """)
        let shortest = try collector.collectAllKeys()

        XCTAssertEqual(
            81,
            shortest.distance
        )
    }

}
