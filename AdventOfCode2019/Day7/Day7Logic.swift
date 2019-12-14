//
//  Day7Logic.swift
//  AdventOfCode2019
//
//  Created by Richard Lee on 12/6/19.
//  Copyright © 2019 Richard Lee. All rights reserved.
//

import Foundation

class DaySevenSolution : DayOfCodeSolution {
    
    func tryPhaseSettings(_ phaseSettings: [Int], withCode code: [Int]) throws -> Int {
        var input = 0
        for i in 0..<phaseSettings.count {
            let machine = IntCodeMachine(withCode: code, withInput: [phaseSettings[i], input])
            try machine.run()
            let output = machine.output()
            guard output.count == 1 else {
                throw DaySevenSolutionError.AmplifierOutputWasInvalid
            }
            input = output[0]
        }
        
        return input
    }
    
    func tryPhaseSettingsPart2(_ phaseSettings: [Int], withCode code: [Int]) throws -> Int {
        var machines: [IntCodeMachine] = []
        for i in 0..<phaseSettings.count {
            machines.append(IntCodeMachine(withCode: code))
            machines[i].addInput(value: phaseSettings[i])
        }

        machines[0].addInput(value: 0)
        while !machines.last!.isHalted() {
            for i in 0..<phaseSettings.count {
                let machine = machines[i]
                do { try machine.run() }
                catch IntCodeMachine.IntCodeMachineError.UnexpectedEndOfInput {
                }
                
                let output = machine.output()
                if output.count > 0 {
                    if i == phaseSettings.count-1 {
                        if machine.isHalted() {
                            break
                        }
                        
                        machines[0].addInput(values: output)
                    } else {
                        machines[i+1].addInput(values: output)
                    }
                    machine.clearOutput()
                }
            }
        }
        
        return machines[phaseSettings.count-1].output()[0]
    }
    
    func findMaximumThrustSetting(code: [Int]) throws -> Int {
        var highest = 0
        for a in 0...4 {
            for b in 0...4 {
                if b == a {
                    continue
                }
                for c in 0...4 {
                    if c == a || c == b {
                        continue
                    }
                    for d in 0...4 {
                        if d == a || d == b || d == c {
                            continue
                        }
                        for e in 0...4 {
                            if e == a || e == b || e == c || e == d {
                                continue
                            }
                            let thrust = try tryPhaseSettings([a, b, c, d, e], withCode: code)
                            if thrust > highest {
                                highest = thrust
                            }
                        }
                    }
                }
            }
        }
        return highest
    }
    
    func findMaximumThrustSettingPart2(code: [Int]) throws -> Int {
        var highest = 0
        for a in 5...9 {
            for b in 5...9 {
                if b == a {
                    continue
                }
                for c in 5...9 {
                    if c == a || c == b {
                        continue
                    }
                    for d in 5...9 {
                        if d == a || d == b || d == c {
                            continue
                        }
                        for e in 5...9 {
                            if e == a || e == b || e == c || e == d {
                                continue
                            }
                            let thrust = try tryPhaseSettingsPart2([a, b, c, d, e], withCode: code)
                            if thrust > highest {
                                highest = thrust
                            }
                        }
                    }
                }
            }
        }
        return highest
    }
    
    func calculatePart1() throws -> Int {
        let day7InputFile = getFileFromProject(named: "Day7Input.txt")
        let i = try IntFileIterator(contentsOf: day7InputFile, delimitedBy: ",")
        let code = i.array();
        
        return try findMaximumThrustSetting(code: code)
    }
    
    func calculatePart2() throws -> Int {
        let day7InputFile = getFileFromProject(named: "Day7Input.txt")
        let i = try IntFileIterator(contentsOf: day7InputFile, delimitedBy: ",")
        let code = i.array();
        
        return try findMaximumThrustSettingPart2(code: code)
    }
    
    public override func heading() -> [UIEntry] {
        return [
            UIEntry(withId: 0, thatDisplays: "Day 7 Solution"),
        ]
    }
    
    public override func execute() -> [UIEntry] {
        let part1Entry = getEntryForFunction(1, method: calculatePart1, labeledWith: "Part 1")
        let part2Entry = getEntryForFunction(2, method: calculatePart2, labeledWith: "Part 2")
        
        return [
            part1Entry,
            part2Entry
        ]
    }
    
    enum DaySevenSolutionError: Error {
        case AmplifierOutputWasInvalid
    }

}
