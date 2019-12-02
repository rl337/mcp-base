//
//  InputHelper.swift
//  AdventOfCode2019
//
//  Created by Richard Lee on 11/30/19.
//  Copyright © 2019 Richard Lee. All rights reserved.
//

import Foundation


public struct IntFileIterator: Sequence, IteratorProtocol {
    private var values : Array<Int>
    private var index: Int
    
    init(contentsOf file: URL) throws {
        values = Array<Int>();
        let raw = try String(contentsOf: file)
        let rawSplits = raw.split(separator: "\n")
        for rawSplit in rawSplits {
            let intValue = Int(String(rawSplit))
            values.append(intValue!)
        }
        index = 0
    }
    
    public mutating func next() -> Int? {
        if values.count < 1 {
            return nil
        }

        if index >= values.count {
            return nil
        }
        
        let result = values[index]
        index = index + 1
        return result
    }
    
    public func peek() throws -> Int {
        guard values.count > 0 else {
            throw IntFileIteratorError.PeekOfEmptyIterator
        }
        
        return values[index]
    }
    
    public enum IntFileIteratorError : Error {
        case PeekOfEmptyIterator
    }
}


