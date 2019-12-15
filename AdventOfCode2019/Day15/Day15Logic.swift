//
//  Day15Logic.swift
//  AdventOfCode2019
//
//  Created by Richard Lee on 12/14/19.
//  Copyright © 2019 Richard Lee. All rights reserved.
//

import Foundation

class DayFifteenSolution : DayOfCodeSolution {
    
    func calculatePart1() throws -> Int {
        let day15InputFile = getFileFromProject(named: "Day15Input.txt")
        let i = try IntFileIterator(contentsOf: day15InputFile, delimitedBy: ",")
        let code = i.array();
        
        let bot = RepairBotMapper(code: code)
        let result = try bot.search()
        
        return result.path.count
    }
    
    func calculatePart2() throws -> Int {
        0
    }
    
    
    public override func heading() -> [UIEntry] {
        return [
            UIEntry(withId: 0, thatDisplays: "Day 15 Solution"),
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

}
