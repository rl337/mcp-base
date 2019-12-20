//
//  VacuumRobotMapper.swift
//  AdventOfCode2019
//
//  Created by Richard Lee on 12/16/19.
//  Copyright © 2019 Richard Lee. All rights reserved.
//

import Foundation

public class VacuumRobotMapper {
    var map: SparseBitmap
    
    init() {
        map = SparseBitmap()
    }
    
    func generateMap(code: [Int]) throws {
        let machine = IntCodeMachine(withCode: code)
        try machine.run()
        
        var x: Int = 0
        var y: Int = 0
        for v in machine.output() {
            if v == 10 {
                x = 0
                y += 1
                continue
            }
            map.points[BitmapPoint(x, y)] = v
            x += 1
        }
    }
    
    func findIntersections() throws -> [BitmapPoint] {
        let scaffold = Int(Character("#").asciiValue!)
        var intersections: [BitmapPoint] = []
        for entry in map.points {
            guard entry.value == scaffold,
                  map.northValue(entry.key) == scaffold,
                  map.southValue(entry.key) == scaffold,
                  map.eastValue(entry.key) == scaffold,
                  map.westValue(entry.key) == scaffold
                  else {
                continue
            }
            intersections.append(entry.key)
        }
        return intersections
    }
    
}
