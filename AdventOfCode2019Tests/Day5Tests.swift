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
}
