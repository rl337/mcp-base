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
        let result = try bot.searchForOxygenTank()
        
        return result.path.count
    }
    
    func drawMap() throws -> String {
        let day15InputFile = getFileFromProject(named: "Day15Input.txt")
        let i = try IntFileIterator(contentsOf: day15InputFile, delimitedBy: ",")
        let code = i.array();
        
        let bot = RepairBotMapper(code: code)
        let map = try bot.createMap()
        
        guard let first = map.first else {
            return "Map was empty!"
        }
        
        var minX = first.key.x
        var maxX = first.key.x
        var minY = first.key.y
        var maxY = first.key.y
        for point in map.keys {
            if point.x < minX {
                minX = point.x
            }
            if point.x > maxX {
                maxX = point.x
            }
            if point.y < minY {
                minY = point.y
            }
            if point.y > maxY {
                maxY = point.y
            }
        }
        minX -= 1
        minY -= 1
        
        var result = ""
        for y in minY...maxY {
            for x in minX...maxX {
                var value: Character
                switch map[GridPoint(x: x, y: y)] {
                case 0: value = "#"
                case 1: value = "."
                case 2: value = "O"
                default: value = "?"
                }
                result.append(value)
            }
            result.append("\n")
        }
        
        return result
    }
    
    func renderMap(map: [GridPoint:Int]) -> String {
        guard let first = map.first else {
            return "Map was empty!"
        }

        var minX = first.key.x
        var maxX = first.key.x
        var minY = first.key.y
        var maxY = first.key.y
        for point in map.keys {
            if point.x < minX {
                minX = point.x
            }
            if point.x > maxX {
                maxX = point.x
            }
            if point.y < minY {
                minY = point.y
            }
            if point.y > maxY {
                maxY = point.y
            }
        }
        minX -= 1
        minY -= 1
        
        var result = ""
        for y in minY...maxY {
            for x in minX...maxX {
                var value: Character
                switch map[GridPoint(x: x, y: y)] {
                case 0: value = "#"
                case 1: value = "."
                case 2: value = "O"
                case -1: value = "S"
                default: value = "?"
                }
                result.append(value)
            }
            result.append("\n")
        }
        
        return result
    }
    
    func drawLongestPath() throws -> String  {
        let day15InputFile = getFileFromProject(named: "Day15Input.txt")
        let i = try IntFileIterator(contentsOf: day15InputFile, delimitedBy: ",")
        let code = i.array();
        
        let bot = RepairBotMapper(code: code)
        //return try bot.getLongestPathFromOxygenTank().path.count
        return renderMap(map: try bot.getLongestPathFromOxygenTank().map)
    }
    
    func calculatePart2() throws -> Int  {
        let day15InputFile = getFileFromProject(named: "Day15Input.txt")
        let i = try IntFileIterator(contentsOf: day15InputFile, delimitedBy: ",")
        let code = i.array();
        
        let bot = RepairBotMapper(code: code)
        //return try bot.getLongestPathFromOxygenTank().path.count
        return try bot.getLongestPathFromOxygenTank().path.count
    }
    
    
    public override func heading() -> [UIEntry] {
        return [
            UIEntry(withId: 0, thatDisplays: "Day 15 Solution"),
        ]
    }
    
    public override func execute() -> [UIEntry] {
        let part1Entry = getEntryForFunction(10, method: calculatePart1, labeledWith: "Part 1")
        let partMapEntry = getEntryForStringFunction(20, method: drawMap, labeledWith: "Map", monospaced: true, size: 7)
        let longestPathEntry = getEntryForStringFunction(30, method: drawLongestPath, labeledWith: "Longest Path", monospaced: true, size: 7)
        let part2Entry = getEntryForFunction(40, method: calculatePart2, labeledWith: "Part 2")
        return [
            part1Entry,
            part2Entry,
            partMapEntry,
            longestPathEntry
        ]
    }

}
