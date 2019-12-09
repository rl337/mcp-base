//
//  Day9Tests.swift
//  AdventOfCode2019Tests
//
//  Created by Richard Lee on 12/8/19.
//  Copyright © 2019 Richard Lee. All rights reserved.
//

import Foundation
import XCTest
@testable import AdventOfCode2019

class Day9Tests: XCTestCase {

    func testIntCodeNewOpcodesPart1Example1() throws {
        let machine = IntCodeMachine(withCode: [109,1,204,-1,1001,100,1,100,1008,100,16,101,1006,101,0,99], withInput: [])
        try machine.run()
        let actual = machine.output()
        XCTAssertEqual(actual, [109,1,204,-1,1001,100,1,100,1008,100,16,101,1006,101,0,99])
    }
    
    func testIntCodeNewOpcodesPart1Example2() throws {
        let machine = IntCodeMachine(withCode: [1102,34915192,34915192,7,4,7,99,0], withInput: [])
        try machine.run()
        let actual = machine.output()
        XCTAssertEqual(actual, [34915192*34915192])
    }
    
    func testIntCodeNewOpcodesPart1Example3() throws {
        let machine = IntCodeMachine(withCode: [104,1125899906842624,99], withInput: [])
        try machine.run()
        let actual = machine.output()
        XCTAssertEqual(actual, [1125899906842624])
    }

}
