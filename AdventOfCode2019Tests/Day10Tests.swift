//
//  Day10Tests.swift
//  AdventOfCode2019Tests
//
//  Created by Richard Lee on 12/9/19.
//  Copyright © 2019 Richard Lee. All rights reserved.
//

import Foundation
import XCTest
@testable import AdventOfCode2019

class Day10Tests: XCTestCase {

    func testCoordinates() throws {
        let field = AsteroidField(data: """
.#..#
.....
#####
....#
...##
"""
        )
        
        XCTAssertEqual(field.width, 5)
        XCTAssertEqual(field.height, 5)
        
        try XCTAssertEqual(false, field.isAsteroid(x: 0, y: 0))
        try XCTAssertEqual(true, field.isAsteroid(x: 1, y: 0))
    }
    
    func testFactors() throws {
        let field = AsteroidField(data: "")
        XCTAssertEqual(field.factorize(n: 1), [1])
        XCTAssertEqual(field.factorize(n: 2), [1, 2])
        XCTAssertEqual(field.factorize(n: 3), [1, 3])
        XCTAssertEqual(field.factorize(n: 4), [1, 2, 4])
        XCTAssertEqual(field.factorize(n: 5), [1, 5])
        XCTAssertEqual(field.factorize(n: 6), [1, 2, 3, 6])
    }
    
    func testLineOfSightCountExample1() throws {
        let field = AsteroidField(data: """
            .#..#
            .....
            #####
            ....#
            ...##
            """
        )
        XCTAssertEqual(8, try field.countVisibleAsteroids(x: 3, y: 4))
        XCTAssertEqual(8, try field.findBestCountForStation())
    }
    
    func testLineOfSightCountExample2() throws {
            let field = AsteroidField(data: """
                ......#.#.
                #..#.#....
                ..#######.
                .#.#.###..
                .#..#.....
                ..#....#.#
                #..#....#.
                .##.#..###
                ##...#..#.
                .#....####
                """
            )
            XCTAssertEqual(33, try field.countVisibleAsteroids(x: 5, y: 8))
            XCTAssertEqual(33, try field.findBestCountForStation())
        }
    
    func testLineOfSightCountExample3() throws {
            let field = AsteroidField(data: """
                #.#...#.#.
                .###....#.
                .#....#...
                ##.#.#.#.#
                ....#.#.#.
                .##..###.#
                ..#...##..
                ..##....##
                ......#...
                .####.###.
                """
            )
            XCTAssertEqual(35, try field.countVisibleAsteroids(x: 1, y: 2))
            XCTAssertEqual(35, try field.findBestCountForStation())
        }
    
    func testLineOfSightCountExample4() throws {
            let field = AsteroidField(data: """
                .#..#..###
                ####.###.#
                ....###.#.
                ..###.##.#
                ##.##.#.#.
                ....###..#
                ..#.#..#.#
                #..#.#.###
                .##...##.#
                .....#.#..
                """
            )
            XCTAssertEqual(41, try field.countVisibleAsteroids(x: 6, y: 3))
            XCTAssertEqual(41, try field.findBestCountForStation())
        }
    
    func testLineOfSightCountExample5() throws {
            let field = AsteroidField(data: """
                .#..##.###...#######
                ##.############..##.
                .#.######.########.#
                .###.#######.####.#.
                #####.##.#.##.###.##
                ..#####..#.#########
                ####################
                #.####....###.#.#.##
                ##.#################
                #####.##.###..####..
                ..######..##.#######
                ####.##.####...##..#
                .#####..#.######.###
                ##...#.##########...
                #.##########.#######
                .####.#.###.###.#.##
                ....##.##.###..#####
                .#.#.###########.###
                #.#.#.#####.####.###
                ###.##.####.##.#..##
                """
            )
            XCTAssertEqual(210, try field.countVisibleAsteroids(x: 11, y: 13))
            XCTAssertEqual(210, try field.findBestCountForStation())
        }
    
    func testCalcAngle() throws {
        let field = AsteroidField(data: "")
        XCTAssertEqual(
           90,
           field.getAngleBetweenPoints(
                a: GridPoint(x: 0, y: 0),
                b: GridPoint(x: 1, y: 0)
            )
        )
        XCTAssertEqual(
           180,
           field.getAngleBetweenPoints(
                a: GridPoint(x: 0, y: 0),
                b: GridPoint(x: 0, y: 1)
            )
        )
        XCTAssertEqual(
           270,
           field.getAngleBetweenPoints(
                a: GridPoint(x: 0, y: 0),
                b: GridPoint(x: -1, y: 0)
           ),
           accuracy: 0.0001
        )
        XCTAssertEqual(
           0,
           field.getAngleBetweenPoints(
                a: GridPoint(x: 0, y: 0),
                b: GridPoint(x: 0, y: -1)
           ),
           accuracy: 0.0001
        )
    }
    
    func testZapOrder() throws {
            let map = """
                .#..##.###...#######
                ##.############..##.
                .#.######.########.#
                .###.#######.####.#.
                #####.##.#.##.###.##
                ..#####..#.#########
                ####################
                #.####....###.#.#.##
                ##.#################
                #####.##.###..####..
                ..######..##.#######
                ####.##.####...##..#
                .#####..#.######.###
                ##...#.##########...
                #.##########.#######
                .####.#.###.###.#.##
                ....##.##.###..#####
                .#.#.###########.###
                #.#.#.#####.####.###
                ###.##.####.##.#..##
                """
        let result = try DayTenSolution().compute200thZapped(map: map, origin: GridPoint(x: 11, y: 13))
        XCTAssertEqual(802, result)
    }
    
}
