//
//  Day4Logic.swift
//  AdventOfCode2019
//
//  Created by Richard Lee on 12/3/19.
//  Copyright © 2019 Richard Lee. All rights reserved.
//

import Foundation

class DayFourSolution : DayOfCodeSolution {
    static let Part1RangeMin = 109165
    static let Part1RangeMax = 576723
    
    static func validateNumberPart1(n: Int, enforceRange: Bool = true) -> Bool {
        let nStr = String(n)
        if nStr.count != 6 { // Must be exactly 6 characters long
            return false
        }
        
        if enforceRange && (n > Part1RangeMax || n < Part1RangeMin) {
            return false // value must be in range
        }
        
        var hasRepeat = false
        for i in 1...5 {
            let prev = nStr[nStr.index(nStr.startIndex, offsetBy: i-1)]
            let curr = nStr[nStr.index(nStr.startIndex, offsetBy: i)]
            if curr < prev { // Digits never decrease in sequences
                return false
            }
            
            if prev == curr {
                hasRepeat = true
            }
        }
        
        if !hasRepeat {
            return false // we must have at least one repeat
        }
        
        return true
    }
    
    static func validateNumberPart2(n: Int, enforceRange: Bool = true) -> Bool {
        let nStr = String(n)
        if nStr.count != 6 { // Must be exactly 6 characters long
            return false
        }
        
        if enforceRange && (n > Part1RangeMax || n < Part1RangeMin) {
            return false // value must be in range
        }
        
        var hasRepeat = false
        var repeats = 0
        for i in 1..<nStr.count {
            let prev = nStr[nStr.index(nStr.startIndex, offsetBy: i-1)]
            let curr = nStr[nStr.index(nStr.startIndex, offsetBy: i)]
            if curr < prev { // Digits never decrease in sequences
                return false
            }
            
            if prev == curr {
                repeats += 1 // repeats match count - 1
                if i == nStr.count - 1 && repeats == 1{
                    hasRepeat = true
                }
            } else {
                if repeats == 1 {
                    hasRepeat = true
                }
                repeats = 0
            }
        }
        
        if !hasRepeat {
            return false // we must have at least one repeat
        }
        
        return true
    }
    
    
    func calculatePart1() throws -> Int {
        var valid = 0
        for i in DayFourSolution.Part1RangeMin...DayFourSolution.Part1RangeMax {
            if DayFourSolution.validateNumberPart1(n: i) {
                valid += 1
            }
        }
        
        return valid
    }
    
    func calculatePart2() throws -> Int {
        var valid = 0
        for i in DayFourSolution.Part1RangeMin...DayFourSolution.Part1RangeMax {
            if DayFourSolution.validateNumberPart2(n: i) {
                valid += 1
            }
        }
        
        return valid
    }
    
    public override func execute() -> [UIEntry] {
        let part1Entry = getEntryForFunction(method: calculatePart1, labeledWith: "Part 1")
        let part2Entry = getEntryForFunction(method: calculatePart2, labeledWith: "Part 2")
        
        return [
            UIEntry(thatDisplays: "Day 4 Solution"),
            part1Entry,
            part2Entry
        ]
    }

}
