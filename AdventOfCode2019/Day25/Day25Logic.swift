//
//  Day25Logic.swift
//  AdventOfCode2019
//
//  Created by Richard Lee on 12/24/19.
//  Copyright © 2019 Richard Lee. All rights reserved.
//

import Foundation

class DayTwentyFiveSolution : DayOfCodeSolution {
    
    func runIntCodeCommand(_ machine: IntCodeMachine, _ input: String?) throws -> String {
        
        if input != nil {
            var commandInts = Array<Character>(input!).asIntArray()
            commandInts.append(10)
            machine.addInput(values: commandInts)
        }
        
        do {
            try machine.run()
        } catch IntCodeMachine.IntCodeMachineError.UnexpectedEndOfInput {
        
        }
        
        let output = machine.output()
        machine.clearOutput()
        
        return output.asAsciiString()
    }
    
    let itemPaths: [String:[String]] = [
        "cake": ["north", "north", "east", "east"],
        "easter egg": ["south", "west", "west"],
        "hologram": ["east", "east"],
        "dark matter": ["east", "east", "east"],
        "klein bottle": ["east", "east", "east", "north", "north", "east"],
        "hypercube": ["east", "east", "east", "north", "north", "east", "north"]
    ]
    
    let reverseDirection: [String: String] = [
        "north": "south",
        "south": "north",
        "east": "west",
        "west": "east"
    ]
    
    // NES == Hull Breach ==
    /*
        "north", // NS == Kitchen ==
        "north", // SE == Passages ==
        "east",  // EW == Hot Chocolae Fountain == (giant electromagnet)
        "east"   // W  == Crew Quarters == (cake)
    */
    
    /*
        "east",  // ESW == Corridor == (ornament)
        "east",  // EW  == Sick Bay == (hologram)
        "east",  // NW  == Gift Wrapping Center == (dark matter)
        "north", // NS  == Engineering ==
        "north", // ES  == Navigation ==
        "east",  // NW  == Observatory == (klein bottle)
        "north", // NS  == Holodeck == (hypercube)
        "north", // SW  == Security Checkpoint ==
        "west"   // E   == Pressure-Sensetive Floor ==
    */
    
    /*
    "east",  // ESW == Corridor == (ornament)
    "south", // NE  == Stables ==
    "east",  // EW  == Storage == (molten lava)
    "east",  // W   == Science Lab == (photons)
    */
    
    /*
        "south",  // NW  == Arcade == (infinite loop)
        "west",   // EW  == Hallway == (fuel cell)
        "west",   // E   == Warp Drive Maintenance == (easter egg)
    */
    
    func takeItem(machine: IntCodeMachine, _ item: String) throws -> [String] {
        guard let pathThere = itemPaths[item] else {
            throw DayTwentyFiveSolutionError.NoItemPath
        }
        
        var lastThereOutput = ""
        for command in pathThere {
            lastThereOutput = try runIntCodeCommand(machine, command)
        }
        
        let takeOutput = try runIntCodeCommand(machine, "take \(item)")
        let takeOutputParts = takeOutput.trim().components(separatedBy: "\n")
        guard takeOutputParts[0] == "You take the \(item)." else {
            throw DayTwentyFiveSolutionError.CouldNotGetItem
        }
        
        var pathBack = pathThere
        pathBack.reverse()
        pathBack = pathBack.map { return reverseDirection[$0]! }
        
        var lastBackOutput = ""
        for command in pathBack {
            lastBackOutput = try runIntCodeCommand(machine, command)
        }
        
        return [ lastThereOutput, "You take the \(item).", lastBackOutput]
    }
    
    func goToPressureSensetiveFloor(machine: IntCodeMachine) throws -> String {
        var lastCommandOutput = ""
        for command in [
            "east",  // ESW == Corridor == (ornament)
            "east",  // EW  == Sick Bay == (hologram)
            "east",  // NW  == Gift Wrapping Center == (dark matter)
            "north", // NS  == Engineering ==
            "north", // ES  == Navigation ==
            "east",  // NW  == Observatory == (klein bottle)
            "north", // NS  == Holodeck == (hypercube)
            "north", // SW  == Security Checkpoint ==
            "west"   // E   == Pressure-Sensetive Floor ==]
            ] {
               lastCommandOutput = try runIntCodeCommand(machine, command)
        }
        
        return lastCommandOutput
    }
    
    func takeItemsGoToPressurePlate(_ items: [String]) throws -> [String] {
        let day25InputFile = getFileFromProject(named: "Day25Input.txt")
        let i = try IntFileIterator(contentsOf: day25InputFile, delimitedBy: ",")
        let code = i.array()
        let machine = IntCodeMachine(withCode: code)
        
        var outputs: [String] = []
        
        for item in items {
            let takeOutput = try takeItem(machine: machine, item)
            outputs.append(takeOutput[1])
        }
        
        let floorOutput = try goToPressureSensetiveFloor(machine: machine)
        if floorOutput.contains("Droids on this ship are heavier") {
            outputs.append("Heavier")
        } else if floorOutput.contains("Droids on this ship are lighter") {
            outputs.append("Lighter")
        } else {
            outputs.append(floorOutput)
        }
        
        return outputs
    }
    

    
    func calculatePart1() throws -> [String] {

        let itemCombinations = [
//            [
//                "cake",
//                "easter egg",
//                "hologram",
//                "dark matter",
//                "klein bottle",
//                "hypercube"
//            ],
//            [
//                "cake",
//                "easter egg",
//                "hologram",
//                //"dark matter",
//                "klein bottle",
//                "hypercube"
//            ],
//            [
//                "cake",
//                "easter egg",
//                //"hologram",
//                //"dark matter",
//                "klein bottle",
//                "hypercube"
//            ],
//            [
//                "cake",
//                "easter egg",
//                //"hologram",
//                "dark matter",
//                "klein bottle",
//                "hypercube"
//            ],
            [
                //"cake",
                "dark matter",
                "klein bottle",
                
                //"hypercube",
                
                "easter egg",
                "hologram",
            ]
            
        ]
        
        var result: [String] = []
        for combination in itemCombinations {
            var output = try takeItemsGoToPressurePlate(combination)
            let last = output.removeLast()
            let rest = combination.joined(separator: ",")
            result.append("\(last): \(rest)")
            
        }
        
        return result
    }
    

    
    func calculatePart2() throws -> Int  {
        0
    }
    
    public override func heading() -> [UIEntry] {
        return [
            UIEntry(withId: 0, thatDisplays: "Day 25 Solution"),
        ]
    }
    
    public override func execute() -> [UIEntry] {
        let part1Entry = getListForStringFunction(10, method: calculatePart1, labeledWith: "Part 1", monospaced: true, reverse: true)
        let part2Entry = getEntryForFunction(8000, method: calculatePart2, labeledWith: "Part 2")
        
        var result: [UIEntry] = part1Entry
        result.append(part2Entry)
        return result
    }
    
    enum DayTwentyFiveSolutionError: Error {
        case NoItemPath, CouldNotGetItem
    }

}
