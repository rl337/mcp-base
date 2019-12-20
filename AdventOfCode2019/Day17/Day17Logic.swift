//
//  Day17Logic.swift
//  AdventOfCode2019
//
//  Created by Richard Lee on 12/16/19.
//  Copyright © 2019 Richard Lee. All rights reserved.
//

import Foundation
class DaySeventeenSolution : DayOfCodeSolution {
    
    func displayMap() throws -> String {
        let day17InputFile = getFileFromProject(named: "Day17Input.txt")
        let i = try IntFileIterator(contentsOf: day17InputFile, delimitedBy: ",")
        let code = i.array();
        
        let bot = VacuumRobotMapper()
        try bot.generateMap(code: code)

        let intersections = try bot.findIntersections()
        var scratchmap = bot.map
        for point in intersections {
            scratchmap.points[point] = Character("O").asInt()
        }
        return scratchmap.asBitmap(mapping: [
            Character("#").asInt(): Character("#"),
            Character(".").asInt(): Character("."),
            Character("^").asInt(): Character("^"),
            Character(">").asInt(): Character(">"),
            Character("<").asInt(): Character("<"),
            Character("v").asInt(): Character("v"),
            Character("O").asInt(): Character("O"),
        ])
    }
    
    func calculatePart1() throws -> Int {
        let day17InputFile = getFileFromProject(named: "Day17Input.txt")
        let i = try IntFileIterator(contentsOf: day17InputFile, delimitedBy: ",")
        let code = i.array();
        
        let bot = VacuumRobotMapper()
        try bot.generateMap(code: code)

        let intersections = try bot.findIntersections()
//        var result = 0
//        for point in intersections {
//            result += (point.x*point.y)
//        }
        let result = intersections.reduce(0) { sum, point in
            sum + (point.x * point.y)
        }
        
        return result
    }
    
    func calculatePart2() throws -> String {
        "Not yet complete"
    }
    
    public override func heading() -> [UIEntry] {
        return [
            UIEntry(withId: 0, thatDisplays: "Day 17 Solution"),
        ]
    }
    
    public override func execute() -> [UIEntry] {

        let mapEntry = getEntryForStringFunction(100, method: displayMap, labeledWith: "Map", monospaced: true, size: 8)
        let part1Entry = getEntryForFunction(200, method: calculatePart1, labeledWith: "Part 1")
        let part2Entry = getEntryForStringFunction(300, method: calculatePart2, labeledWith: "Part 2")
        
        return [
            mapEntry,
            part1Entry,
            part2Entry
        ]
    }

}
