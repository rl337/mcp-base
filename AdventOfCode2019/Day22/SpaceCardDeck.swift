//
//  SpaceCardDeck.swift
//  AdventOfCode2019
//
//  Created by Richard Lee on 12/22/19.
//  Copyright © 2019 Richard Lee. All rights reserved.
//

import Foundation


class SpaceCardDeck {
    var cards: [Int]
    
    init(cardCount: Int = 10) {
        cards = Array(0..<cardCount)
    }
    
    func dealIntoNewStack() {
        cards.reverse()
    }
    
    func toCutNCards(_ n: Int) {
        let idx: Int
        if n < 0 {
            idx = cards.count + n
        } else {
            idx = n
        }

        let postCutSize = cards.count - idx
        let postCutIndex = idx
        
        var newDeck = cards
        newDeck[0..<postCutSize] = cards[postCutIndex..<cards.count]
        newDeck[postCutSize..<cards.count] = cards[0..<postCutIndex]
        cards = newDeck
    }
    
    func dealWithIncrementN(_ n: Int) {
        var newDeck = cards
        for i in 0..<cards.count {
            newDeck[i * n % cards.count] = cards[i]
        }
        cards = newDeck
    }
    
    func runScript(script: String) throws {
        for command in script.components(separatedBy: "\n") {
            if command == "deal into new stack" {
                dealIntoNewStack()
            } else if command.starts(with: "deal with increment") {
                let parts = command.components(separatedBy: " ")
                guard let lastPart = parts.last else {
                    throw SpaceCardDeckError.InvalidCommand
                }
                guard let increment = Int(lastPart) else {
                    throw SpaceCardDeckError.InvalidIncrementValue
                }
                dealWithIncrementN(increment)
            } else if command.starts(with: "cut") {
                let parts = command.components(separatedBy: " ")
                guard let lastPart = parts.last else {
                    throw SpaceCardDeckError.InvalidCommand
                }
                guard let cut = Int(lastPart) else {
                    throw SpaceCardDeckError.InvalidCutValue
                }
                toCutNCards(cut)
            }
        }
    }
    
    enum SpaceCardDeckError: Error {
        case InvalidCommand
        case InvalidIncrementValue
        case InvalidCutValue
    }
}
