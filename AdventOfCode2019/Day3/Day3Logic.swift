//
//  Day3Logic.swift
//  AdventOfCode2019
//
//  Created by Richard Lee on 12/2/19.
//  Copyright © 2019 Richard Lee. All rights reserved.
//

import Foundation

class DayThreeSolution : DayOfCodeSolution {
    
    func calculatePart1() throws -> Int {
        let day3InputFile = getFileFromProject(named: "Day3Input.txt")
        var content = try String(contentsOf: day3InputFile)
        if content.hasSuffix("\n") {
            content.removeLast()
        }
        let lines = content.split(separator: "\n")
        
        let commands1 = lines[0].components(separatedBy: ",")
        let commands2 = lines[1].components(separatedBy: ",")

        let grid = CursorGrid()
        _ = try grid.follow(commands: commands1, value: 1)
        let closest = try grid.follow(commands: commands2, value: 2)
        return calcManhattanDistance(a: Origin, b: closest!)
    }
    
    func calculateShortestStepsFor(commands1: [String], commands2: [String]) throws -> Int {
        let grid = CursorGrid()
        _ = try grid.follow(commands: commands1, value: 1)
        let intersections = try grid.followAllIntersections(commands: commands2, value: 2)
        
        var shortestSteps = try grid.stepsUntilCommands(commands: commands1, point: intersections[0]) + grid.stepsUntilCommands(commands: commands2, point: intersections[1])
        for intersection in intersections {
            let steps = try grid.stepsUntilCommands(commands: commands1, point: intersection) + grid.stepsUntilCommands(commands: commands2, point: intersection)
            if steps < shortestSteps {
                shortestSteps = steps
            }
        }
        
        return shortestSteps
    }
    
    func calculatePart2() throws -> Int {
        let day3InputFile = getFileFromProject(named: "Day3Input.txt")
        var content = try String(contentsOf: day3InputFile)
        if content.hasSuffix("\n") {
            content.removeLast()
        }
        let lines = content.split(separator: "\n")
        
        let commands1 = lines[0].components(separatedBy: ",")
        let commands2 = lines[1].components(separatedBy: ",")

        return try calculateShortestStepsFor(commands1: commands1, commands2: commands2)
    }
    
    
    public override func execute() -> [UIEntry] {
        let part1Entry = getEntryForFunction(method: calculatePart1, labeledWith: "Part 1")
        let part2Entry = getEntryForFunction(method: calculatePart2, labeledWith: "Part 2")
        
        return [
            UIEntry(thatDisplays: "Day 3 Solution"),
            part1Entry,
            part2Entry
        ]
    }

}
