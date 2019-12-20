//
//  Day17Logic.swift
//  AdventOfCode2019
//
//  Created by Richard Lee on 12/15/19.
//  Copyright © 2019 Richard Lee. All rights reserved.
//

import Foundation

class DaySixteenSolution : DayOfCodeSolution {
    
    func calculatePart1() throws -> String {
        let day16InputFile = getFileFromProject(named: "Day16Input.txt")
        let input = try String(contentsOf: day16InputFile).trim()
        let fft = try FlawedFrequencyTransmission(rawSignal: input)
        let result = try fft.phase(phase: 100)[0...7]
        return "\(result)"
    }
    
    func calculatePart2() throws -> String {
        let day16InputFile = getFileFromProject(named: "Day16Input.txt")
        let input = try String(contentsOf: day16InputFile).trim()
        let fft = try FlawedFrequencyTransmission(rawSignal: input)
        let result = try fft.phase(phase: 0)[0...7]

        return "\(result)"
    }
    
    public override func heading() -> [UIEntry] {
        return [
            UIEntry(withId: 0, thatDisplays: "Day 16 Solution"),
        ]
    }
    
    public override func execute() -> [UIEntry] {
        let part1Entry = getEntryForStringFunction(1, method: calculatePart1, labeledWith: "Part 1")
        let part2Entry = getEntryForStringFunction(2, method: calculatePart2, labeledWith: "Part 2")
        
        return [
            part1Entry,
            part2Entry
        ]
    }

}
