//
//  AsteroidField.swift
//  AdventOfCode2019
//
//  Created by Richard Lee on 12/9/19.
//  Copyright © 2019 Richard Lee. All rights reserved.
//

import Foundation

class AsteroidField {
    let data: String
    let width: Int
    let height: Int
    init(data: String) {
        self.data = data
        let lines = data.components(separatedBy: "\n")
        self.width = lines[0].count
        self.height = lines.count
    }
    
    func isAsteroid(x: Int, y: Int) throws -> Bool {
        guard x >= 0, x < width, y >= 0, y < height else {
            throw AsteroidFieldError.CoordinateOutsideOfAstroidField
        }
        let item = data[data.index(data.startIndex, offsetBy: y * (width + 1) + x)]
        return item == "#"
    }
    
    func hasDirectLineOfSight(x1: Int, y1: Int, x2: Int, y2: Int) throws -> Bool {
        if x1 == x2 && y1 == y2 {
            return false
        }
        
        var dx = x2 - x1
        var dy = y2 - y1
        if dx == 0 {
            dy = dy < 0 ? -1 : 1
        } else if dy == 0 {
            dx = dx < 0 ? -1 : 1
        } else {
            guard let scale = gcf(a: abs(dx), b: abs(dy)) else {
                return true
            }
            dx = dx / scale
            dy = dy / scale
        }
        
        var xp = x1 + dx
        var yp = y1 + dy
        while (xp != x2 || yp != y2) {
            if try isAsteroid(x: xp, y: yp) {
                return false
            }
            xp += dx
            yp += dy
        }
        
        return true
    }
    
    func countVisibleAsteroids(x: Int, y: Int) throws -> Int? {
        guard try isAsteroid(x: x, y: y) else {
            return nil
        }
        
        var visible = 0
        for ny in 0..<height {
            for nx in 0..<width {
                if try isAsteroid(x: nx, y: ny) {
                    if try hasDirectLineOfSight(x1: x, y1: y, x2: nx, y2: ny) {
                        visible += 1
                    }
                }
            }
        }
        
        return visible
    }
    
    func findBestCountForStation() throws -> Int? {
        var maxCount = 0
        for ny in 0..<height {
            for nx in 0..<width {
                if try isAsteroid(x: nx, y: ny) {
                    guard let count = try countVisibleAsteroids(x: nx, y: ny) else {
                        continue
                    }
                    if count > maxCount {
                        maxCount = count
                    }
                }
            }
        }
        
        return maxCount
    }
    
    
    func gcf(a: Int, b: Int) -> Int? {
        if a == 0 || b == 0 {
            return nil
        }
        
        let af = factorize(n: abs(a))
        let bf = factorize(n: abs(b))
        
        let cf = af.intersection(bf)
        guard let max = cf.max() else {
            return nil
        }
        return max
    }
    
    func factorize(n: Int) -> Set<Int> {
        var result: [Int] = []
        
        var i = 1
        while i <= n {
            if n % i == 0 {
                result.append(i)
            }
            i += 1
        }
        
        return Set(result)
    }
 
    enum AsteroidFieldError: Error {
        case CoordinateOutsideOfAstroidField
        
    }
}
