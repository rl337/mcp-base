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
    private var halted: Bool
    
    init(withCode code: [Int], withInput inputs: [Int] = []) {
        self.code = code
        self.ip = 0
        self.inputArray = []
        self.outputArray = []
        self.halted = false
        
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
    
    func clearOutput() {
        outputArray.removeAll()
    }
    
    func addInput(value: Int) {
        self.inputArray.append(value)
    }
    
    func addInput(values: [Int]) {
        self.inputArray.append(contentsOf: values)
    }
    
    func isHalted() -> Bool {
        return halted
    }
    
    func run() throws {
        
        if halted {
            throw IntCodeMachineError.CallToRunOnHaltedMachine
        }
        
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
                halted = true
                break
            }
            
            switch de {
            case 1:
                let operand1 = try valueAtIPOffsetWithMode(atOffset: 1, usingMode: c)
                let operand2 = try valueAtIPOffsetWithMode(atOffset: 2, usingMode: b)
                let result = operand1 + operand2
                try storeAtIPOffsetIndex(result, atOffset: 3, usingMode: a)
                ip += 4
            case 2:
                let operand1 = try valueAtIPOffsetWithMode(atOffset: 1, usingMode: c)
                let operand2 = try valueAtIPOffsetWithMode(atOffset: 2, usingMode: b)
                let result = operand1 * operand2
                try storeAtIPOffsetIndex(result, atOffset: 3, usingMode: a)
                ip += 4
            case 3:
                guard self.inputArray.count > 0 else {
                    throw IntCodeMachineError.UnexpectedEndOfInput
                }
                let result = self.inputArray.remove(at: 0)
                try storeAtIPOffsetIndex(result, atOffset: 1, usingMode: c)
                ip += 2
            case 4:
                let operand1 = try valueAtIPOffsetWithMode(atOffset: 1, usingMode: c)
                self.outputArray.append(operand1)
                ip += 2
            case 5:
                let operand1 = try valueAtIPOffsetWithMode(atOffset: 1, usingMode: c)
                let operand2 = try valueAtIPOffsetWithMode(atOffset: 2, usingMode: b)
                if operand1 != 0 {
                    ip = operand2
                } else {
                    ip += 3
                }
            case 6:
                let operand1 = try valueAtIPOffsetWithMode(atOffset: 1, usingMode: c)
                let operand2 = try valueAtIPOffsetWithMode(atOffset: 2, usingMode: b)
                if operand1 == 0 {
                    ip = operand2
                } else {
                    ip += 3
                }
            case 7:
                let operand1 = try valueAtIPOffsetWithMode(atOffset: 1, usingMode: c)
                let operand2 = try valueAtIPOffsetWithMode(atOffset: 2, usingMode: b)
                var result = 0
                if operand1 < operand2 {
                    result = 1
                }
                try storeAtIPOffsetIndex(result, atOffset: 3, usingMode: a)
                ip += 4
            case 8:
                let operand1 = try valueAtIPOffsetWithMode(atOffset: 1, usingMode: c)
                let operand2 = try valueAtIPOffsetWithMode(atOffset: 2, usingMode: b)
                var result = 0
                if operand1 == operand2 {
                    result = 1
                }
                try storeAtIPOffsetIndex(result, atOffset: 3, usingMode: a)
                ip += 4
            default:
                throw IntCodeMachineError.InvalidOpcode
            }
        }
    }
    
    enum IntCodeMachineError : Error {
        case
            InvalidOpcode,
            IPOutOfRange,
            LocationOutOfRange,
            InvalidIPOffset,
            UnexpectedEndOfInput,
            InvalidAddressingMode,
            CallToRunOnHaltedMachine
    }
}
