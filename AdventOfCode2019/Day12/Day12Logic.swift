//
//  Day12Logic.swift
//  AdventOfCode2019
//
//  Created by Richard Lee on 12/11/19.
//  Copyright © 2019 Richard Lee. All rights reserved.
//

import Foundation
class DayTwelveSolution : DayOfCodeSolution {
    
    func calculatePart1() throws -> Int {
        let day12InputFile = getFileFromProject(named: "Day12Input.txt")
        var content = try String(contentsOf: day12InputFile)
        while content.last == "\n" {
            content.removeLast()
        }
        var moons: [Point3D] = []
        for moonStr in content.components(separatedBy: "\n") {
            moons.append(try Point3D.parse(str: moonStr))
        }
        let gravity = GravitySystem(data: moons)
        _ = try gravity.step(1000)
        return gravity.totalEnergy()
    }
    
    func calculatePart2() throws -> Int {
        let day12InputFile = getFileFromProject(named: "Day12Input.txt")
        var content = try String(contentsOf: day12InputFile)
        while content.last == "\n" {
            content.removeLast()
        }
        var moons: [Point3D] = []
        for moonStr in content.components(separatedBy: "\n") {
            moons.append(try Point3D.parse(str: moonStr))
        }
        let gravity = GravitySystem(data: moons)
        //return try GravitySystem.stepsToRepeat(gravity: gravity)
        return gravity.totalEnergy()
    }
    
    public override func execute() -> [UIEntry] {
        let part1Entry = getEntryForFunction(1, method: calculatePart1, labeledWith: "Part 1")
        let part2Entry = getEntryForFunction(2, method: calculatePart2, labeledWith: "Part 2")
        
        return [
            UIEntry(withId: 0, thatDisplays: "Day 12 Solution"),
            part1Entry,
            part2Entry
        ]
    }

}
