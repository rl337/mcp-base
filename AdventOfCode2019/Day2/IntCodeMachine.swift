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
    private var inputArray: [Int]
    private var outputArray: [Int]
    
    init(withCode code: [Int], withInput inputs: [Int] = []) {
        self.code = code
        self.ip = 0
        self.inputArray = []
        self.outputArray = []
        
        if inputs.count > 0 {
            inputArray.append(contentsOf: inputs)
        }
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
    
    func valueAtIPOffsetWithMode(atOffset offset: Int, usingMode mode: Int = 0) throws -> Int {
        
        let idx = try indexOfIPOffset(offset: offset)
        let valueAtIdx = code[idx]
        if mode == 0 {
            
            guard valueAtIdx >= 0 && valueAtIdx < code.count else {
                throw IntCodeMachineError.LocationOutOfRange
            }
            return code[valueAtIdx]
        } else if mode == 1 {
            return valueAtIdx
        }
        
        throw IntCodeMachineError.InvalidAddressingMode
    }
    
    func storeAtIPOffsetIndex(_ value: Int, atOffset offset: Int, usingMode mode: Int = 0) throws {
        guard mode == 0 else {
            throw IntCodeMachineError.InvalidAddressingMode
        }
        
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
    
    func output() -> [Int] {
        return outputArray
    }
    
    func run() throws {
        while true {
            let opcode = try valueAtIP()
            var opcodeString = String(opcode)
            
            var a: Int = 0
            var b: Int = 0
            var c: Int = 0
            var de: Int
            if opcodeString.count < 1 {
                throw IntCodeMachineError.InvalidOpcode
            }
            
            if opcodeString.count == 5 {
                a = Int(String(opcodeString.remove(at: opcodeString.startIndex)))!
            }
            if opcodeString.count == 4 {
                b = Int(String(opcodeString.remove(at: opcodeString.startIndex)))!
            }
            if opcodeString.count == 3 {
                c = Int(String(opcodeString.remove(at: opcodeString.startIndex)))!
            }
            de = Int(opcodeString)!

            if de == 99 {
                break
            }
            
            var advance: Int
            switch de {
            case 1:
                let operand1 = try valueAtIPOffsetWithMode(atOffset: 1, usingMode: c)
                let operand2 = try valueAtIPOffsetWithMode(atOffset: 2, usingMode: b)
                let result = operand1 + operand2
                try storeAtIPOffsetIndex(result, atOffset: 3, usingMode: a)
                advance = 4
            case 2:
                let operand1 = try valueAtIPOffsetWithMode(atOffset: 1, usingMode: c)
                let operand2 = try valueAtIPOffsetWithMode(atOffset: 2, usingMode: b)
                let result = operand1 * operand2
                try storeAtIPOffsetIndex(result, atOffset: 3, usingMode: a)
                advance = 4
            case 3:
                guard self.inputArray.count > 0 else {
                    throw IntCodeMachineError.UnexpectedEndOfInput
                }
                let result = self.inputArray.remove(at: 0)
                try storeAtIPOffsetIndex(result, atOffset: 1, usingMode: c)
                advance = 2
            case 4:
                let operand1 = try valueAtIPOffsetWithMode(atOffset: 1, usingMode: c)
                self.outputArray.append(operand1)
                advance = 2
            default:
                throw IntCodeMachineError.InvalidOpcode
            }
            
            ip += advance
        }
    }
    
    enum IntCodeMachineError : Error {
        case
            InvalidOpcode,
            IPOutOfRange,
            LocationOutOfRange,
            InvalidIPOffset,
            UnexpectedEndOfInput,
            InvalidAddressingMode
    }
}
