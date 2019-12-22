//
//  UsefulExtensions.swift
//  AdventOfCode2019
//
//  Created by Richard Lee on 12/17/19.
//  Copyright © 2019 Richard Lee. All rights reserved.
//

import Foundation

extension Character {
    func asInt() -> Int {
        Int(self.asciiValue!)
    }
}

extension Int {
    func asCharacter() -> Character {
        Character(Unicode.Scalar.init(UInt8(self)))
    }
}

extension String {
    
    func trim() -> String {
        var copy = self
        while copy.first == " " || copy.first == "\n" {
            copy.removeFirst()
        }
        while copy.last == " " || copy.last == "\n" {
            copy.removeLast()
        }
        return copy
    }
    
    func asCharacter() -> Character {
        return Character(self)
    }
    
    func asCharacterInt() -> Int {
        return Character(self).asInt()
    }
}

extension Array where Element == String {
    func asCharacterArray() -> [Character] {
        return self.map { $0.asCharacter() }
    }
    
    func asIntArray() -> [Int] {
        return self.map { $0.asCharacter().asInt() }
    }
}

extension Array where Element == Character {
    func asIntArray() -> [Int] {
        return self.map { $0.asInt() }
    }
}

extension Array where Element == Int {
    func asAsciiString() -> String {
        return String(self.map { $0.asCharacter() })
    }
    
    func asStringArray() -> [String] {
        return self.map { String($0) }
    }
}
