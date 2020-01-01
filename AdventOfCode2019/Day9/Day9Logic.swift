//
//  Day9Logic.swift
//  AdventOfCode2019
//
//  Created by Richard Lee on 12/8/19.
//  Copyright © 2019 Richard Lee. All rights reserved.
//

import Foundation

//
//  Day8Logic.swift
//  AdventOfCode2019
//
//  Created by Richard Lee on 12/7/19.
//  Copyright © 2019 Richard Lee. All rights reserved.
//

import Foundation

class DayNineSolution : DayOfCodeSolution {
    
    func countValues(value: Int, data: [Int]) -> Int {
        var total = 0
        for i in data {
            if i == value {
                total += 1
            }
        }
        return total
    }
    
    func calculatePart1() throws -> [Int] {
        let day9InputFile = getFileFromProject(named: "Day9Input.txt")
        let machine = try IntCodeMachine(fromURL: day9InputFile, withInput: [1])
        try machine.run()
        return machine.output()
    }
    
    func calculatePart2() throws -> [Int] {
        let day9InputFile = getFileFromProject(named: "Day9Input.txt")
        let machine = try IntCodeMachine(fromURL: day9InputFile, withInput: [2])
        try machine.run()
        return machine.output()
    }
    
    public override func heading() -> [UIEntry] {
        return [
            UIEntry(withId: 0, thatDisplays: "Day 9 Solution")
        ]
    }
    
    public override func execute() -> [UIEntry] {
        let part1Entry = getListForFunction(100, method: calculatePart1, labeledWith: "Part 1")
        let part2Entry = getListForFunction(200, method: calculatePart2, labeledWith: "Part 2")
        
        var result: [UIEntry] = [
        ]
        result.append(contentsOf: part1Entry)
        result.append(contentsOf: part2Entry)
        
        return result
    }

}
