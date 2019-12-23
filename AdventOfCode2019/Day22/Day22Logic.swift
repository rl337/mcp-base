//
//  Day22Logic.swift
//  AdventOfCode2019
//
//  Created by Richard Lee on 12/22/19.
//  Copyright © 2019 Richard Lee. All rights reserved.
//

import Foundation

class DayTwentyTwoSolution : DayOfCodeSolution {
    
    func calculatePart1() throws -> Int {
        let day22InputFile = getFileFromProject(named: "Day22Input.txt")
        let script = try String(contentsOf: day22InputFile)
        
        let deck = SpaceCardDeck(cardCount: 10007)
        try deck.runScript(script: script)
        
        for i in 0 ..< deck.cards.count {
            if deck.cards[i] == 2019 {
                return i
            }
        }
        
        return 0
    }
    
    func calculatePart2() throws -> Int  {
        let day22InputFile = getFileFromProject(named: "Day22Input.txt")
        let script = try String(contentsOf: day22InputFile)
        
        let deck = SpaceCardDeck(cardCount: 119315717514047)
        try deck.runScript(script: script)
        
        for i in 0 ..< deck.cards.count {
            if deck.cards[i] == 2019 {
                return i
            }
        }
        
        return 0
    }
    
    public override func execute() -> [UIEntry] {
        let part1Entry = getEntryForFunction(10, method: calculatePart1, labeledWith: "Part 1")
        let part2Entry = getEntryForFunction(40, method: calculatePart2, labeledWith: "Part 2")
        return [
            part1Entry,
            part2Entry,
        ]
    }

}
