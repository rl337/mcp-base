//
//  PanelGrid.swift
//  AdventOfCode2019
//
//  Created by Richard Lee on 12/10/19.
//  Copyright © 2019 Richard Lee. All rights reserved.
//

import Foundation

enum RobotDirection {
    case Up, Down, Left, Right
}

class PanelGrid {
    var data: [GridPoint: Int]
    var position: GridPoint
    var direction: RobotDirection
    var robot: IntCodeMachine
    var maxX: Int
    var minX: Int
    var maxY: Int
    var minY: Int
    
    init(program: [Int]) {
        data = [:]
        position = GridPoint(x: 0, y: 0)
        direction = .Up
        robot = IntCodeMachine(withCode: program)
        minX = 0
        maxX = 0
        minY = 0
        maxY = 0
    }
    
    func turnRobot(turn: Int) throws {
        switch(turn, direction) {
        case (0, .Up):
            direction = .Left
        case (0, .Left):
            direction = .Down
        case (0, .Down):
            direction = .Right
        case (0, .Right):
            direction = .Up
        case (1, .Up):
            direction = .Right
        case (1, .Right):
            direction = .Down
        case (1, .Down):
            direction = .Left
        case (1, .Left):
            direction = .Up
        default:
            throw PanelGridError.BadDirection
        }
    }
    
    func moveRobotForward() throws {
        switch direction {
        case .Up: position.y -= 1
        case .Left: position.x += 1
        case .Down: position.y += 1
        case .Right: position.x -= 1
        }
    }
    
    func step() throws{
        let color = data[position] ?? 0
        
        robot.addInput(value: color)
        do {
            try robot.run()
        } catch {
            
        }
        
        let output = robot.output()
        robot.clearOutput()
        data[position] = output[0]
        if position.x > maxX {
            maxX = position.x
        }
        if position.x < minX {
            minX = position.x
        }
        if position.y > maxY {
            maxY = position.y
        }
        if position.y < minY {
            minY = position.y
        }
        try turnRobot(turn: output[1])
        try moveRobotForward()
    }
    
    func asBitmap() -> String {
        let width = maxX - minX
        let height = maxY - minY
        
        var result: String = "\n"
        for y in 0...height {
            var row: [Character] = Array(repeating: "#", count: width+1)
            for x in 0...width {
                switch data[GridPoint(x: maxX - x, y: minY + y)] {
                case 0: row[x] = " "
                case 1: row[x] = "#"
                default: row[x] = " "
                }
            }
            result.append(contentsOf: String(row))
            result.append(contentsOf: String("\n"))
        }
        return result
    }
    
    func run() throws {
        while !robot.isHalted() {
            try step()
        }
    }
    
    var count: Int {
        get {
            return data.count
        }
    }
    
    enum PanelGridError: Error {
        case BadDirection
    }
}
