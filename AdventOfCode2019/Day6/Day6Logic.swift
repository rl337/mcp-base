//
//  Day6Logic.swift
//  AdventOfCode2019
//
//  Created by Richard Lee on 12/5/19.
//  Copyright © 2019 Richard Lee. All rights reserved.
//

import Foundation

class DaySixSolution : DayOfCodeSolution {
    
    func calculatePart1() throws -> Int {
        let day6InputFile = getFileFromProject(named: "Day6Input.txt")
        let content = try String(contentsOf: day6InputFile)
        let map = try OrbitalMap(content)
        
        return map.com.sumOfDepths()
    }
    
    func calculatePart2() throws -> Int {
        let day6InputFile = getFileFromProject(named: "Day6Input.txt")
        let content = try String(contentsOf: day6InputFile)
        let map = try OrbitalMap(content)
        
        return try map.com.findMinimumOrbitalTransfers(a: "YOU", b: "SAN")
    }
    
    public override func heading() -> [UIEntry] {
        return [
            UIEntry(withId: 0, thatDisplays: "Day 6 Solution"),
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
