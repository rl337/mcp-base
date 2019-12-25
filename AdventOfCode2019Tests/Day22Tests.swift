//
//  Day22Tests.swift
//  AdventOfCode2019Tests
//
//  Created by Richard Lee on 12/22/19.
//  Copyright © 2019 Richard Lee. All rights reserved.
//

import Foundation

import XCTest
@testable import AdventOfCode2019

extension SpaceCardDeck {
    func asIntArray() throws -> [Int] {
        var result: [Int] = []
        for i in 0 ..< self.count! {
            result.append(try self.getCard(index: i))
        }
        
        return result
    }
}

class Day22Tests: XCTestCase {
    
    
    func testDealIntoNewStack() throws {
        let deck = SpaceCardDeck(cardCount: 10)
        try deck.dealIntoNewStack()
        
        XCTAssertEqual(
            [9, 8, 7, 6, 5, 4, 3, 2, 1, 0],
            try deck.asIntArray()
        )
    }

    func testCutNCards() throws {
        let deck = SpaceCardDeck(cardCount: 10)
        try deck.toCutNCards(3)
        
        XCTAssertEqual(
            [3, 4, 5, 6, 7, 8, 9, 0, 1, 2],
            try deck.asIntArray()
        )
    }
    
    func testCutNegativeNCards() throws {
        let deck = SpaceCardDeck(cardCount: 10)
        try deck.toCutNCards(-4)
        
        XCTAssertEqual(
            [6, 7, 8, 9, 0, 1, 2, 3, 4, 5],
            try deck.asIntArray()
        )
    }
    
    func testDealWithIncrement3() throws {
        let deck = SpaceCardDeck(cardCount: 10)
        try deck.dealWithIncrementN(3)
        
        XCTAssertEqual(
            [0, 7, 4, 1, 8, 5, 2, 9, 6, 3],
            try deck.asIntArray()
        )
    }
    
    func testDealWithScriptExample1() throws {
        let deck = SpaceCardDeck(cardCount: 10)
//        try deck.runScript(script: """
//        deal with increment 7
//        deal into new stack
//        deal into new stack
//        """)
                try deck.runScript(script: """
                deal with increment 7
                """)
        
        XCTAssertEqual(
            [0, 3, 6, 9, 2, 5, 8, 1, 4, 7],
            try deck.asIntArray()
        )
    }
    
    func testDealWithScriptExample2() throws {
        let deck = SpaceCardDeck(cardCount: 10)
        try deck.runScript(script: """
        cut 6
        deal with increment 7
        deal into new stack
        """)
        
        XCTAssertEqual(
            [3, 0, 7, 4, 1, 8, 5, 2, 9, 6],
            try deck.asIntArray()
        )
    }
    
    func testDealWithScriptExample3() throws {
        let deck = SpaceCardDeck(cardCount: 10)
        try deck.runScript(script: """
        deal with increment 7
        deal with increment 9
        cut -2
        """)
        
        XCTAssertEqual(
            [6, 3, 0, 7, 4, 1, 8, 5, 2, 9],
            try deck.asIntArray()
        )
    }
    
    func testDealWithScriptExample4() throws {
        let deck = SpaceCardDeck(cardCount: 10)
        try deck.runScript(script: """
        deal into new stack
        cut -2
        deal with increment 7
        cut 8
        cut -4
        deal with increment 7
        cut 3
        deal with increment 9
        deal with increment 3
        cut -1
        """)
        
        XCTAssertEqual(
            [9, 2, 5, 8, 1, 4, 7, 0, 3, 6],
            try deck.asIntArray()
        )
    }
}
