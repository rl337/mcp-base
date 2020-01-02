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
    let part1Solution: String?
    let part2Solution: String?
    
    init(part1: String? = nil, part2: String? = nil) {
        self.part1Solution = part1
        self.part2Solution = part2
    }
    
    convenience init(part1: Int, part2: Int) {
        self.init(part1: String(part1), part2: String(part2))
    }
    
    convenience init(part1: Int) {
        self.init(part1: String(part1), part2: nil)
    }
    
    convenience init(part1: Int, part2: Int? = nil) {
        self.init(part1: String(part1), part2: part2 == nil ? nil: String(part2!))
    }
    
    convenience init(part1: Int, part2: String) {
        self.init(part1: String(part1), part2: part2)
    }
    
    public func heading() -> [UIEntry] {
        return [
            UIEntry(withId: 0, thatDisplays: "This is the Prototype Day of Code")
        ]
    }
    
    func fullHeading() -> [UIEntry] {
        var headings: [UIEntry] = []
        headings.append(contentsOf: self.heading())
        if self.part1Solution != nil {
            headings.append(
                self.getEntryForConfirmedAnswer(
                    Int.max,
                    value: self.part1Solution!,
                    labeledWith: "Part 1 Solution"
                )
            )
        }
        
        if self.part2Solution != nil {
            headings.append(
                self.getEntryForConfirmedAnswer(
                    Int.max - 1,
                    value: self.part2Solution!,
                    labeledWith: "Part 2 Solution"
                )
            )
        }
        
        return headings
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
    
    func getEntryForConfirmedAnswer(_ id: Int, value: String, labeledWith label: String) -> UIEntry {
        return UIEntry(
            withId: id,
            thatDisplays: value,
            labeledWith: label
        )
        
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
    
    func getListForStringFunction(_ id: Int, method: () throws -> [String], labeledWith label: String, monospaced: Bool = false, size: Float = 9, reverse: Bool = false) -> [UIEntry] {
        do {
            var results = try method()
            if reverse {
                results.reverse()
            }
            var resultList: [UIEntry] = [UIEntry(
                withId: id,
                thatDisplays: "Output",
                labeledWith: "#"
            )]
            
            if reverse {
                var i = results.count
                for result in results {
                    resultList.append(UIEntry(
                        withId: id + i,
                        thatDisplays: result,
                        labeledWith: String(i),
                        isMonospaced: monospaced
                    ))
                    i -= 1
                }
            } else {
                var i = 1
                for result in results {
                    resultList.append(UIEntry(
                        withId: id + i,
                        thatDisplays: result,
                        labeledWith: String(i),
                        isMonospaced: monospaced
                    ))
                    i += 1
                }
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
                    DayOneSolution(part1: 3336439, part2: 5001791),
                    DayTwoSolution(part1: 4138658, part2: 7264),
                    DayThreeSolution(part1: 1674, part2: 14012),
                    DayFourSolution(part1: 2814, part2: 1991),
                    DayFiveSolution(part1: 5346030, part2: 513116),
                    DaySixSolution(part1: 147223, part2: 340),
                    DaySevenSolution(part1: 43210, part2: 25534964),
                    DayEightSolution(part1: 2193, part2: "YEHEF"),
                    DayNineSolution(part1: 4234906522, part2: 60962),
                    DayTenSolution(part1: 227, part2: 604),
                    DayElevenSolution(part1: 2428, part2: "RJLFBUCU"),
                    DayTwelveSolution(part1: 9139, part2: nil),
                    DayThirteenSolution(part1: 414, part2: 20183),
                    DayFourteenSolution(part1: 873899, part2: 1893569),
                    DayFifteenSolution(part1: 230, part2: 288),
                    DaySixteenSolution(part1: 53296082, part2: nil),
                    DaySeventeenSolution(part1: 4688, part2: nil),
                    DayNineteenSolution(part1: 158, part2: nil),
                    DayTwentyOneSolution(part1: 19360724, part2: nil),
                    DayTwentyTwoSolution(part1: 2514, part2: nil),
                    DayTwentyThreeSolution(part1: 23626, part2: 19019),
                    DayTwentyFourSolution(part1: 32776479, part2: nil),
                    DayTwentyFiveSolution(part1: 1090617344, part2: nil),
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
        return solutions[current].fullHeading()
    }
        
}

