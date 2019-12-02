//
//  DayOneLogic.swift
//  AdventOfCode2019
//
//  Created by Richard Lee on 11/30/19.
//  Copyright © 2019 Richard Lee. All rights reserved.
//

import Foundation


public class DayOneSolution : DayOfCodeSolution {

    public func calculateFuel(ofMass mass: Int) -> Int {
        return mass / 3 - 2
    }
    
    public func calculateFuelForIterator<T: Sequence>(data: T, calculateFuelForFuel: Bool) -> Int where T.Iterator.Element == Int {

        var sum = 0;
        for x in data {
            var xtotal = calculateFuel(ofMass: x)
            if calculateFuelForFuel {
                var fuelMass = calculateFuel(ofMass: xtotal)
                while fuelMass > 0 {
                    xtotal += fuelMass
                    fuelMass = calculateFuel(ofMass: fuelMass)
                }
            }
            
            sum = sum + xtotal
        }
        
        return sum
    }
    
    public func calculatePart1() throws -> Int {
        let day1InputFile = getFileFromProject(named: "Day1Input.txt")
        let i = try IntFileIterator(contentsOf: day1InputFile)
        return calculateFuelForIterator(
            data: i, calculateFuelForFuel: false)
    }
    
    public func calculatePart2() throws -> Int {
        let day1InputFile = getFileFromProject(named: "Day1Input.txt")
        let i = try IntFileIterator(contentsOf: day1InputFile)
        return calculateFuelForIterator(
            data: i, calculateFuelForFuel: true)
    }
    
    public override func execute() -> [UIEntry] {
        
        var day1Entry: UIEntry
        do {
            let day1Part1Result = try calculatePart1()
            day1Entry = UIEntry(
                thatDisplays: String(day1Part1Result),
                labeledWith: "Part 1"
            )
        } catch {
            day1Entry = UIEntry(
                thatDisplays: "\(error)",
                labeledWith: "Part 1",
                isError: true
            )
        }
        
        var day2Entry: UIEntry
        do {
            let day1Part1Result = try calculatePart2()
            day2Entry = UIEntry(
                thatDisplays: String(day1Part1Result),
                labeledWith: "Part 2"
            )
        } catch {
            day2Entry = UIEntry(
                thatDisplays: "\(error)",
                labeledWith: "Part 2",
                isError: true
            )
        }

        return [
            UIEntry(thatDisplays: "Day 1 Solution"),
            day1Entry,
            day2Entry
        ]
    }
}
