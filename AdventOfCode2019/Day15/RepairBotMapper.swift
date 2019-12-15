//
//  RepairBotMapper.swift
//  AdventOfCode2019
//
//  Created by Richard Lee on 12/14/19.
//  Copyright © 2019 Richard Lee. All rights reserved.
//

import Foundation

public class RepairBotPath {
    var machine: IntCodeMachine
    var location: GridPoint
    var path: [Int]
    var map: [GridPoint: Int]
    
    init(code: [Int]) {
        machine = IntCodeMachine(withCode: code)
        path = []
        map = [:]
        location = GridPoint(x: 0, y: 0)
        map[location] = -1
    }
    
    func getLocationFromCommand(command: Int) throws -> GridPoint {
        var point = location
        switch(command) {
        case 1:
            point.y -= 1
        case 2:
            point.y += 1
        case 3:
            point.x += 1
        case 4:
            point.x -= 1
        default:
            throw RepairBotPathError.InvalidCommand
        }
        return point
    }
    
    func move(command: Int) throws -> Int {
        machine.addInput(value: command)
        
        do {
            try machine.run()
        } catch IntCodeMachine.IntCodeMachineError.UnexpectedEndOfInput {
        }
        
        let output = machine.output()
        machine.clearOutput()
        
        path.append(command)
        location = try getLocationFromCommand(command: command)
        map[location] = output[0]
        
        return output[0]
    }
    
    func clone() -> RepairBotPath {
        let result = RepairBotPath(code: [])
        result.machine = machine.clone()
        result.path = path
        result.map = map
        result.location = location
        return result
    }
    
    enum RepairBotPathError: Error {
        case InvalidCommand
    }
}

public class RepairBotMapper {
    var pathQueue: [RepairBotPath]
    var code: [Int]
    
    init(code: [Int]) {
        self.pathQueue = []
        self.code = code
    }
    
    func search() throws -> RepairBotPath {
        pathQueue.append(RepairBotPath(code: code))
        while true {
            let path = pathQueue.removeFirst()
            
            let north = try path.getLocationFromCommand(command: 1)
            if path.map[north] == nil {
                let northPath = path.clone()
                let northResult = try northPath.move(command: 1)
                if northResult == 2 {
                    return northPath
                } else if northResult == 1 {
                    pathQueue.append(northPath)
                }
            }
            
            let south = try path.getLocationFromCommand(command: 2)
            if path.map[south] == nil {
                let southPath = path.clone()
                let southResult = try southPath.move(command: 2)
                if southResult == 2 {
                    return southPath
                } else if southResult == 1 {
                    pathQueue.append(southPath)
                }
            }

            let west = try path.getLocationFromCommand(command: 3)
            if path.map[west] == nil {
                let westPath = path.clone()
                let westResult = try westPath.move(command: 3)
                if westResult == 2 {
                    return westPath
                } else if westResult == 1 {
                    pathQueue.append(westPath)
                }
            }
            
            let east = try path.getLocationFromCommand(command: 4)
            if path.map[east] == nil {
                let eastPath = path.clone()
                let eastResult = try eastPath.move(command: 4)
                if eastResult == 2 {
                    return eastPath
                } else if eastResult == 1 {
                    pathQueue.append(eastPath)
                }
            }
        }
    }
}
