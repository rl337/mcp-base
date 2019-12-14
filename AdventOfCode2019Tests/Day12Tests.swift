//
//  Day12Tests.swift
//  AdventOfCode2019Tests
//
//  Created by Richard Lee on 12/11/19.
//  Copyright © 2019 Richard Lee. All rights reserved.
//

import Foundation
import XCTest
@testable import AdventOfCode2019

class Day12Tests: XCTestCase {

    func testParsePoint3D() throws {
        XCTAssertEqual(Point3D(-1, 0, 2), try Point3D.parse(str: "<x=-1, y=0, z=2>"))
        XCTAssertEqual(Point3D(2, -10, -7), try Point3D.parse(str: "<x=2, y=-10, z=-7>"))
        XCTAssertEqual(Point3D(4, -8, 8), try Point3D.parse(str: "<x=4, y=-8, z=8>"))
        XCTAssertEqual(Point3D(-3, 5, -1), try Point3D.parse(str: "<x=-3, y=5, z=-1>"))
    }
    
    func testGravitySystemVelocities() throws {
        let gravity = GravitySystem(data: [
            Point3D(-1, 0, 2),
            Point3D(2, -10, -7),
            Point3D(4, -8, 8),
            Point3D(3, 5, -1)
        ])
        
        let expected: [Point3D] = [
            Point3D(3, -1, -1),
            Point3D(1, 3, 3),
            Point3D(-3, 1, -3),
            Point3D(-1, -3, 1)
        ]
        
        XCTAssertEqual(expected, try gravity.spotVelocities())

        let expected2: [Point3D] = [
            Point3D(2, -1, 1),
            Point3D(3, -7, -4),
            Point3D(1, -7, 5),
            Point3D(2, 2, 0)
        ]
        XCTAssertEqual(expected2, try gravity.step(1))
    }
    
    func testGravityAtSteps() throws {
        let gravity = GravitySystem(data: [
            Point3D(-1, 0, 2),
            Point3D(2, -10, -7),
            Point3D(4, -8, 8),
            Point3D(3, 5, -1)
        ])
        
        let expected: [[Point3D]] = [
            [
                try Point3D.parse(str: "<x= 2, y=-1, z= 1>"),
                try Point3D.parse(str: "<x= 3, y=-7, z=-4>"),
                try Point3D.parse(str: "<x= 1, y=-7, z= 5>"),
                try Point3D.parse(str: "<x= 2, y= 2, z= 0>"),
            ],
            [
                try Point3D.parse(str: "<x= 5, y=-3, z=-1>"),
                try Point3D.parse(str: "<x= 1, y=-2, z= 2>"),
                try Point3D.parse(str: "<x= 1, y=-4, z=-1>"),
                try Point3D.parse(str: "<x= 1, y=-4, z= 2>"),
            ],
            [
                try Point3D.parse(str: "<x= 5, y=-6, z=-1>"),
                try Point3D.parse(str: "<x= 0, y= 0, z= 6>"),
                try Point3D.parse(str: "<x= 2, y= 1, z=-5>"),
                try Point3D.parse(str: "<x= 1, y=-8, z= 2>"),
            ],
        ]
        
        for step in 0..<expected.count {
            XCTAssertEqual(expected[step], try gravity.step(1), "Step \(step+1) Failed")
        }
    }
    
    func testGravityEnergy() throws {
        let gravity = GravitySystem(data: [
            Point3D(-1, 0, 2),
            Point3D(2, -10, -7),
            Point3D(4, -8, 8),
            Point3D(3, 5, -1)
        ])
        
        _ = try gravity.step(10)
        XCTAssertEqual(179, gravity.totalEnergy())
    }
    
    func testByteRadix() throws {
        let radix = ByteRadix()
        
        radix.set(value: "omg".hashValue)
        radix.set(value: "haha".hashValue)
        radix.set(value: "foo".hashValue)
        radix.set(value: "bar".hashValue)

        XCTAssertEqual(true, radix.isSet(value: "omg".hashValue))
        XCTAssertEqual(true, radix.isSet(value: "haha".hashValue))
        XCTAssertEqual(true, radix.isSet(value: "foo".hashValue))
        XCTAssertEqual(true, radix.isSet(value: "bar".hashValue))
    }
    
    func testStepsToRepeat() throws {
        let gravity = GravitySystem(data: [
            Point3D(-1, 0, 2),
            Point3D(2, -10, -7),
            Point3D(4, -8, 8),
            Point3D(3, 5, -1)
        ])
        
        XCTAssertEqual(2772, try GravitySystem.stepsToRepeat(gravity: gravity))
    }

    
}
