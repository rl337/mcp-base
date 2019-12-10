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
        let day10InputFile = getFileFromProject(named: "Day10Input.txt")
        var map = try String(contentsOf: day10InputFile)
        if map.last == "\n" {
            map.removeLast()
        }
        let field = AsteroidField(data: map)
        let origin = try field.findBestCoordForStation()

        return try compute200thZapped(map: map, origin: origin!)
    }
    
    func compute200thZapped(map: String, origin: GridPoint) throws -> Int {
        let field = AsteroidField(data: map)
        var numZapped = 0
        var target: GridPoint?
        while target == nil {
            let list = try field.listVisibleOrderedByAngle(origin: origin)
            for item in list {
                if numZapped == 199 {
                    target = item
                    break
                }
                try field.zapAsteroid(x: item.x, y: item.y)
                numZapped += 1
            }
        }
        return target!.x*100 + target!.y
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
