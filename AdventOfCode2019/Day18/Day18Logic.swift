//
//  Day18Logic.swift
//  AdventOfCode2019
//
//  Created by Richard Lee on 1/20/20.
//  Copyright © 2020 Richard Lee. All rights reserved.
//

import Foundation

class DayEighteenSolution : DayOfCodeSolution {
    
    func calculatePart1() throws -> Int {
        let day18InputFile = getFileFromProject(named: "Day18Input.txt")
        let content = try String(contentsOf: day18InputFile)
        
        let collector = try KeyCollector(rawMap: content)
        let shortest = try collector.collectAllKeys()
        
        return shortest.distance
    }
    
    func calculatePart2() throws -> Int {
        return 0
    }
    
    public override func heading() -> [UIEntry] {
        return [
            UIEntry(withId: 0, thatDisplays: "Day 18 Solution"),
        ]
    }
    
    public override func execute() -> [UIEntry] {
        let part1Entry = getEntryForFunction(100, method: calculatePart1, labeledWith: "Part 1")

        let part2Entry = getEntryForFunction(300, method: calculatePart2, labeledWith: "Part 2")
        
        return [
            part1Entry,
            part2Entry,
        ]
    }

}
