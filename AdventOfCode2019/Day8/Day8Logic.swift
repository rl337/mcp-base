//
//  Day8Logic.swift
//  AdventOfCode2019
//
//  Created by Richard Lee on 12/7/19.
//  Copyright © 2019 Richard Lee. All rights reserved.
//

import Foundation

class DayEightSolution : DayOfCodeSolution {
    
    func countValues(value: Int, data: [Int]) -> Int {
        var total = 0
        for i in data {
            if i == value {
                total += 1
            }
        }
        return total
    }
    
    func calculatePart1() throws -> Int {
        let day8InputFile = getFileFromProject(named: "Day8Input.txt")
        var data = try String(contentsOf: day8InputFile)
        if data.last == "\n" {
            data.removeLast()
        }
        let img = SpaceImageFormat(width: 25, height: 6, data: data)
        
        var fewest0s: [Int] = img.getLayer(n: 0)
        var fewestCount = countValues(value: 0, data: fewest0s)
        for n in 1..<img.count {
            let candidate = img.getLayer(n: n)
            let candidateCount = countValues(value: 0, data: candidate)
            
            if candidateCount < fewestCount {
                fewestCount = candidateCount
                fewest0s = candidate
            }
        }
        
        return countValues(value: 1, data: fewest0s) * countValues(value: 2, data: fewest0s)
    }
    
    func calculatePart2() throws -> String {
        let day8InputFile = getFileFromProject(named: "Day8Input.txt")
        var data = try String(contentsOf: day8InputFile)
        if data.last == "\n" {
            data.removeLast()
        }
        let img = SpaceImageFormat(width: 25, height: 6, data: data)
        let rendering = img.render()
        var result = "\n"
        for y in 0..<6 {
            for x in 0..<25 {
                let i = y * 25 + x
                switch(rendering[i]) {
                case 0: result.append(".")
                case 1: result.append("#")
                case 2: result.append(" ")
                default:
                    continue
                }
                
            }
            result.append("\n")
        }
        return result
    }
    
    public override func execute() -> [UIEntry] {
        let part1Entry = getEntryForFunction(1, method: calculatePart1, labeledWith: "Part 1")
        let part2Entry = getEntryForStringFunction(2, method: calculatePart2, labeledWith: "Part 2")
        
        return [
            UIEntry(withId: 0, thatDisplays: "Day 8 Solution"),
            part1Entry,
            part2Entry
        ]
    }

}
