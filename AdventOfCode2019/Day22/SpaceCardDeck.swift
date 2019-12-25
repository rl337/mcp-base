//
//  SpaceCardDeck.swift
//  AdventOfCode2019
//
//  Created by Richard Lee on 12/22/19.
//  Copyright © 2019 Richard Lee. All rights reserved.
//

import Foundation

protocol DeckFilter : class {
    func getCard(index: Int) throws -> Int
    func getCardCount() -> Int
}

enum SpaceCardDeckError : Error {
    case FilterNotImplemented, InvalidCardIndex, NoParentFilterPresentInvalidCommand, InvalidIncrementValue, InvalidCutValue, InvalidCommand
}

class SpaceCardDeckFilter : DeckFilter {
    let parent: DeckFilter
    init(parent: DeckFilter) {
        self.parent = parent
    }
    
    func getCard(index: Int) throws -> Int {
        throw SpaceCardDeckError.FilterNotImplemented
    }
    
    func getCardCount() -> Int {
        return parent.getCardCount()
    }

}

class IdentityFilter : DeckFilter {
    let cardCount: Int
    init(cardCount: Int) {
        self.cardCount = cardCount
    }
    
    func getCard(index: Int) throws -> Int {
        guard index >= 0 else {
            throw SpaceCardDeckError.InvalidCardIndex
        }
        
        guard index < self.cardCount else {
            throw SpaceCardDeckError.InvalidCardIndex
        }
        
        return index
    }
    
    func getCardCount() -> Int {
        return self.cardCount
    }
}

class DealIntoNewStackFilter : SpaceCardDeckFilter {
    
    override func getCard(index: Int) throws -> Int {
        let reversedIndex = getCardCount() - index - 1
        return try parent.getCard(index: reversedIndex)
    }
    
}

class ToCutNCardsFilter : SpaceCardDeckFilter {
    let n: Int
    
    init(parent: DeckFilter, n: Int) {
        self.n = n
        super.init(parent: parent)
    }
    
    override func getCard(index: Int) throws -> Int {
        let cardCount = getCardCount()
        let safeIndex: Int
        if self.n < 0 {
            safeIndex =  cardCount + self.n
        } else {
            safeIndex = self.n
        }
        
        let realIndex = (safeIndex + index) % cardCount
        
        return try parent.getCard(index: realIndex)
    }
    
}

class DealWithIncrementFilter : SpaceCardDeckFilter {
    let increment: Int
    
    init(parent: DeckFilter, increment: Int) {
        self.increment = increment
        super.init(parent: parent)
    }
    
    /*
         0 1 2 3 4 5 6 7 8 9
         0 7 4 1 8 5 2 9 7 3
         0 2 1 0 2 1 0 2 1 0
         0 6 3 0 6 3 0 6 3 0

         0 3 6 9 2 5 8 1 4 7
     
i/3
         *     *     *     *

     0 0   0  0
     1 7   7  3
     2 14  4  6
     3 21  1  9
     4 28  8  2
     5 35  5  5
     6 42  2  8
     7 49  9  1
     8 56  6  4
     9 63  3  7
   
     
     */
    
    override func getCard(index: Int) throws -> Int {
        
        let wraps = (increment - (index % increment)) % increment
        let realIndex = ((index + getCardCount() * wraps) / increment) % getCardCount()
        
        return try parent.getCard(index: realIndex)
    }
    
}

class SpaceCardDeck {
    var filters: [DeckFilter]
    var count: Int? {
        get {
            guard let parent = self.filters.last else {
                return nil
            }
            
            return parent.getCardCount()
        }
    }
    
    init(cardCount: Int = 10) {
        self.filters = [
            IdentityFilter(cardCount: cardCount)
        ]
    }
    
    func getCard(index: Int) throws -> Int {
        guard let parent = self.filters.last else {
            throw SpaceCardDeckError.NoParentFilterPresentInvalidCommand
        }
        
        return try parent.getCard(index: index)
    }
    
    func dealIntoNewStack() throws {
        guard let parent = self.filters.last else {
            throw SpaceCardDeckError.NoParentFilterPresentInvalidCommand
        }
        self.filters.append(DealIntoNewStackFilter(parent: parent))
    }
    
    func toCutNCards(_ n: Int) throws {
        guard let parent = self.filters.last else {
            throw SpaceCardDeckError.NoParentFilterPresentInvalidCommand
        }
        self.filters.append(ToCutNCardsFilter(parent: parent, n: n))
    }
    
    func dealWithIncrementN(_ n: Int) throws {
        guard let parent = self.filters.last else {
            throw SpaceCardDeckError.NoParentFilterPresentInvalidCommand
        }
        self.filters.append(DealWithIncrementFilter(parent: parent, increment: n))
    }
    
    func runScript(script: String) throws {
        for command in script.components(separatedBy: "\n") {
            if command == "deal into new stack" {
                try dealIntoNewStack()
            } else if command.starts(with: "deal with increment") {
                let parts = command.components(separatedBy: " ")
                guard let lastPart = parts.last else {
                    throw SpaceCardDeckError.InvalidCommand
                }
                guard let increment = Int(lastPart) else {
                    throw SpaceCardDeckError.InvalidIncrementValue
                }
                try dealWithIncrementN(increment)
            } else if command.starts(with: "cut") {
                let parts = command.components(separatedBy: " ")
                guard let lastPart = parts.last else {
                    throw SpaceCardDeckError.InvalidCommand
                }
                guard let cut = Int(lastPart) else {
                    throw SpaceCardDeckError.InvalidCutValue
                }
                try toCutNCards(cut)
            }
        }
    }

}
