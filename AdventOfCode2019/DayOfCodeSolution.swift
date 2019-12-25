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
    public var isMonospaced: Bool
    public var size: Float

    init(withId id: Int, thatDisplays message: String, labeledWith label: String? = nil, isError: Bool = false, isMonospaced: Bool = false, size: Float=16.0) {
        self.id = id
        self.message = message
        self.label = label
        self.isError = isError
        self.isMonospaced = isMonospaced
        self.size = size
    }
}

public struct BitmapPoint: Hashable {
    var x: Int
    var y: Int
    
    init(_ x: Int, _ y: Int) {
        self.x = x
        self.y = y
    }
    
    var north: BitmapPoint {
        BitmapPoint(self.x, self.y-1)
    }
    
    var south: BitmapPoint {
        BitmapPoint(self.x, self.y+1)
    }
    
    var east: BitmapPoint {
        BitmapPoint(self.x-1, self.y)
    }
    
    var west: BitmapPoint {
        BitmapPoint(self.x+1, self.y)
    }
}

public struct SparseBitmap {
    var points: [BitmapPoint: Int]
    
    var minX: Int? {
        get {
            let min = self.points.min { $0.key.x < $1.key.x }
            return min?.key.x
        }
    }
    
    var maxX: Int? {
        get {
            let max = self.points.max { $0.key.x < $1.key.x }
            return max?.key.x
        }
    }
    
    var minY: Int? {
        get {
            let min = self.points.min { $0.key.y < $1.key.y }
            return min?.key.y
        }
    }
    
    var maxY: Int? {
        get {
            let max = self.points.max { $0.key.y < $1.key.y }
            return max?.key.y
        }
    }
    
    init(_ points: [BitmapPoint: Int] = [:]) {
        self.points = [:]
        for point in points {
            self.points[point.key] = point.value
        }
    }
    
    func northValue(_ point: BitmapPoint) -> Int? {
        return self.points[point.north]
    }
    
    func southValue(_ point: BitmapPoint) -> Int? {
        return self.points[point.south]
    }
    
    func eastValue(_ point: BitmapPoint) -> Int? {
        return self.points[point.east]
    }
    
    func westValue(_ point: BitmapPoint) -> Int? {
        return self.points[point.west]
    }
    
    func asBitmap(mapping: [Int?:Character]) -> String {
        guard
            self.points.count > 0,
            let minX = self.minX,
            let maxX = self.maxX,
            let minY = self.minY,
            let maxY = self.maxY else {
            return ""
        }
        
        let width = maxX - minX
        var result: String = "\n"
        for y in minY...maxY {
            var row: [Character] = Array(repeating: "#", count: width+1)
            for x in 0...width {
                row[x] = mapping[self.points[BitmapPoint(x + minX, minY + y)]] ?? "?"
            }
            result.append(contentsOf: String(row))
            result.append(contentsOf: String("\n"))
        }
        return result.trim()
    }
}

extension UIEntry: Identifiable {
    
}

public class DayOfCodeSolution {
    
    public func heading() -> [UIEntry] {
        return [
            UIEntry(withId: 0, thatDisplays: "This is the Prototype Day of Code")
        ]
    }
    
    public func execute() -> [UIEntry] {
        return [
            UIEntry(withId: 0, thatDisplays: "This is the result of prototype")
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
    
    func getEntryForStringFunction(_ id: Int, method: () throws -> String, labeledWith label: String, monospaced: Bool = false, size: Float = 9) -> UIEntry {
        do {
            let result = try method()
            return UIEntry(
                withId: id,
                thatDisplays: result,
                labeledWith: label,
                isMonospaced: monospaced,
                size: size
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
    
    func getListForFunction(_ id: Int, method: () throws -> [Int], labeledWith label: String, monospaced: Bool = false) -> [UIEntry] {
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
                    labeledWith: String(i),
                    isMonospaced: monospaced
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
                    DayTenSolution(),
                    DayElevenSolution(),
                    DayTwelveSolution(),
                    DayFourteenSolution(),
                    DayFifteenSolution(),
                    DaySixteenSolution(),
                    DaySeventeenSolution(),
                    DayNineteenSolution(),
                    DayTwentyOneSolution(),
                    DayTwentyTwoSolution(),
                    DayTwentyThreeSolution(),
                    DayTwentyFourSolution(),
                    DayThirteenSolution(),
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
    
    public func hasPrev() -> Bool {
        return current > 0
    }
    
    public func hasNext() -> Bool {
        return current < (solutions.count - 1)
    }
    
    public func selectPrev() {
        if hasPrev() {
            current-=1
        }
    }
    
    public func selectNext() {
        if hasNext() {
            current+=1
        }
    }
    
    public func execute() -> [UIEntry] {
        return solutions[current].execute()
    }
    
    public func heading() -> [UIEntry] {
        return solutions[current].heading()
    }
}

