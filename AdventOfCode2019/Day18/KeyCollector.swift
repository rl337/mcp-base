//
//  KeyCollector.swift
//  AdventOfCode2019
//
//  Created by Richard Lee on 12/18/19.
//  Copyright © 2019 Richard Lee. All rights reserved.
//

import Foundation

struct PathCacheKey : Hashable {
    var a: BitmapPoint
    var b: BitmapPoint
}

public class KeyCollector {
    var shortestPathCache: [PathCacheKey: [BitmapPoint]]
    let finder: SlimeMoldShortestPath
    let blockedKeys: [Int: [Int]]
    
    init(rawMap: String) throws {
        finder = try SlimeMoldShortestPath(rawMap, ["#".asCharacterInt(), ".".asCharacterInt()])
        shortestPathCache = [:]
        blockedKeys = [:]
    }

    func shortestPath(a: BitmapPoint, b: BitmapPoint, keys: [Int], allKeys: [Int]) throws -> [BitmapPoint]? {
        let pathKey = PathCacheKey(a: a, b: b)
        var cachedPath = shortestPathCache[pathKey]
        if cachedPath == nil {
            cachedPath = finder.shortestPath(a, b, walls: ["#".asCharacterInt()])
            shortestPathCache[pathKey] = cachedPath
        }
        
        guard let path = cachedPath else {
            return nil
        }
                    
        let remainingKeys = allKeys.filter { !keys.contains($0) }
        let remainingDoors = remainingKeys.map { doorForKey(key: $0) }
        
        let blockingDoors = finder.items.filter{ remainingDoors.contains($0.key) && path.contains($0.value) }
        if blockingDoors.count > 0 {
            return nil
        }
        
        return path
    }

    func doorForKey(key: Int) -> Int {
        let keyOffset = key - "a".asCharacterInt()
        return "A".asCharacterInt() + keyOffset
    }
    
    func collectAllKeys() throws -> (distance: Int, order: [Int])? {
        let allKeys = finder.items.filter {
            $0.key >= "a".asCharacterInt() &&
            $0.key <= "z".asCharacterInt()
        }
        let allKeyKeys = Array<Int>(allKeys.keys)
        
        var orders: [(distance: Int, order: [Int], location: BitmapPoint)] = []
        guard let location = finder.items["@".asCharacterInt()] else {
            throw KeyCollectorError.NoInitialStartLocation
        }
        
        for thisKey in allKeys {
            guard let pathToKey = try shortestPath(a: location, b: thisKey.value, keys: [thisKey.key], allKeys: allKeyKeys) else {
                continue
            }
            orders.append((distance: pathToKey.count - 1, order: [thisKey.key], location: thisKey.value))
        }
        
        var shortestOrder: [Int]?
        var shortestDistance: Int?
        
        while orders.count > 0 {
            var newPathsFound = 0
            let path = orders.removeFirst()
            let remainingKeys = allKeys.filter { !path.order.contains($0.key) }
            
            if remainingKeys.count < 1 { // This path has all of the keys
                return (distance: path.distance, order: path.order)
//                if shortestDistance == nil {
//                    shortestDistance = path.distance
//                    shortestOrder = path.order
//                } else {
//                    if path.distance < shortestDistance! {
//                        shortestDistance = path.distance
//                        shortestOrder = path.order
//                    }
//                }
//                continue
            }
            
            for thisKey in remainingKeys {
                var haveKeys = path.order
                haveKeys.append(thisKey.key)
                guard let pathToKey = try shortestPath(a: path.location, b: thisKey.value, keys: haveKeys, allKeys: allKeyKeys) else {
                    continue
                }
                newPathsFound += 1
                var newOrder = path.order
                newOrder.append(thisKey.key)
                orders.append((distance: path.distance + pathToKey.count - 1, order: newOrder, location: thisKey.value))
            }
            
            if newPathsFound < 1 {
                throw KeyCollectorError.NoValidPathToRemainingKeys
            }
        }

        if shortestDistance == nil {
            return nil
        }
        return (shortestDistance!, shortestOrder!)
    }
    
    enum KeyCollectorError : Error {
        case NoInitialStartLocation, KeyLocationCannotBeFound, NoValidPathToRemainingKeys
    }
}
