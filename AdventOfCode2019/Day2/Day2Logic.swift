//
//  Day2Logic.swift
//  AdventOfCode2019
//
//  Created by Richard Lee on 12/1/19.
//  Copyright © 2019 Richard Lee. All rights reserved.
//

import Foundation

class DayTwoSolution : DayOfCodeSolution {
    
    func computeWithNounAndVerb(noun: Int, verb: Int) throws -> Int {
        let day2InputFile = getFileFromProject(named: "Day2Input.txt")
        let i = try IntFileIterator(contentsOf: day2InputFile, delimitedBy: ",")
        var code = i.array();
        code[1] = noun
        code[2] = verb
        
        let machine = IntCodeMachine(withCode: code)
        try machine.run()
        let state = machine.array()
        
        return state[0]
    }
    
    func calculatePart1() throws -> Int {
        return try computeWithNounAndVerb(noun: 12, verb: 2)
    }
    
    func calculatePart2() throws -> Int {
        for noun in 0...99 {
            for verb in 0...99 {
                let trial = try computeWithNounAndVerb(noun: noun, verb: verb)
                if trial == 19690720 {
                    return 100 * noun + verb
                }
            }
        }
        
        throw DayTwoSolutionError.Part2HadNoSolution
    }
    
    public override func heading() -> [UIEntry] {
        return [
            UIEntry(withId: 0, thatDisplays: "Day 2 Solution"),
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
    
    
    enum DayTwoSolutionError : Error {
        case Part2HadNoSolution
    }
}
