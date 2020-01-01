//
//  Day21Logic.swift
//  AdventOfCode2019
//
//  Created by Richard Lee on 12/21/19.
//  Copyright © 2019 Richard Lee. All rights reserved.
//

import Foundation

class DayTwentyOneSolution : DayOfCodeSolution {
    
    func calculatePart1() throws -> String {
        let day21InputFile = getFileFromProject(named: "Day21Input.txt")
        let machine = try IntCodeMachine(fromURL: day21InputFile)
        machine.addInput(values:
            // Check if 4 spaces away is solid, jump if any holes exist between
            Array<Character>("""
OR D J
WALK

"""
            ).asIntArray()
        )
        try machine.run()
        var output = machine.output()

        if output.count > 1 {
            var resultList: [String] = []
            var damage = 0
            if output.last! > 255 {
                damage = output.removeLast()

            }
            resultList.append(output.asAsciiString())
            resultList.append(String(damage))
            return resultList.joined(separator: "\n")
        }
        return output.asStringArray().joined(separator: ", ")
    }
    
    func calculatePart2() throws -> String {
                let day21InputFile = getFileFromProject(named: "Day21Input.txt")
                let machine = try IntCodeMachine(fromURL: day21InputFile)
                machine.addInput(values:
                    // Check if 4 spaces away is solid, jump if any holes exist between
                    Array<Character>("""
        NOT T T
        AND A T
        AND B T
        AND C T
        NOT T J
        AND D J
        WALK

        """
                    ).asIntArray()
                )
                try machine.run()
                var output = machine.output()

                if output.count > 1 {
                    var resultList: [String] = []
                    var damage = 0
                    if output.last! > 255 {
                        damage = output.removeLast()

                    }
                    resultList.append(output.asAsciiString())
                    resultList.append(String(damage))
                    return resultList.joined(separator: "\n")
                }
                return output.asStringArray().joined(separator: ", ")
    }
    
    public override func heading() -> [UIEntry] {
        return [
            UIEntry(withId: 0, thatDisplays: "Day 19 Solution"),
        ]
    }
    
    public override func execute() -> [UIEntry] {
        let part1Entry = getEntryForStringFunction(1, method: calculatePart1, labeledWith: "Part 1", monospaced: true)
        let part2Entry = getEntryForStringFunction(2, method: calculatePart2, labeledWith: "Part 2", monospaced: true)
        
        let result =  [
            part1Entry,
            part2Entry
        ]
        
        return result
    }

}
