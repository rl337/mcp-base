//
//  InputHelper.swift
//  AdventOfCode2019
//
//  Created by Richard Lee on 11/30/19.
//  Copyright © 2019 Richard Lee. All rights reserved.
//

import Foundation


public struct IntFileIterator: Sequence, IteratorProtocol {
    var values : Array<Int>
    var index: Int
    
    init(contentsOf file: URL) {
        values = Array<Int>();
        index = -1
        do {
            let raw = try String(contentsOf: file)
            let rawSplits = raw.split(separator: "\n")
            for rawSplit in rawSplits {
                let intValue = Int(String(rawSplit))
                values.append(intValue!)
            }
            
        } catch {
            
        }
    }
    
    public mutating func next() -> Int? {
        index = index + 1
        if index >= values.count {
            return nil
        }
        
        return values[index]
    }
    
}
