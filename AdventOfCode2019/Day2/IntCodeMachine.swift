//
//  IntCodeMachine.swift
//  AdventOfCode2019
//
//  Created by Richard Lee on 12/1/19.
//  Copyright © 2019 Richard Lee. All rights reserved.
//

import Foundation

class VirtualArray {
    private var real: [Int]
    private var virtual: [Int:Int]
    
    init(_ initial: [Int] = []) {
        self.real = initial
        self.virtual = [:]
    }
    
    func get(_ index: Int) throws -> Int {
        guard index >= 0 else {
            throw VirtualArrayError.InvalidNegativeIndex
        }
        
        if index < real.count {
            return real[index]
        }
        
        return virtual[index] ?? 0
    }
    
    func set(_ index: Int, value: Int) throws {
        guard index >= 0 else {
            throw VirtualArrayError.InvalidNegativeIndex
        }
        
        if index < real.count {
            real[index] = value
        }
        
        virtual[index] = value
    }
    
    enum VirtualArrayError: Error {
        case InvalidNegativeIndex
    }
    
    func asArray() -> [Int] {
        return real
    }
    
    func clone() -> VirtualArray {
        let result = VirtualArray()
        result.real = self.real
        result.virtual = self.virtual
        return result
    }
}

struct DecodedOpCode {
    var paramAMode: Int
    var paramBMode: Int
    var paramCMode: Int
    var operation: Int
    
    init(_ opcode: Int) throws {
        var opcodeString = String(opcode)
        
        if opcodeString.count < 1 {
            throw DecodedOpCodeError.InvalidOpcode
        }
        
        paramAMode = 0
        if opcodeString.count == 5 {
            paramAMode = Int(String(opcodeString.remove(at: opcodeString.startIndex)))!
        }
        
        paramBMode = 0
        if opcodeString.count == 4 {
            paramBMode = Int(String(opcodeString.remove(at: opcodeString.startIndex)))!
        }
        
        paramCMode = 0
        if opcodeString.count == 3 {
            paramCMode = Int(String(opcodeString.remove(at: opcodeString.startIndex)))!
        }
        operation = Int(opcodeString)!
    }
    
    enum DecodedOpCodeError: Error {
        case InvalidOpcode
    }
}

class IntCodeMachine {
    private var code: VirtualArray
    private var ip: Int
    private var relativeBase: Int
    private var inputArray: [Int]
    private var outputArray: [Int]
    private var halted: Bool
    private var beyondMemory: [Int:Int]

    init(withCode code: [Int], withInput inputs: [Int] = []) {
        self.code = VirtualArray(code)
        self.ip = 0
        self.relativeBase = 0
        self.inputArray = []
        self.outputArray = []
        self.halted = false
        self.beyondMemory = [:]
        
        if inputs.count > 0 {
            inputArray.append(contentsOf: inputs)
        }
    }
    
    func clone() -> IntCodeMachine {
        let result = IntCodeMachine(withCode: [])
        result.code = self.code.clone()
        result.ip = self.ip
        result.relativeBase = self.relativeBase
        result.inputArray = self.inputArray
        result.outputArray = self.outputArray
        result.halted = self.halted
        result.beyondMemory = self.beyondMemory
        return result
    }
    
    func valueAtIPOffsetWithMode(atOffset offset: Int, usingMode mode: Int = 0) throws -> Int {
        guard ip >= 0 else {
            throw IntCodeMachineError.IPOutOfRange
        }
        
        let idx = ip + offset
        let valueAtIdx = try code.get(idx)
        switch mode {
        case 0:
            return try code.get(valueAtIdx)
        case 1:
            return valueAtIdx
        case 2:
            return try code.get(valueAtIdx + relativeBase)
        default:
            throw IntCodeMachineError.InvalidAddressingMode
        }
    }
    
    func storeAtIPOffsetIndex(_ value: Int, atOffset offset: Int, usingMode mode: Int = 0) throws {
        guard ip >= 0 else {
            throw IntCodeMachineError.IPOutOfRange
        }

        let idx = ip + offset
        switch mode {
        case 0:
            try code.set(code.get(idx), value: value)
        case 2:
            try code.set(code.get(idx) + relativeBase, value: value)
        default:
            throw IntCodeMachineError.InvalidAddressingMode
        }
    }
    
    func array() -> [Int] {
        return code.asArray()
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
            let rawOpcode = try code.get(ip)
            let opcode = try DecodedOpCode(rawOpcode)

            if opcode.operation == 99 {
                halted = true
                break
            }
            
            switch opcode.operation {
            case 1:
                let operand1 = try valueAtIPOffsetWithMode(atOffset: 1, usingMode: opcode.paramCMode)
                let operand2 = try valueAtIPOffsetWithMode(atOffset: 2, usingMode: opcode.paramBMode)
                let result = operand1 + operand2
                try storeAtIPOffsetIndex(result, atOffset: 3, usingMode: opcode.paramAMode)
                ip += 4
            case 2:
                let operand1 = try valueAtIPOffsetWithMode(atOffset: 1, usingMode: opcode.paramCMode)
                let operand2 = try valueAtIPOffsetWithMode(atOffset: 2, usingMode: opcode.paramBMode)
                let result = operand1 * operand2
                try storeAtIPOffsetIndex(result, atOffset: 3, usingMode: opcode.paramAMode)
                ip += 4
            case 3:
                guard self.inputArray.count > 0 else {
                    throw IntCodeMachineError.UnexpectedEndOfInput
                }
                let result = self.inputArray.remove(at: 0)
                try storeAtIPOffsetIndex(result, atOffset: 1, usingMode: opcode.paramCMode)
                ip += 2
            case 4:
                let operand1 = try valueAtIPOffsetWithMode(atOffset: 1, usingMode: opcode.paramCMode)
                self.outputArray.append(operand1)
                ip += 2
            case 5:
                let operand1 = try valueAtIPOffsetWithMode(atOffset: 1, usingMode: opcode.paramCMode)
                let operand2 = try valueAtIPOffsetWithMode(atOffset: 2, usingMode: opcode.paramBMode)
                if operand1 != 0 {
                    ip = operand2
                } else {
                    ip += 3
                }
            case 6:
                let operand1 = try valueAtIPOffsetWithMode(atOffset: 1, usingMode: opcode.paramCMode)
                let operand2 = try valueAtIPOffsetWithMode(atOffset: 2, usingMode: opcode.paramBMode)
                if operand1 == 0 {
                    ip = operand2
                } else {
                    ip += 3
                }
            case 7:
                let operand1 = try valueAtIPOffsetWithMode(atOffset: 1, usingMode: opcode.paramCMode)
                let operand2 = try valueAtIPOffsetWithMode(atOffset: 2, usingMode: opcode.paramBMode)
                var result = 0
                if operand1 < operand2 {
                    result = 1
                }
                try storeAtIPOffsetIndex(result, atOffset: 3, usingMode: opcode.paramAMode)
                ip += 4
            case 8:
                let operand1 = try valueAtIPOffsetWithMode(atOffset: 1, usingMode: opcode.paramCMode)
                let operand2 = try valueAtIPOffsetWithMode(atOffset: 2, usingMode: opcode.paramBMode)
                var result = 0
                if operand1 == operand2 {
                    result = 1
                }
                try storeAtIPOffsetIndex(result, atOffset: 3, usingMode: opcode.paramAMode)
                ip += 4
            case 9:
                let operand1 = try valueAtIPOffsetWithMode(atOffset: 1, usingMode: opcode.paramCMode)
                self.relativeBase += operand1
                ip += 2
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
