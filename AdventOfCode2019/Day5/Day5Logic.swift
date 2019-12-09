//
//  Day5Logic.swift
//  AdventOfCode2019
//
//  Created by Richard Lee on 12/4/19.
//  Copyright © 2019 Richard Lee. All rights reserved.
//

import Foundation

class DayFiveSolution : DayOfCodeSolution {
    
    func calculatePart1() throws -> [Int] {
        let day5InputFile = getFileFromProject(named: "Day5Input.txt")
        let i = try IntFileIterator(contentsOf: day5InputFile, delimitedBy: ",")
        let code = i.array();
        
        let machine = IntCodeMachine(withCode: code, withInput: [1])
        try machine.run()
        let output = machine.output()
        guard output.count > 0 else {
            throw DayFiveSolutionError.ExpectedOutput
        }
        
        for state in 0..<output.count-1 {
            guard output[state] == 0 else {
                return output
            }
        }
        
        return [output.last!]
    }
    
    func calculatePart2() throws -> Int {
        let day5InputFile = getFileFromProject(named: "Day5Input.txt")
        let i = try IntFileIterator(contentsOf: day5InputFile, delimitedBy: ",")
        let code = i.array();
        
        let machine = IntCodeMachine(withCode: code, withInput: [5])
        try machine.run()
        let output = machine.output()
        guard output.count == 1 else {
            throw DayFiveSolutionError.ExpectedOutput
        }
        
        return output[0]
    }
    
    public override func execute() -> [UIEntry] {
        var result: [UIEntry] = []
        result.append(UIEntry(withId: 0, thatDisplays: "Day 5 Solution"))
        
        result.append(contentsOf: getListForFunction(1, method: calculatePart1, labeledWith: "Part 1"))

        result.append(getEntryForFunction(100, method: calculatePart2, labeledWith: "Part 2"))

        return result
    }
    
    enum DayFiveSolutionError: Error {
        case ExpectedOutput, DiagnosticFailed
    }

}
