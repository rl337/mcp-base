//
//  DayOfCodeSolution.swift
//  AdventOfCode2019
//
//  Created by Richard Lee on 12/1/19.
//  Copyright © 2019 Richard Lee. All rights reserved.
//

import Foundation

public struct UIEntry {
    var label: String?
    var message: String
    var isError: Bool

    init(thatDisplays message: String, labeledWith label: String? = nil, isError: Bool = false) {
        self.message = message
        self.label = label
        self.isError = isError
    }
}

public class DayOfCodeSolution {
    public func execute() -> [UIEntry] {
        return [
            UIEntry(thatDisplays: "This is the Prototype Day of Code")
        ]
    }
    
    func getFileFromProject(named name: String) -> URL {
        let bundlePath = Bundle.main.resourceURL!
        return bundlePath.appendingPathComponent(name)
    }
}

public class SolutionController {
    private static var instance: SolutionController?
    
    public static func getInstance() -> SolutionController {
        if let exists = instance {
            return exists
        } else {
            instance = SolutionController(
                for: [
                    DayOneSolution(),
                ]
            )
            return instance!
        }
    }
    
    var solutions: [DayOfCodeSolution]
    var current: Int
    
    public init(for solutions: [DayOfCodeSolution]) {
        self.solutions = solutions
        self.current = 0
    }
    
    public func select(index i: Int) {
        current = i
    }
    
    public func execute() -> [UIEntry] {
        return solutions[current].execute()
    }
}

