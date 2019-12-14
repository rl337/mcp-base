//
//  GravitySystem.swift
//  AdventOfCode2019
//
//  Created by Richard Lee on 12/11/19.
//  Copyright © 2019 Richard Lee. All rights reserved.
//

import Foundation

struct Point3D : Equatable, CustomStringConvertible {
    var x: Int
    var y: Int
    var z: Int
    
    var description: String {
        return "<\(x),\(y),\(z)>"
    }
    
    init(_ x: Int, _ y: Int, _ z: Int) {
        self.x = x
        self.y = y
        self.z = z
    }
    
    static func parse(str: String) throws -> Point3D {
        var value = str
        if value.first == "<" {
            value.removeFirst()
        }
        
        if value.last == ">" {
            value.removeLast()
        }
        
        var result = Point3D(0, 0, 0)
        let axisList = value.components(separatedBy: ",")
        for axis in axisList {
            let axisPair = axis.components(separatedBy: "=")
            if axisPair.count != 2 {
                throw Point3DError.MalformedAxisString
            }
            
            var axisValueStr = axisPair[1]
            while axisValueStr.first == " " {
                axisValueStr.removeFirst()
            }
            while axisValueStr.last == " " {
                axisValueStr.removeLast()
            }
            guard let axisValue = Int(axisValueStr) else {
                throw Point3DError.InvalidAxisValue
            }
            var axisName = axisPair[0]
            while axisName.first == " " {
                axisName.removeFirst()
            }
            while axisName.last == " " {
                axisName.removeLast()
            }
            
            switch axisName {
            case "x": result.x = axisValue
            case "y": result.y = axisValue
            case "z": result.z = axisValue
            default: throw Point3DError.InvalidAxisName
            }
        }
        
        return result
    }
    
    enum Point3DError: Error {
        case MalformedAxisString, InvalidAxisName, InvalidAxisValue
    }
    
    static func == (lhs: Point3D, rhs: Point3D) -> Bool {
        return
            lhs.x == rhs.x &&
            lhs.y == rhs.y &&
            lhs.z == rhs.z
    }
}

class GravitySystem: CustomStringConvertible {
    var data: [Point3D]
    var velocities: [Point3D]
    
    var description: String {
        return "\(data),\(velocities)"
    }

    init(data: [Point3D]) {
        self.data = []
        self.data.append(contentsOf: data)
        self.velocities = Array(repeating: Point3D(0, 0, 0), count: data.count)
    }
    
