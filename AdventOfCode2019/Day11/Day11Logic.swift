//
//  Day11Logic.swift
//  AdventOfCode2019
//
//  Created by Richard Lee on 12/10/19.
//  Copyright © 2019 Richard Lee. All rights reserved.
//

class DayElevenSolution : DayOfCodeSolution {
    
    func calculatePart1() throws -> Int {
        let day11InputFile = getFileFromProject(named: "Day11Input.txt")
        let i = try IntFileIterator(contentsOf: day11InputFile, delimitedBy: ",")
        let code = i.array();
        
        let grid = PanelGrid(program: code)
        try grid.run()
        return grid.count
    }
    
    func calculatePart2() throws -> String {
        let day11InputFile = getFileFromProject(named: "Day11Input.txt")
        let i = try IntFileIterator(contentsOf: day11InputFile, delimitedBy: ",")
        let code = i.array();
        
        let grid = PanelGrid(program: code)
        grid.data[GridPoint(x: 0, y: 0)] = 1
        try grid.run()
        return grid.asBitmap()
    }
    
    public override func execute() -> [UIEntry] {
        let part1Entry = getEntryForFunction(1, method: calculatePart1, labeledWith: "Part 1")
        let part2Entry = getEntryForStringFunction(2, method: calculatePart2, labeledWith: "Part 2")
        
        return [
            UIEntry(withId: 0, thatDisplays: "Day 11 Solution"),
            part1Entry,
            part2Entry
        ]
    }

}
