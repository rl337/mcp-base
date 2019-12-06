//
//  OrbitalMap.swift
//  AdventOfCode2019
//
//  Created by Richard Lee on 12/5/19.
//  Copyright © 2019 Richard Lee. All rights reserved.
//

import Foundation

class Node {
    var name: String
    var children: [Node]
    
    init(named name: String, withChildren children: [Node] = []) {
        self.name = name
        self.children = []
        self.children.append(contentsOf: children)
    }
    
    func find(named name: String) -> Node? {
        if name == self.name {
            return self
        }
        
        guard children.count > 0 else {
            return nil
        }
        
        for child in self.children {
            let candidate = child.find(named: name)
            if candidate != nil {
                return candidate
            }
        }
        
        return nil
    }
    
    func add(named name: String) throws -> Node {
        let node = find(named: name)
        if node != nil {
            throw NodeError.NameAlreadyExistsInSubtree
        }
        
        let result = Node(named: name)
        children.append(result)
        return result
    }
    
    func addNode(_ node: Node) {
        children.append(node)
    }
    
    func listNodePaths(_ path: [String] = []) -> [[String]] {
        var result: [[String]] = []
        
        var myPath = path
        myPath.append(name)
        result.append(myPath)

        if children.count < 1 {
            return result
        }
        
        for child in children {
            for childPath in child.listNodePaths(myPath) {
                result.append(childPath)
            }
        }
        return result
    }
    
    func sumOfDepths() -> Int {
        let allPaths = listNodePaths()
        var total = 0
        for path in allPaths {
            total += (path.count-1)
        }
        
        return total
    }
    
    func findMinimumOrbitalTransfers(a: String, b: String) throws -> Int {
        let nodePaths = listNodePaths()
        var aPath: [String]?
        var bPath: [String]?
        for nodePath in nodePaths {
            guard let last = nodePath.last else {
                continue
            }
            
            if last == a {
                aPath = nodePath
            }
            if last == b {
                bPath = nodePath
            }
        }
        
        guard aPath != nil, bPath != nil else {
            throw NodeError.NodeNotFoundInNodePaths
        }

        while aPath!.count > 0 && bPath!.count > 0 {
            if aPath![0] != bPath![0] {
                break
            }
            _ = aPath!.removeFirst()
            _ = bPath!.removeFirst()
        }
        
        return aPath!.count + bPath!.count - 2
    }
    
    enum NodeError : Error {
        case NameAlreadyExistsInSubtree
        case NodeNotFoundInNodePaths
    }
}

class OrbitalMap {
    var com: Node
    
    init(_ content: String) throws {
        com = Node(named: "COM")
        var trimmed = content
        guard trimmed.count > 0 else {
            return
        }
        if trimmed.last! == "\n" {
            trimmed.removeLast()
        }
        let parts = trimmed.components(separatedBy: "\n")
        var toAdd: [String:Node] = ["COM": com]
        for part in parts {
            let names = part.components(separatedBy: ")")
            guard names.count == 2 else {
                throw OrbitalMapError.OrbitalMapEntryMustHaveTwoParts
            }
            
            var parent = toAdd[names[0]]
            if parent == nil {
                parent = Node(named: names[0])
                toAdd[names[0]] = parent
            }
            
            var child = toAdd[names[1]]
            if child == nil {
                child = Node(named: names[1])
                toAdd[names[1]] = child
            }
            
            parent!.addNode(child!)
        }
        
//        var attempts = 0
//        while toAdd.count > 0 && attempts <= toAdd.count {
//            attempts += 1
//            let next = toAdd.removeFirst()
//            let candidate = com.find(named: next[0])
//            guard let parent = candidate else {
//                toAdd.append(next)
//                continue
//            }
//            
//            _ = try parent.add(named: next[1])
//            attempts = 0
//        }
    }
    
    enum OrbitalMapError: Error {
        case OrbitalMapEntryMustHaveTwoParts, DisjointOrbitalMapInput
    }
}
