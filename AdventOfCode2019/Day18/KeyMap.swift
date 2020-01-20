//
//  KeyMap.swift
//  AdventOfCode2019
//
//  Created by Richard Lee on 1/17/20.
//  Copyright © 2020 Richard Lee. All rights reserved.
//

import Foundation

struct ItemPair : Hashable {
    var a: Int
    var b: Int
}

class KeyMap {
    var map: SparseBitmap
    var items: [Int:BitmapPoint]
    var walls: [Int]
    
    init() {
        map = SparseBitmap()
        self.items = [:]
        self.walls = []
    }
    
    convenience init(_ rawMap: String, _ notItems: [Int] = [".".asCharacterInt()], _ walls: [Int] = ["#".asCharacterInt()]) throws {
        self.init()
        self.walls = walls
        
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
                
                if walls.firstIndex(of: chInt) != nil {
                    continue
                }
                
                if self.items.keys.contains(chInt) {
                    throw KeyMapError.DuplicateItemFound
                }
                self.items[chInt] = coord
            }
            x = 0
            y += 1
        }
    }
    
    func isTraversable(p: BitmapPoint?) -> Bool {
        guard let p = p else {
            return false
        }
        
        let value = map.points[p]
        let result = walls.first { $0 == value }
        
        return result == nil
    }
    
    func getItemDistanceMap() -> [ItemPair: BitmapPointPath] {
        var itemDistanceMap: [ItemPair: BitmapPointPath] = [:]
        let itemsToCompute = self.items.filter {
            let char = $0.key.asCharacter()
            if !char.isLowercase && char != "@" {
                return false
            }
            return true
        }
        
        for itemData in itemsToCompute {
            var itemsToFind = itemsToCompute.filter({
                if itemData.key == $0.key {
                    return false
                }
                
                let itemKeys = [itemData.key, $0.key].sorted()
                return !itemDistanceMap.contains(where: {$0.key == ItemPair(a: itemKeys[0], b: itemKeys[1])})
            })
            
            var paths: [BitmapPointPath] = [BitmapPointPath(path: [itemData.value])]
            var states: [[BitmapPoint]:Int] = [:]
            while itemsToFind.count > 0 && paths.count > 0 {
                let path = paths.removeFirst()
                guard let last = path.last else {
                    continue
                }
                
                for direction in [ last.north, last.south, last.east, last.west] {
                    if path.contains(direction) {
                        continue
                    }
                    
                    if isTraversable(p: direction) {
                        var newPath = path
                        newPath.append(direction)
                        
                        let state = [newPath.path.first!, newPath.last!]
                        let prevState = states[state]
                        if prevState == nil || prevState! > state.count {
                            states[state] = state.count
                            paths.append(newPath)
                        }
                    }
                    
                    guard let itemFound = itemsToFind.first(where: {$0.value == direction}) else {
                        continue
                    }
                    
                    itemsToFind.removeValue(forKey: itemFound.key)
                    let itemKeys = [itemData.key, itemFound.key].sorted()
                    itemDistanceMap[ItemPair(a: itemKeys[0], b: itemKeys[1])] = path
                }
            }
        }
        
        return itemDistanceMap
    }

    enum KeyMapError : Error {
        case DuplicateItemFound
    }
}

struct BitmapPointPath {
    var path: [BitmapPoint]
    
    init(path: [BitmapPoint]) {
        self.path = path
    }
    
    var last: BitmapPoint? {
        return path.last
    }
    
    func contains(_ p: BitmapPoint) -> Bool {
        return path.contains(p)
    }
    
    mutating func append(_ p: BitmapPoint) {
        return path.append(p)
    }
}

extension BitmapPointPath : Comparable {
    static func < (lhs: BitmapPointPath, rhs: BitmapPointPath) -> Bool {
        if lhs.path.count < rhs.path.count {
            return true
        }

        if lhs.path.count == rhs.path.count {
            for i in 0 ..< lhs.path.count {
                if lhs.path[i] < rhs.path[i] {
                    return true
                }
                
                if lhs.path[i] > rhs.path[i] {
                    return false
                }
            }
        }

        return false
    }

    static func == (lhs: BitmapPointPath, rhs: BitmapPointPath) -> Bool {
        lhs.path == rhs.path
    }
}

//class GridPointPathProvider : PathProvider {
//    typealias ComponentType = GridPointPath
//
//    func listCandidates(forPath path: Path<GridPointPath>) -> [Path<GridPointPath>] {
//    }
//
//}
