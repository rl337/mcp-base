//
//  SlimeMoldShortestPath.swift
//  AdventOfCode2019
//
//  Created by Richard Lee on 12/17/19.
//  Copyright © 2019 Richard Lee. All rights reserved.
//

import Foundation

class SlimeMoldShortestPath {
    var map: SparseBitmap
    var items: [Int:BitmapPoint]
    
    init() {
        map = SparseBitmap()
        self.items = [:]
    }
    
    convenience init(_ rawMap: String, _ notItems: [Int] = []) throws {
        self.init()
        var x: Int = 0
        var y: Int = 0
        for line in rawMap.components(separatedBy: "\n") {
            for ch in Array<Character>(line) {
                let coord = BitmapPoint(x, y)
                let chInt = ch.asInt()
                map.points[coord] = chInt
                x += 1
                if notItems.firstIndex(of: chInt) != nil {
                    continue
                }
                
                if self.items.keys.contains(chInt) {
                    throw SlimeMoldShortestPathError.DuplicateItemFound
                }
                self.items[chInt] = coord
            }
            x = 0
            y += 1
        }
    }
    
    func isTraversable(p: BitmapPoint?, walls: [Int]) -> Bool {
        guard let p = p else {
            return false
        }
        
        let value = map.points[p]
        let result = walls.first { $0 == value }
        
        return result == nil
    }
    
    func shortestPath(_ a: BitmapPoint, _ b: BitmapPoint, walls: [Int] = [Character("#").asInt()]) -> [BitmapPoint]? {
        
        if a == b {
            return []
        }
        
        var paths: [[BitmapPoint]] = [[a]]
        while paths.count > 0 {
            let path = paths.removeFirst()
            guard let last = path.last else {
                continue
            }
            
            if last == b {
                return path
            }
            
            for direction in [ last.north, last.south, last.east, last.west] {
                if path.contains(direction) {
                    continue
                }
                
                if isTraversable(p: direction, walls: walls) {
                    var newPath = path
                    newPath.append(direction)
                    paths.append(newPath)
                }
            }
        }
        return nil
    }
    
    enum SlimeMoldShortestPathError : Error {
        case DuplicateItemFound
    }
}
