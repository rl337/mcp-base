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
    private var index: Int?
    
    init(contentsOf file: URL, delimitedBy delimiter: Character = "\n") throws {
        values = Array<Int>();
        var raw = try String(contentsOf: file)
        if raw.hasSuffix("\n") && delimiter != "\n" {
            raw.removeLast()
        }
        
        let rawSplits = raw.split(separator: delimiter)
        for rawSplit in rawSplits {
            if rawSplit == "" {
                continue
            }
            let intValue = Int(String(rawSplit))
            values.append(intValue!)
        }
        index = 0
    }
    
    public mutating func next() -> Int? {
        guard values.count > 0,
            let index = index,
            index < values.count else {
            return nil
        }
        
        let result = values[index]
        self.index = index + 1
        return result
    }
    
    public func peek() throws -> Int {
        guard values.count > 0 else {
            throw IntFileIteratorError.PeekOfEmptyIterator
        }
        
        guard let index = index else {
            throw IntFileIteratorError.PeekBeforeNext
        }
        
        return values[index]
    }
    
    public func array() -> [Int] {
        return values
    }
    
    public enum IntFileIteratorError : Error {
        case PeekOfEmptyIterator, PeekBeforeNext
    }
}


