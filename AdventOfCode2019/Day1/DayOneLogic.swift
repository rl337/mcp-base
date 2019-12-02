//
//  DayOneLogic.swift
//  AdventOfCode2019
//
//  Created by Richard Lee on 11/30/19.
//  Copyright © 2019 Richard Lee. All rights reserved.
//

import Foundation


public class DayOneSolution : DayOfCodeSolution {

    func calculateFuel(ofMass mass: Int) -> Int {
        return mass / 3 - 2
    }
    
    func calculateFuelForIterator<T: Sequence>(data: T, calculateFuelForFuel: Bool) -> Int where T.Iterator.Element == Int {

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
    
    func calculatePart1() throws -> Int {
        let day1InputFile = getFileFromProject(named: "Day1Input.txt")
        let i = try IntFileIterator(contentsOf: day1InputFile)
        return calculateFuelForIterator(
            data: i, calculateFuelForFuel: false)
    }
    
    func calculatePart2() throws -> Int {
        let day1InputFile = getFileFromProject(named: "Day1Input.txt")
        let i = try IntFileIterator(contentsOf: day1InputFile)
        return calculateFuelForIterator(
            data: i, calculateFuelForFuel: true)
    }
    
    public override func execute() -> [UIEntry] {
        
        let part1Entry = getEntryForFunction(method: calculatePart1, labeledWith: "Part 1")
        let part2Entry = getEntryForFunction(method: calculatePart2, labeledWith: "Part 2")

        return [
            UIEntry(thatDisplays: "Day 1 Solution"),
            part1Entry,
            part2Entry
        ]
    }
}
