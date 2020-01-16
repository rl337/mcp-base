//
//  ShortestPath.swift
//  AdventOfCode2019
//
//  Created by Richard Lee on 1/13/20.
//  Copyright © 2020 Richard Lee. All rights reserved.
//

import Foundation

protocol HashableComparable: Hashable, Comparable {
    
}

extension String : HashableComparable {
    
}

class PathComponent<T: HashableComparable> {
    var weight: Int
    var value: T
    
    init(of value: T, withWeight weight: Int) {
        self.weight = weight
        self.value = value
    }
}

class Path<T: HashableComparable> {
    var components: [PathComponent<T>]
    
    init() {
        self.components = Array()
    }
    
    convenience init(_ value: PathComponent<T>) {
        self.init()
        self.components.append(value)
    }
    
    convenience init(_ parent: Path<T>, _ value: PathComponent<T>) {
        self.init()
        
        self.components.append(contentsOf: parent.components)
        self.components.append(value)
    }
    
    var weight: Int {
        get {
            self.components.reduce(0) { $0 + $1.weight }
        }
    }
    
    var count: Int {
        get {
            self.components.count
        }
    }
    
    var last: PathComponent<T>? {
        get {
            self.components.last
        }
    }
}

protocol PathProvider {
    associatedtype ComponentType: HashableComparable
    func listCandidates(forPath path: Path<ComponentType>) -> [Path<ComponentType>]
}

class PathFinder<ProviderType: PathProvider> {
    var provider: ProviderType
    
    init(provider: ProviderType) {
        self.provider = provider
    }
    
    func shortestPath(from a: ProviderType.ComponentType, to b: ProviderType.ComponentType) throws -> Path<ProviderType.ComponentType>? {
        let heap: BinaryHeap<Path<ProviderType.ComponentType>> = BinaryHeap { $0.weight > $1.weight }
        try heap.enqueue(Path(PathComponent(of: a, withWeight: 0)))
        while heap.count > 0 {
            let shortest = try heap.dequeue()
            for candidate in provider.listCandidates(forPath: shortest) {
                guard let last = candidate.last else {
                    continue
                }
                
                if last.value == b {
                    return candidate
                }
                
                try heap.enqueue(candidate)
            }
        }
        
        return nil
    }
    
}
