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
    
    init(code: [Int], location: GridPoint = GridPoint(x: 0, y: 0)) {
        self.machine = IntCodeMachine(withCode: code)
        self.path = []
        self.map = [:]
        self.location = location
        self.map[location] = -1
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
    var code: [Int]
    
    init(code: [Int]) {
        self.code = code
    }
    
    func searchForOxygenTank() throws -> RepairBotPath {
        var pathQueue: [RepairBotPath] = []
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
    
    func createMap() throws -> [GridPoint: Int] {
        var pathQueue: [RepairBotPath] = []
        pathQueue.append(RepairBotPath(code: code))
        var result: [GridPoint: Int] = [:]
        while pathQueue.count > 0 {
            let path = pathQueue.removeFirst()
            
            let north = try path.getLocationFromCommand(command: 1)
            if path.map[north] == nil {
                let northPath = path.clone()
                let northResult = try northPath.move(command: 1)
                if northResult == 2 {
                    result[north] = 2
                } else if northResult == 1 {
                    pathQueue.append(northPath)
                    result[north] = 1
                } else if northResult == 0 {
                    result[north] = 0
                }
            }
            
            let south = try path.getLocationFromCommand(command: 2)
            if path.map[south] == nil {
                let southPath = path.clone()
                let southResult = try southPath.move(command: 2)
                if southResult == 2 {
                    result[south] = 2
                } else if southResult == 1 {
                    pathQueue.append(southPath)
                    result[south] = 1
                } else if southResult == 0 {
                    result[south] = 0
                }
            }

            let west = try path.getLocationFromCommand(command: 3)
            if path.map[west] == nil {
                let westPath = path.clone()
                let westResult = try westPath.move(command: 3)
                if westResult == 2 {
                    result[west] = 2
                } else if westResult == 1 {
                    pathQueue.append(westPath)
                    result[west] = 1
                } else if westResult == 0 {
                    result[west] = 0
                }
            }
            
            let east = try path.getLocationFromCommand(command: 4)
            if path.map[east] == nil {
                let eastPath = path.clone()
                let eastResult = try eastPath.move(command: 4)
                if eastResult == 2 {
                    result[east] = 2
                } else if eastResult == 1 {
                    pathQueue.append(eastPath)
                    result[east] = 1
                } else if eastResult == 0 {
                    result[east] = 0
                }
            }
        }
        return result
    }
    
    func getLongestPathFromOxygenTank() throws -> RepairBotPath {
        let map = try self.createMap()
        let candidates = map.filter{ $0.value == 2 }
        if candidates.count != 1 {
            throw RepairBotMapperError.NoOxygenTankFound
        }
        guard let tank = candidates.first else {
            throw RepairBotMapperError.NoOxygenTankFound
        }
        
        var pathQueue: [RepairBotPath] = []
        pathQueue.append(RepairBotPath(code: code, location: tank.key))
        
        var longestPath: RepairBotPath = pathQueue[0]
        while true {
            let path = pathQueue.removeFirst()

            let north = try path.getLocationFromCommand(command: 1)
            if path.map[north] == nil {
                let northPath = path.clone()
                northPath.location = north
                if map[north] == 1 {
                    northPath.map[north] = 1
                    northPath.path.append(1)
                    pathQueue.append(northPath)
                } else {
                    path.map[north] = 0
                }
            }
            
            let south = try path.getLocationFromCommand(command: 2)
            if path.map[south] == nil {
                let southPath = path.clone()
                southPath.location = south
                if map[south] == 1 {
                    southPath.path.append(2)
                    southPath.map[south] = 1
                    pathQueue.append(southPath)
                } else {
                    path.map[south] = 0
                }
            }

            let west = try path.getLocationFromCommand(command: 3)
            if path.map[west] == nil {
                let westPath = path.clone()
                westPath.location = west
                if map[west] == 1 {
                    westPath.map[west] = 1
                    westPath.path.append(3)
                    pathQueue.append(westPath)
                } else {
                   path.map[west] = 0
               }
            }
            
            let east = try path.getLocationFromCommand(command: 4)
            if path.map[east] == nil {
                let eastPath = path.clone()
                eastPath.location = east
                if map[east] == 1 {
                    eastPath.map[east] = 1
                    eastPath.path.append(4)
                    pathQueue.append(eastPath)
                } else {
                    path.map[east] = 0
                }
            }
            
            if path.path.count > longestPath.path.count {
                longestPath = path
            }
            
            if pathQueue.count < 1 {
                return longestPath
            }
        }
    }
    
    enum RepairBotMapperError: Error {
        case NoOxygenTankFound
    }
    
}