    @inlinable func spotVelocities() throws -> [Point3D] {
        var result = Array(repeating: Point3D(0, 0, 0), count: data.count)
        result[0].x =
            (data[0].x < data[1].x ? 1 : (data[0].x > data[1].x ? -1 : 0)) +
            (data[0].x < data[2].x ? 1 : (data[0].x > data[2].x ? -1 : 0)) +
            (data[0].x < data[3].x ? 1 : (data[0].x > data[3].x ? -1 : 0))
        result[0].y =
            (data[0].y < data[1].y ? 1 : (data[0].y > data[1].y ? -1 : 0)) +
            (data[0].y < data[2].y ? 1 : (data[0].y > data[2].y ? -1 : 0)) +
            (data[0].y < data[3].y ? 1 : (data[0].y > data[3].y ? -1 : 0))
        result[0].z =
            (data[0].z < data[1].z ? 1 : (data[0].z > data[1].z ? -1 : 0)) +
            (data[0].z < data[2].z ? 1 : (data[0].z > data[2].z ? -1 : 0)) +
            (data[0].z < data[3].z ? 1 : (data[0].z > data[3].z ? -1 : 0))
        
        result[1].x =
            (data[1].x < data[0].x ? 1 : (data[1].x > data[0].x ? -1 : 0)) +
            (data[1].x < data[2].x ? 1 : (data[1].x > data[2].x ? -1 : 0)) +
            (data[1].x < data[3].x ? 1 : (data[1].x > data[3].x ? -1 : 0))
        result[1].y =
            (data[1].y < data[0].y ? 1 : (data[1].y > data[0].y ? -1 : 0)) +
            (data[1].y < data[2].y ? 1 : (data[1].y > data[2].y ? -1 : 0)) +
            (data[1].y < data[3].y ? 1 : (data[1].y > data[3].y ? -1 : 0))
        result[1].z =
            (data[1].z < data[0].z ? 1 : (data[1].z > data[0].z ? -1 : 0)) +
            (data[1].z < data[2].z ? 1 : (data[1].z > data[2].z ? -1 : 0)) +
            (data[1].z < data[3].z ? 1 : (data[1].z > data[3].z ? -1 : 0))
        
        result[2].x =
            (data[2].x < data[0].x ? 1 : (data[2].x > data[0].x ? -1 : 0)) +
            (data[2].x < data[1].x ? 1 : (data[2].x > data[1].x ? -1 : 0)) +
            (data[2].x < data[3].x ? 1 : (data[2].x > data[3].x ? -1 : 0))
        result[2].y =
            (data[2].y < data[0].y ? 1 : (data[2].y > data[0].y ? -1 : 0)) +
            (data[2].y < data[1].y ? 1 : (data[2].y > data[1].y ? -1 : 0)) +
            (data[2].y < data[3].y ? 1 : (data[2].y > data[3].y ? -1 : 0))
        result[2].z =
            (data[2].z < data[0].z ? 1 : (data[2].z > data[0].z ? -1 : 0)) +
            (data[2].z < data[1].z ? 1 : (data[2].z > data[1].z ? -1 : 0)) +
            (data[2].z < data[3].z ? 1 : (data[2].z > data[3].z ? -1 : 0))
        
        result[3].x =
            (data[3].x < data[0].x ? 1 : (data[3].x > data[0].x ? -1 : 0)) +
            (data[3].x < data[1].x ? 1 : (data[3].x > data[1].x ? -1 : 0)) +
            (data[3].x < data[2].x ? 1 : (data[3].x > data[2].x ? -1 : 0))
        result[3].y =
            (data[3].y < data[0].y ? 1 : (data[3].y > data[0].y ? -1 : 0)) +
            (data[3].y < data[1].y ? 1 : (data[3].y > data[1].y ? -1 : 0)) +
            (data[3].y < data[2].y ? 1 : (data[3].y > data[2].y ? -1 : 0))
        result[3].z =
            (data[3].z < data[0].z ? 1 : (data[3].z > data[0].z ? -1 : 0)) +
            (data[3].z < data[1].z ? 1 : (data[3].z > data[1].z ? -1 : 0)) +
            (data[3].z < data[2].z ? 1 : (data[3].z > data[2].z ? -1 : 0))
        
        return result
    }
    
    @inlinable func applyVelocities(_ v: [Point3D]) {
        data[0].x += v[0].x
        data[0].y += v[0].y
        data[0].z += v[0].z
        
        data[1].x += v[1].x
        data[1].y += v[1].y
        data[1].z += v[1].z
        
        data[2].x += v[2].x
        data[2].y += v[2].y
        data[2].z += v[2].z
        
        data[3].x += v[3].x
        data[3].y += v[3].y
        data[3].z += v[3].z
    }
    
    @inlinable func updateVelocities(_ v: [Point3D]) {
        velocities[0].x += v[0].x
        velocities[0].y += v[0].y
        velocities[0].z += v[0].z
        
        velocities[1].x += v[1].x
        velocities[1].y += v[1].y
        velocities[1].z += v[1].z
        
        velocities[2].x += v[2].x
        velocities[2].y += v[2].y
        velocities[2].z += v[2].z
        
        velocities[3].x += v[3].x
        velocities[3].y += v[3].y
        velocities[3].z += v[3].z
    }
    
    func step(_ steps: Int) throws -> [Point3D] {
        for _ in 0..<steps {
            try step()
        }
        
        return data
    }
    
    @inlinable func step() throws{
        let v = try self.spotVelocities()
        updateVelocities(v)
        applyVelocities(velocities)
    }
    
    static func stepsToRepeat(gravity: GravitySystem) throws -> Int {
        //var seen = Set<Int>()
//        seen.insert(gravity.description.hashValue) // only insert first item
        let initial = gravity.description.hashValue
        try gravity.step()
        var steps = 1
        while true {
            let state = gravity.description.hashValue
            if initial == state {
                return steps
            }
            //seen.insert(state)
            try gravity.step()
            steps += 1
        }
    }
    
    func totalEnergy() -> Int {
        var total = 0
        for a in 0..<data.count {
            let pot = (abs(data[a].x) + abs(data[a].y) + abs(data[a].z))
            let kin = (abs(velocities[a].x) + abs(velocities[a].y) + abs(velocities[a].z))
            total += (pot * kin)
        }
        
        return total
    }
    
    
}
