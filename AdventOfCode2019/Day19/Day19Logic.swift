//
//  Day19Logic.swift
//  AdventOfCode2019
//
//  Created by Richard Lee on 12/19/19.
//  Copyright © 2019 Richard Lee. All rights reserved.
//

import Foundation

class DayNineteenSolution : DayOfCodeSolution {
    
    func calculatePart1() throws -> Int {
        let day19InputFile = getFileFromProject(named: "Day19Input.txt")
        let i = try IntFileIterator(contentsOf: day19InputFile, delimitedBy: ",")
        let code = i.array()
        let mapper = TractorBeamMapper()
        try mapper.mapTractorBeam(code)
        
        return mapper.map.points.count
    }
    
    func calculatePart2() throws -> [Int] {
        let day19InputFile = getFileFromProject(named: "Day19Input.txt")
        let i = try IntFileIterator(contentsOf: day19InputFile, delimitedBy: ",")
        let code = i.array()
        
        let mapper = TractorBeamMapper()
        
        var result: [Int] = []
        for height in [10, 20, 40, 80] {
            result.append(try mapper.findWidthAtHeight(code, height))
        }
        return result
    }
    
    func displayTractorBeam() throws -> String {
        let day19InputFile = getFileFromProject(named: "Day19Input.txt")
        let i = try IntFileIterator(contentsOf: day19InputFile, delimitedBy: ",")
        let code = i.array()
        
        let mapper = TractorBeamMapper()
        try mapper.mapTractorBeam(code)
        
        return mapper.map.asBitmap(mapping: [
            1: Character("#"),
            nil: Character("."),
        ])
    }
    
    public override func heading() -> [UIEntry] {
        return [
            UIEntry(withId: 0, thatDisplays: "Day 19 Solution"),
        ]
    }
    
    public override func execute() -> [UIEntry] {
        let part1Entry = getEntryForFunction(100, method: calculatePart1, labeledWith: "Part 1")
        let displayBeam =  getEntryForStringFunction(200, method: displayTractorBeam, labeledWith: "Beam Image", monospaced: true)

        let part2Entry = getListForFunction(300, method: calculatePart2, labeledWith: "Part 2")
        
        var result =  [
            part1Entry,
            displayBeam,
        ]
        
        result.append(contentsOf: part2Entry)
        return result
    }

}
