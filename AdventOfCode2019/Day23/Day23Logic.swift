//
//  Day23Logic.swift
//  AdventOfCode2019
//
//  Created by Richard Lee on 12/22/19.
//  Copyright © 2019 Richard Lee. All rights reserved.
//

import Foundation

class DayTwentyThreeSolution : DayOfCodeSolution {
    
    func calculatePart1() throws -> Int {
        let day23InputFile = getFileFromProject(named: "Day23Input.txt")
        var network: [IntCodeMachine] = []
        for address in 0..<50 {
            network.append(try IntCodeMachine(fromURL: day23InputFile))
            network[address].addInput(value: address)
        }
        
        while true {

            for address in 0..<network.count {
                let node = network[address]
                if node.input().count < 1 {
                    node.addInput(value: -1)
                }
                do {
                    try node.run()
                } catch IntCodeMachine.IntCodeMachineError.UnexpectedEndOfInput {
                    
                }
                var output = node.output()
                node.clearOutput()
                while output.count > 0 {
                    let toAddress = output.removeFirst()
                    let x = output.removeFirst()
                    let y = output.removeFirst()
                    
                    if toAddress >= 0 && toAddress < network.count {
                        network[toAddress].addInput(values: [x, y])
                    }
                    
                    if toAddress == 255 {
                        return y
                    }
                }
            }
        }
    }
    
    func calculatePart2() throws -> Int  {
        let day23InputFile = getFileFromProject(named: "Day23Input.txt")
        let i = try IntFileIterator(contentsOf: day23InputFile, delimitedBy: ",")
        let code = i.array();
        var network: [IntCodeMachine] = []
        for address in 0..<50 {
            network.append(IntCodeMachine(withCode: code))
            network[address].addInput(value: address)
        }
        var natValue = (x: -1, y: -1)
        var lastSentNatYValue = -1
        while true {
            var isIdle = true
            for address in 0..<network.count {
                let node = network[address]
                if node.input().count < 1 {
                    node.addInput(value: -1)
                } else {
                    isIdle = false
                }
                
                do {
                    try node.run()
                } catch IntCodeMachine.IntCodeMachineError.UnexpectedEndOfInput {
                    
                }
                var output = node.output()
                if output.count > 0 {
                    isIdle = false
                }
                node.clearOutput()
                while output.count > 0 {
                    let toAddress = output.removeFirst()
                    let x = output.removeFirst()
                    let y = output.removeFirst()
                    
                    if toAddress >= 0 && toAddress < network.count {
                        network[toAddress].addInput(values: [x, y])
                    }
                    
                    if toAddress == 255 {
                        natValue.x = x
                        natValue.y = y
                    }
                }
            }
            
            if isIdle {
                if natValue.y == lastSentNatYValue {
                    return lastSentNatYValue
                }
                
                network[0].addInput(values: [natValue.x, natValue.y])
                lastSentNatYValue = natValue.y
            }
        }
        
    }
    
    public override func heading() -> [UIEntry] {
        return [
            UIEntry(withId: 0, thatDisplays: "Day 23 Solution"),
        ]
    }
    
    public override func execute() -> [UIEntry] {
        let part1Entry = getEntryForFunction(10, method: calculatePart1, labeledWith: "Part 1")
        let part2Entry = getEntryForFunction(40, method: calculatePart2, labeledWith: "Part 2")
        return [
            part1Entry,
            part2Entry,
        ]
    }

}
