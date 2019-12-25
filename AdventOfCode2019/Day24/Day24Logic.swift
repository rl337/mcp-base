//
//  Day24Logic.swift
//  AdventOfCode2019
//
//  Created by Richard Lee on 12/24/19.
//  Copyright © 2019 Richard Lee. All rights reserved.
//

import Foundation

class DayTwentyFourSolution : DayOfCodeSolution {
    
    func calculatePart1() throws -> Int {
        let day24InputFile = getFileFromProject(named: "Day24Input.txt")
        let initialState = try String(contentsOf: day24InputFile)
        
        var seenStates = Set<Int>()
        let grid = BugGrid(5, initialState)
        while true {
            let currentState = grid.asString().hashValue
            if seenStates.contains(currentState) {
                break
            }
            
            grid.step()
            seenStates.insert(currentState)
        }
        
        return grid.computeBiodiversity()
    }
    
    func calculatePart2() throws -> Int  {
        0
    }
    
    public override func heading() -> [UIEntry] {
        return [
            UIEntry(withId: 0, thatDisplays: "Day 24 Solution"),
        ]
    }
    
    public override func execute() -> [UIEntry] {
        let part1Entry = getEntryForFunction(10, method: calculatePart1, labeledWith: "Part 1")
        let part2Entry = getEntryForFunction(40, method: calculatePart2, labeledWith: "Part 2")
        return [
            part1Entry,
            part2Entry,
        ]
    }

}
