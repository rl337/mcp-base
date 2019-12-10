//
//  Day10Logic.swift
//  AdventOfCode2019
//
//  Created by Richard Lee on 12/9/19.
//  Copyright © 2019 Richard Lee. All rights reserved.
//

import Foundation

class DayTenSolution : DayOfCodeSolution {
    
    func calculatePart1() throws -> Int {
        let day10InputFile = getFileFromProject(named: "Day10Input.txt")
        var map = try String(contentsOf: day10InputFile)
        if map.last == "\n" {
            map.removeLast()
        }
        let field = AsteroidField(data: map)
        
        return try field.findBestCountForStation()!
    }
    
    func calculatePart2() throws -> Int {
        0
    }
    
    public override func execute() -> [UIEntry] {
        let part1Entry = getEntryForFunction(1, method: calculatePart1, labeledWith: "Part 1")
        let part2Entry = getEntryForFunction(2, method: calculatePart2, labeledWith: "Part 2")
        
        return [
            UIEntry(withId: 0, thatDisplays: "Day 10 Solution"),
            part1Entry,
            part2Entry
        ]
    }
    
    enum DaySevenSolutionError: Error {
        case AmplifierOutputWasInvalid
    }

}
