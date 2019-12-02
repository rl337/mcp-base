//
//  Day2Logic.swift
//  AdventOfCode2019
//
//  Created by Richard Lee on 12/1/19.
//  Copyright © 2019 Richard Lee. All rights reserved.
//

import Foundation

class DayTwoSolution : DayOfCodeSolution {
    
    func calculatePart1() throws -> Int {
        let day2InputFile = getFileFromProject(named: "Day2Input.txt")
        let i = try IntFileIterator(contentsOf: day2InputFile, delimitedBy: ",")
        var code = i.array();
        code[1] = 12
        code[2] = 2
        
        let machine = IntCodeMachine(withCode: code)
        try machine.run()
        let state = machine.array()
        
        return state[0]
    }
    
    public override func execute() -> [UIEntry] {
        
        var part1Entry: UIEntry
        do {
            let day1Part1Result = try calculatePart1()
            part1Entry = UIEntry(
                thatDisplays: String(day1Part1Result),
                labeledWith: "Part 1"
            )
        } catch {
            part1Entry = UIEntry(
                thatDisplays: "\(error)",
                labeledWith: "Part 1",
                isError: true
            )
        }
        
        return [
            UIEntry(thatDisplays: "Day 2 Solution"),
            part1Entry
        ]
    }
    
}
