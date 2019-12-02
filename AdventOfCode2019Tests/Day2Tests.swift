//
//  Day2Tests.swift
//  AdventOfCode2019Tests
//
//  Created by Richard Lee on 12/1/19.
//  Copyright © 2019 Richard Lee. All rights reserved.
//

import Foundation


import XCTest
@testable import AdventOfCode2019

class Day2Tests: XCTestCase {
    func testIntCodeMachineExample1() throws {
        let machine = IntCodeMachine(withCode: [1,0,0,0,99])
        try machine.run()
        XCTAssertEqual([2,0,0,0,99], machine.array(), "Machine ended with bad state")
    }
    
    func testIntCodeMachineExample2() throws {
        let machine = IntCodeMachine(withCode: [2,3,0,3,99])
        try machine.run()
        XCTAssertEqual([2,3,0,6,99], machine.array(), "Machine ended with bad state")
    }
    
    func testIntCodeMachineExample3() throws {
        let machine = IntCodeMachine(withCode: [2,4,4,5,99,0])
        try machine.run()
        XCTAssertEqual([2,4,4,5,99,9801], machine.array(), "Machine ended with bad state")
    }
    
    func testIntCodeMachineExample4() throws {
        let machine = IntCodeMachine(withCode: [1,1,1,4,99,5,6,0,99])
        try machine.run()
        XCTAssertEqual([30,1,1,4,2,5,6,0,99], machine.array(), "Machine ended with bad state")
    }
}
