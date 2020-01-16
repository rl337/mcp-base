//
//  ShortestPathTests.swift
//  AdventOfCode2019Tests
//
//  Created by Richard Lee on 1/13/20.
//  Copyright © 2020 Richard Lee. All rights reserved.
//

import Foundation

import XCTest
@testable import AdventOfCode2019

class TestGraphPathProvider: PathProvider {
    typealias ComponentType = String
    var graph: [String: [(String, Int)]]
    
    init(_ graph: [String: [(String, Int)]]) {
        self.graph = graph
    }
    
    func listCandidates(forPath path: Path<ComponentType>) -> [Path<ComponentType>] {
        guard let lastValue = path.last?.value else {
            return []
        }
        
        guard let candidateTuples = graph[lastValue] else {
            return []
        }
        let filterList: [String] = path.components.map({$0.value})
        
        let filteredCandidates = candidateTuples.filter({!filterList.contains($0.0)})
        if filteredCandidates.count < 1 {
            return []
        }
        
        return filteredCandidates.map({ Path<ComponentType>(path, PathComponent<ComponentType>(of: $0.0, withWeight: $0.1))})
    }
    
}

class ShortestPathTests: XCTestCase {
    
    func testWikipediaScenario() throws {
        let provider = TestGraphPathProvider([
            "1": [("2", 7), ("3", 9), ("6", 14)],
            "2": [("1", 7), ("3", 10), ("4", 15)],
            "3": [("1", 9), ("2", 10), ("4", 11), ("6", 2)],
            "4": [("2", 15), ("3", 11), ("5", 6)],
            "5": [("4", 6), ("6", 9)],
            "6": [("1", 14), ("3", 2), ("5", 9)]
        ])
        
        let finder = PathFinder(provider: provider)
        guard let path = try finder.shortestPath(from: "1", to: "5") else {
            XCTFail("Expected a possible path between 1 and 5")
            return
        }
        XCTAssertEqual(4, path.count)
        XCTAssertEqual("1", path.components[0].value)
        XCTAssertEqual("3", path.components[1].value)
        XCTAssertEqual("6", path.components[2].value)
        XCTAssertEqual("5", path.components[3].value)
    }

}
