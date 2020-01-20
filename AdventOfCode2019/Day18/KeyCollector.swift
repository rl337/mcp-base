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
    let finder: KeyMap
    let blockedKeys: [Int: [Int]]
    
    init(rawMap: String) throws {
        finder = try KeyMap(rawMap, [".".asCharacterInt()], ["#".asCharacterInt()])
        blockedKeys = [:]
    }

    func doorForKey(key: Int) -> Int {
        let keyOffset = key - "a".asCharacterInt()
        return "A".asCharacterInt() + keyOffset
    }
    
    func collectAllKeys() throws -> (distance: Int, order: [Int]) {
        let allKeys = finder.items.filter {
            $0.key >= "a".asCharacterInt() &&
            $0.key <= "z".asCharacterInt()
        }
        let keyPaths = finder.getItemDistanceMap()

        let neededKeys = finder.items.filter {
            $0.key >= "A".asCharacterInt() &&
            $0.key <= "Z".asCharacterInt()
        }.map { door in
            Dictionary.Element(String(door.key.asCharacter()).lowercased().asCharacterInt(), door.value)
        }
        var neededKeysForPath: [ItemPair: [Int]] = [:]
        for item in keyPaths {
            guard let pathToKey = keyPaths[item.key] else {
                continue
            }
            let needsKeys = neededKeys.filter { pathToKey.contains($0.value)}
            neededKeysForPath[item.key] = needsKeys.map({ $0.key })
        }
        
        let orders: BinaryHeap<(distance: Int, order: [Int], location: BitmapPoint)> = BinaryHeap { a, b in a.distance > b.distance
        }
        
        let startingItem = "@".asCharacterInt()
        let startingPoint = finder.items[startingItem]!
        var states: [[Int]: Int] = [:]
        try orders.enqueue((distance: 0, order: [startingItem], location: startingPoint))
        
        while orders.count > 0 {
            let path = try orders.dequeue()
            let remainingKeys = allKeys.filter { !path.order.contains($0.key) }
            
            if remainingKeys.count < 1 { // This path has all of the keys
                return (distance: path.distance, order: path.order)
            }
            
            for thisKey in remainingKeys {
                let keypair = [thisKey.key, path.order.last!].sorted()
                let itemPair = ItemPair(a:keypair[0], b: keypair[1])
                guard let pathToKey = keyPaths[itemPair] else {
                    continue
                }
                
                // needsKeys are any keys necessary to traverse path
                let haveKeys = path.order
                let needsKeys = neededKeysForPath[itemPair]!
                let unmetKeys = needsKeys.filter { thisKey in !haveKeys.contains(thisKey) }
                if unmetKeys.count > 0 {
                    // We couldn't pass because we don't yet have the key
                    continue
                }
                
                var newOrder = path.order
                newOrder.append(thisKey.key)
                let candidate = (distance: path.distance + pathToKey.path.count, order: newOrder, location: thisKey.value)

                let state = candidate.order.sorted() + [ candidate.order.last! ]
                let prevStateDistance = states[state]
                if prevStateDistance == nil || prevStateDistance! > candidate.distance {
                    states[state] = candidate.distance
                    try orders.enqueue(candidate)
                }
            }
        }
        
        throw KeyCollectorError.NoValidPathToRemainingKeys
    }
    
    enum KeyCollectorError : Error {
        case NoInitialStartLocation, KeyLocationCannotBeFound, NoValidPathToRemainingKeys
    }
}
