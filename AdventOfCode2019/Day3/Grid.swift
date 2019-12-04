//
//  Grid.swift
//  AdventOfCode2019
//
//  Created by Richard Lee on 12/2/19.
//  Copyright © 2019 Richard Lee. All rights reserved.
//

import Foundation

public struct GridPoint : Hashable{
    var x: Int
    var y: Int
    
    init(x: Int, y: Int) {
        self.x = x
        self.y = y
    }
    
    func getManhattanDistance(p: GridPoint) -> Int {
        return calcManhattanDistance(a: self, b: p)
    }
}

let Origin = GridPoint(x: 0, y: 0)

public struct GridLine {
    var a: GridPoint
    var b: GridPoint
    
    init(a: GridPoint, b: GridPoint) {
        self.a = a
        self.b = b
    }
}

public class Grid {
    var data: [GridPoint: Int]
    
    init() {
        data = [:]
    }
    
    func get(point: GridPoint) -> Int? {
        return data[point]
    }
    
    func set(point: GridPoint, value: Int) {
        data[point] = value
    }
    
    func setStraightLine(line: GridLine, value: Int) throws {
        if line.a.x == line.b.x {
            var y1: Int
            var y2: Int
            
            if line.a.y > line.b.y {
                y2 = line.a.y
                y1 = line.b.y
            } else {
                y2 = line.b.y
                y1 = line.a.y
            }
            
            let x = line.a.x
            for y in y1...y2 {
                set(point: GridPoint(x: x, y: y), value: value)
            }
            return
        }
        
        if line.a.y == line.b.y {
            var x1: Int
            var x2: Int
            
            if line.a.x > line.b.x {
                x2 = line.a.x
                x1 = line.b.x
            } else {
                x2 = line.b.x
                x1 = line.a.x
            }
            
            let y = line.a.y
            for x in x1...x2 {
                set(point: GridPoint(x: x, y: y), value: value)
            }
            return
        }
        
        throw GridError.LineIsNotStraight
    }
    
    func lineIntersectsPointInSteps(line: GridLine, point: GridPoint) throws -> Int? {
        if line.a.x == line.b.x {
            if point.x != line.a.x {
                return nil
            }
            
            return calcManhattanDistance(a: line.a, b: point)
        }
        
        if line.a.y == line.b.y {
            if point.y != line.a.y {
                return nil
            }
            return calcManhattanDistance(a: line.a, b: point)
        }
        
        throw GridError.LineIsNotStraight
    }
    
    func getIntersections(line: GridLine, value: Int) throws -> [GridPoint] {
        var intersections : [GridPoint] = []
        if line.a.x == line.b.x {
            var y1: Int
            var y2: Int
            
            if line.a.y > line.b.y {
                y2 = line.a.y
                y1 = line.b.y
            } else {
                y2 = line.b.y
                y1 = line.a.y
            }
            
            let x = line.a.x
            for y in y1...y2 {
                let coord = GridPoint(x: x, y: y)
                guard coord != Origin else {
                    continue
                }
                
                if let result = get(point: coord) {
                    if result != value {
                        intersections.append(coord)
                    }
                }
            }
            return intersections
        }
        
        if line.a.y == line.b.y {
            var x1: Int
            var x2: Int
            
            if line.a.x > line.b.x {
                x2 = line.a.x
                x1 = line.b.x
            } else {
                x2 = line.b.x
                x1 = line.a.x
            }
            
            let y = line.a.y
            for x in x1...x2 {
                let coord = GridPoint(x: x, y: y)
                if let result = get(point: coord) {
                    if result != value && coord != Origin {
                        intersections.append(coord)
                    }
                }
            }
            return intersections
        }
        
        throw GridError.LineIsNotStraight
    }
    
    enum GridError : Error {
        case LineIsNotStraight
    }
}

class CursorGrid : Grid {
    var cursor: GridPoint
    
    override init() {
        cursor = GridPoint(x: 0, y: 0)
        super.init()
    }
    
    func move(command: String, value: Int) throws -> [GridPoint] {
        if command.count < 2 {
            throw CursorGridError.IllegalCommand
        }
        
        var command = command
        let direction = command.removeFirst()
        guard let distance = Int(command) else {
            throw CursorGridError.BadDistance
        }
        
        var newPosition: GridPoint
        switch direction {
        case "U": newPosition = GridPoint(x: cursor.x, y: cursor.y + distance)
        case "D": newPosition = GridPoint(x: cursor.x, y: cursor.y - distance)
        case "L": newPosition = GridPoint(x: cursor.x - distance, y: cursor.y)
        case "R": newPosition = GridPoint(x: cursor.x + distance, y: cursor.y)
        default: throw CursorGridError.BadDirection
        }
        
        let proposedLine = GridLine(a: cursor, b: newPosition)
        let intersections = try getIntersections(line: proposedLine, value: value)
        try setStraightLine(line: proposedLine, value: value)
        cursor = newPosition
        return intersections
    }
    
    func follow(commands: [String], value: Int) throws -> GridPoint? {
        var closestIntersection: GridPoint?
        for command in commands {
            let intersections = try move(command: command, value: value)
            if intersections.count > 0 {
                if closestIntersection == nil {
                    closestIntersection = intersections[0]
                }
                for intersection in intersections {
                    if calcManhattanDistance(a: intersection, b: Origin) < calcManhattanDistance(a: closestIntersection!, b: Origin) {
                        closestIntersection = intersection
                    }
                }
            }
        }
        cursor = Origin
        return closestIntersection
    }
    
    func followAllIntersections(commands: [String], value: Int) throws -> [GridPoint] {
        var allIntersections: [GridPoint] = []
        for command in commands {
            let intersections = try move(command: command, value: value)
            if intersections.count > 0 {
                allIntersections.append(contentsOf: intersections)
            }
        }
        cursor = Origin
        return allIntersections
    }
    
    func stepsUntilCommands(commands: [String], point: GridPoint) throws -> Int {
        var position = Origin
        var total = 0
        for command in commands {
            var command = command
            let direction = command.removeFirst()
            guard let distance = Int(command) else {
                throw CursorGridError.BadDistance
            }
            
            var newPosition: GridPoint
            switch direction {
            case "U": newPosition = GridPoint(x: position.x, y: position.y + distance)
            case "D": newPosition = GridPoint(x: position.x, y: position.y - distance)
            case "L": newPosition = GridPoint(x: position.x - distance, y: position.y)
            case "R": newPosition = GridPoint(x: position.x + distance, y: position.y)
            default: throw CursorGridError.BadDirection
            }
            
            let proposedLine = GridLine(a: position, b: newPosition)
            guard let partialSteps = try lineIntersectsPointInSteps(line: proposedLine, point: point) else {
                total += calcManhattanDistance(a: position, b: newPosition)
                position = newPosition
                continue
            }
            
            total += partialSteps
            return total
        }
        
        throw CursorGridError.IntersectionNeverHappens
    }
    
    enum CursorGridError : Error {
        case IllegalCommand
        case BadDirection
        case BadDistance
        case IntersectionNeverHappens
    }
}

func calcManhattanDistance(a: GridPoint, b: GridPoint) -> Int {
    return abs(a.x - b.x) + abs(a.y - b.y)
}
