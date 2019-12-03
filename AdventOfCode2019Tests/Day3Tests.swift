//
//  Day3Tests.swift
//  AdventOfCode2019Tests
//
//  Created by Richard Lee on 12/2/19.
//  Copyright © 2019 Richard Lee. All rights reserved.
//

import Foundation
import XCTest
@testable import AdventOfCode2019

class Day3Tests: XCTestCase {
    func testGridMove() throws {
        let grid = CursorGrid()
        let intersections = try grid.move(command: "R2", value: 1)
        XCTAssertEqual(0, intersections.count)
        XCTAssertEqual(3, grid.data.count)
        XCTAssertEqual(grid.get(point: Origin), 1)
        XCTAssertEqual(grid.get(point: GridPoint(x: 1, y: 0)), 1)
        XCTAssertEqual(grid.get(point: GridPoint(x: 2, y: 0)), 1)

        let intersections2 = try grid.move(command: "U2", value: 1)
        XCTAssertEqual(0, intersections2.count)
        XCTAssertEqual(grid.get(point: GridPoint(x: 2, y: 0)), 1)
        XCTAssertEqual(grid.get(point: GridPoint(x: 2, y: 1)), 1)
        XCTAssertEqual(grid.get(point: GridPoint(x: 2, y: 2)), 1)

        let intersections3 = try grid.move(command: "L2", value: 1)
        XCTAssertEqual(0, intersections3.count)
        XCTAssertEqual(grid.get(point: GridPoint(x: 2, y: 2)), 1)
        XCTAssertEqual(grid.get(point: GridPoint(x: 1, y: 2)), 1)
        XCTAssertEqual(grid.get(point: GridPoint(x: 0, y: 2)), 1)
        
        let intersections4 = try grid.move(command: "D2", value: 1)
        XCTAssertEqual(0, intersections4.count)
        XCTAssertEqual(grid.get(point: GridPoint(x: 0, y: 2)), 1)
        XCTAssertEqual(grid.get(point: GridPoint(x: 0, y: 1)), 1)
        XCTAssertEqual(grid.get(point: GridPoint(x: 0, y: 0)), 1)

    }
    
    func testGridExample1() throws {
        let grid = CursorGrid()
        let closestIntersection1 = try grid.follow(commands: ["R8","U5","L5","D3"], value: 1)
        XCTAssertNil(closestIntersection1)
        let closestIntersection2 = try grid.follow(commands: ["U7","R6","D4","L4"], value: 2)
        XCTAssertNotNil(closestIntersection2)
        XCTAssertEqual(6, calcManhattanDistance(a: Origin, b: closestIntersection2!))
    }
    
    func testGridExample2() throws {
        let grid = CursorGrid()
        let closestIntersection1 = try grid.follow(commands: ["R75","D30","R83","U83","L12","D49","R71","U7","L72"], value: 1)
        XCTAssertNil(closestIntersection1)
        let closestIntersection2 = try grid.follow(commands: ["U62","R66","U55","R34","D71","R55","D58","R83"], value: 2)
        XCTAssertNotNil(closestIntersection2)
        XCTAssertEqual(159, calcManhattanDistance(a: Origin, b: closestIntersection2!))
    }
    
    func testGridExample3() throws {
        let grid = CursorGrid()
        let closestIntersection1 = try grid.follow(commands: ["R98","U47","R26","D63","R33","U87","L62","D20","R33","U53","R51"], value: 1)
        XCTAssertNil(closestIntersection1)
        let closestIntersection2 = try grid.follow(commands: ["U98","R91","D20","R16","D67","R40","U7","R15","U6","R7"], value: 2)
        XCTAssertNotNil(closestIntersection2)
        XCTAssertEqual(135, calcManhattanDistance(a: Origin, b: closestIntersection2!))
    }
        
    
    func testPart2Example1() throws {
        let commands1 = ["R8","U5","L5","D3"]
        let commands2 = ["U7","R6","D4","L4"]
        let dts = DayThreeSolution()
        let result = try dts.calculateShortestStepsFor(commands1: commands1, commands2: commands2)
        XCTAssertEqual(30, result)
    }


}
