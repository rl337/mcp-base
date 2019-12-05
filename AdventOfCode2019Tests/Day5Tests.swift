//
//  Day5Tests.swift
//  AdventOfCode2019Tests
//
//  Created by Richard Lee on 12/4/19.
//  Copyright © 2019 Richard Lee. All rights reserved.
//

import Foundation
import XCTest
@testable import AdventOfCode2019

class Day5Tests: XCTestCase {
    
    func testIntCodeMachineWithModes() throws {
        let machine = IntCodeMachine(withCode: [1002,4,3,4,33])
        try machine.run()
        XCTAssertEqual([1002,4,3,4,99], machine.array(), "Machine ended with bad state")
    }
    
    func testIntCodeMachineIO() throws {
        let machine = IntCodeMachine(withCode: [3,5,4,5,99,99], withInput: [-5])
        try machine.run()
        XCTAssertEqual([3,5,4,5,99,-5], machine.array(), "Machine ended with bad state")
        XCTAssertEqual(1, machine.output().count)
        XCTAssertEqual(-5, machine.output()[0])
    }
    
    func testIntCodeMachineConditionalsExample1Negative() throws {
        let machine = IntCodeMachine(withCode: [3,9,8,9,10,9,4,9,99,-1,8], withInput: [-5])
        try machine.run()
        XCTAssertEqual(1, machine.output().count)
        XCTAssertEqual(0, machine.output()[0])
    }
    
    func testIntCodeMachineConditionalsExample1Positive() throws {
        let machine = IntCodeMachine(withCode: [3,9,8,9,10,9,4,9,99,-1,8], withInput: [8])
        try machine.run()
        XCTAssertEqual(1, machine.output().count)
        XCTAssertEqual(1, machine.output()[0])
    }
    
    func testIntCodeMachineConditionalsExample2Negative() throws {
        let machine = IntCodeMachine(withCode: [3,9,7,9,10,9,4,9,99,-1,8], withInput: [8])
        try machine.run()
        XCTAssertEqual(1, machine.output().count)
        XCTAssertEqual(0, machine.output()[0])
    }
    
    func testIntCodeMachineConditionalsExample2Positive() throws {
        let machine = IntCodeMachine(withCode: [3,9,7,9,10,9,4,9,99,-1,8], withInput: [7])
        try machine.run()
        XCTAssertEqual(1, machine.output().count)
        XCTAssertEqual(1, machine.output()[0])
    }
    
    func testIntCodeMachineConditionalsExample3Negative() throws {
        let machine = IntCodeMachine(withCode: [3,3,1108,-1,8,3,4,3,99], withInput: [9])
        try machine.run()
        XCTAssertEqual(1, machine.output().count)
        XCTAssertEqual(0, machine.output()[0])
    }

    func testIntCodeMachineConditionalsExample3Positive() throws {
        let machine = IntCodeMachine(withCode: [3,3,1108,-1,8,3,4,3,99], withInput: [8])
        try machine.run()
        XCTAssertEqual(1, machine.output().count)
        XCTAssertEqual(1, machine.output()[0])
    }
    
    
    func testIntCodeMachineConditionalsExample4Positive() throws {
        let machine = IntCodeMachine(withCode: [3,3,1107,-1,8,3,4,3,99], withInput: [7])
        try machine.run()
        XCTAssertEqual(1, machine.output().count)
        XCTAssertEqual(1, machine.output()[0])
    }
    
    func testIntCodeMachineConditionalsExample4Negative() throws {
        let machine = IntCodeMachine(withCode: [3,3,1107,-1,8,3,4,3,99], withInput: [8])
        try machine.run()
        XCTAssertEqual(1, machine.output().count)
        XCTAssertEqual(0, machine.output()[0])
    }
    
    func testIntCodeMachineBranchingExample1Positive() throws {
        let machine = IntCodeMachine(withCode: [3,12,6,12,15,1,13,14,13,4,13,99,-1,0,1,9], withInput: [4])
        try machine.run()
        XCTAssertEqual(1, machine.output().count)
        XCTAssertEqual(1, machine.output()[0])
    }
    
    func testIntCodeMachineBranchingExample1Negative() throws {
        let machine = IntCodeMachine(withCode: [3,12,6,12,15,1,13,14,13,4,13,99,-1,0,1,9], withInput: [0])
        try machine.run()
        XCTAssertEqual(1, machine.output().count)
        XCTAssertEqual(0, machine.output()[0])
    }
    
    func testIntCodeMachineBranchingExample2Positive() throws {
        let machine = IntCodeMachine(withCode: [3,3,1105,-1,9,1101,0,0,12,4,12,99,1], withInput: [5])
        try machine.run()
        XCTAssertEqual(1, machine.output().count)
        XCTAssertEqual(1, machine.output()[0])
    }
    
    func testIntCodeMachineBranchingExample2Negative() throws {
        let machine = IntCodeMachine(withCode: [3,3,1105,-1,9,1101,0,0,12,4,12,99,1], withInput: [0])
        try machine.run()
        XCTAssertEqual(1, machine.output().count)
        XCTAssertEqual(0, machine.output()[0])
    }
}
