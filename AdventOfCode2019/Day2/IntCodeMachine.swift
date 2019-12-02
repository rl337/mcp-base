//
//  IntCodeMachine.swift
//  AdventOfCode2019
//
//  Created by Richard Lee on 12/1/19.
//  Copyright © 2019 Richard Lee. All rights reserved.
//

import Foundation

class IntCodeMachine {
    private var code: [Int]
    private var ip: Int
    
    init(withCode code: [Int]) {
        self.code = code
        self.ip = 0
    }
    
    func indexOfIPOffset(offset: Int) throws -> Int {
        guard offset >= 0 else {
            throw IntCodeMachineError.InvalidIPOffset
        }
        
        guard ip >= 0 && ip < code.count else {
            throw IntCodeMachineError.IPOutOfRange
        }
        
        let idx = ip + offset
        guard idx < code.count else {
            throw IntCodeMachineError.LocationOutOfRange
        }
        
        return idx
    }
    
    func valueAtIPOffsetIndex(atOffset offset: Int) throws -> Int {
        let idx = try indexOfIPOffset(offset: offset)
        let loc = code[idx]
        guard loc >= 0 && loc < code.count else {
            throw IntCodeMachineError.LocationOutOfRange
        }
        return code[loc]
    }
    
    func storeAtIPOffsetIndex(_ value: Int, atOffset offset: Int) throws {
        let idx = try indexOfIPOffset(offset: offset)
        let loc = code[idx]
        guard loc >= 0 && loc < code.count else {
            throw IntCodeMachineError.LocationOutOfRange
        }
        code[loc] = value
    }
    
    func valueAtIP() throws -> Int {
        guard ip >= 0 && ip < code.count else {
            throw IntCodeMachineError.IPOutOfRange
        }
        return code[ip]
    }
    
    func array() -> [Int] {
        return code
    }
    
    func run() throws {
        while true {
            let opcode = try valueAtIP()
            if opcode == 99 {
                break
            }
            
            let operand1 = try valueAtIPOffsetIndex(atOffset: 1)
            let operand2 = try valueAtIPOffsetIndex(atOffset: 2)
            var result: Int
            switch opcode {
            case 1:
                result = operand1 + operand2
            case 2:
                result = operand1 * operand2
            default:
                throw IntCodeMachineError.InvalidOpcode
            }
            try storeAtIPOffsetIndex(result, atOffset: 3)
            ip += 4
        }
    }
    
    enum IntCodeMachineError : Error {
        case
            InvalidOpcode,
            IPOutOfRange,
            LocationOutOfRange,
            InvalidIPOffset
    }
}
