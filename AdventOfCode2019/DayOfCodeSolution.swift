//
//  DayOfCodeSolution.swift
//  AdventOfCode2019
//
//  Created by Richard Lee on 12/1/19.
//  Copyright © 2019 Richard Lee. All rights reserved.
//

import Foundation

public struct UIEntry {
    public var id: Int
    public var label: String?
    public var message: String
    public var isError: Bool

    init(withId id: Int, thatDisplays message: String, labeledWith label: String? = nil, isError: Bool = false) {
        self.id = id
        self.message = message
        self.label = label
        self.isError = isError
    }
}

public class DayOfCodeSolution {
    public func execute() -> [UIEntry] {
        return [
            UIEntry(withId: 0, thatDisplays: "This is the Prototype Day of Code")
        ]
    }
    
    func getFileFromProject(named name: String) -> URL {
        let bundlePath = Bundle.main.resourceURL!
        return bundlePath.appendingPathComponent(name)
    }
    
    func getEntryForFunction(_ id: Int, method: () throws -> Int, labeledWith label: String) -> UIEntry {
        do {
            let result = try method()
            return UIEntry(
                withId: id,
                thatDisplays: String(result),
                labeledWith: label
            )
        } catch {
            return UIEntry(
                withId: id,
                thatDisplays: "\(error)",
                labeledWith: label,
                isError: true
            )
        }
    }
    
    func getEntryForStringFunction(_ id: Int, method: () throws -> String, labeledWith label: String) -> UIEntry {
        do {
            let result = try method()
            return UIEntry(
                withId: id,
                thatDisplays: result,
                labeledWith: label
            )
        } catch {
            return UIEntry(
                withId: id,
                thatDisplays: "\(error)",
                labeledWith: label,
                isError: true
            )
        }
    }
    
    func getListForFunction(_ id: Int, method: () throws -> [Int], labeledWith label: String) -> [UIEntry] {
        do {
            let results = try method()
            var resultList: [UIEntry] = [UIEntry(
                withId: id,
                thatDisplays: "Output",
                labeledWith: "#"
            )]
            var i = 1
            for result in results {
                resultList.append(UIEntry(
                    withId: id + i,
                    thatDisplays: String(result),
                    labeledWith: String(i)
                ))
                i += 1
            }
            return resultList
        } catch {
            return [UIEntry(
                withId: id,
                thatDisplays: "\(error)",
                labeledWith: label,
                isError: true
            )]
        }
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
                    DayTwoSolution(),
                    DayThreeSolution(),
                    DayFourSolution(),
                    DayFiveSolution(),
                    DaySixSolution(),
                    DaySevenSolution(),
                    DayEightSolution(),
                    DayNineSolution(),
                ]
            )
            return instance!
        }
    }
    
    var solutions: [DayOfCodeSolution]
    var current: Int
    
    public init(for solutions: [DayOfCodeSolution]) {
        self.solutions = solutions
        self.current = solutions.count - 1
    }
    
    public func select(index i: Int) {
        current = i
    }
    
    public func execute() -> [UIEntry] {
        return solutions[current].execute()
    }
}

