//
//  Day12Logic.swift
//  AdventOfCode2019
//
//  Created by Richard Lee on 12/14/19.
//  Copyright © 2019 Richard Lee. All rights reserved.
//

import Foundation

class DayFourteenSolution : DayOfCodeSolution {
    
    func calculatePart1() throws -> Int {
        let day11InputFile = getFileFromProject(named: "Day14Input.txt")
        let recipes = try String(contentsOf: day11InputFile)
        return try oreToProduceNFuel(recipes: recipes, n: 1)
    }
    
    func oreToProduceNFuel(recipes: String, n: Int) throws -> Int{
        let factory = NanoFactory(recipes: recipes)
        
        _ = try factory.get(Ingredient(qty: n, name: "FUEL"))
        return factory.oreUsed
    }
    
    func fuelWithOre(recipes: String, ore: Int) throws -> Int {
        let oreFor1Fuel = try oreToProduceNFuel(recipes: recipes, n: 1)
        
        var left = 0
        var estimate = ore / oreFor1Fuel
        var right = estimate * 4
        while right - left > 1 {
            let produced = try oreToProduceNFuel(recipes: recipes, n: estimate)
            if produced == ore {
                return estimate
            }
            
            if produced < ore {
                left = estimate
            } else {
                right = estimate
            }
            estimate = (left + right) / 2
        }
        
        return estimate
    }
    
    func calculatePart2() throws -> Int {
        let day11InputFile = getFileFromProject(named: "Day14Input.txt")
        let recipes = try String(contentsOf: day11InputFile)
        
        let ore = 1000000000000
        return try fuelWithOre(recipes: recipes, ore: ore)
    }
    
    
    public override func heading() -> [UIEntry] {
        return [
            UIEntry(withId: 0, thatDisplays: "Day 14 Solution"),
        ]
    }
    
    public override func execute() -> [UIEntry] {
        let part1Entry = getEntryForFunction(1, method: calculatePart1, labeledWith: "Part 1")
        let part2Entry = getEntryForFunction(2, method: calculatePart2, labeledWith: "Part 2")
        
        return [
            part1Entry,
            part2Entry
        ]
    }

}
