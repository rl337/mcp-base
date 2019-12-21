//
//  TractorBeamMapper.swift
//  AdventOfCode2019
//
//  Created by Richard Lee on 12/19/19.
//  Copyright © 2019 Richard Lee. All rights reserved.
//

import Foundation

public class TractorBeamMapper {
    var map: SparseBitmap
    
    init() {
        map = SparseBitmap()
    }
    
    func runMachine(_ code: [Int], _ x: Int, _ y: Int) throws -> Int {
        let machine = IntCodeMachine(withCode: code)
        machine.addInput(value: x)
        machine.addInput(value: y)
        do {
        try machine.run()
        } catch IntCodeMachine.IntCodeMachineError.UnexpectedEndOfInput {
        }
        
        let output = machine.output()
        machine.clearOutput()
        
        return output[0]
    }
    
    func mapTractorBeam(_ code: [Int], _ width: Int = 50, _ height: Int = 50, _ onlyLastRow: Bool = false, _ onlyLeadingColumn: Bool = false) throws {
        
        for y in (onlyLastRow ? height-1 : 0)..<width {
            for x in 0..<height {
                let output = try runMachine(code, x, y)
                
                if output == 1 {
                    map.points[BitmapPoint(x, y)] = 1
                } else if output != 0 {
                    throw TractorBeamMapperError.UnexpectedOutputValue
                }
            }
        }
    }
    
    func findWidthAtHeight(_ code: [Int], _ height: Int) throws -> Int {
        var x: Int = 0
        let y: Int = height - 1
        
        while try runMachine(code, x, y) == 0 {
            x += 1
        }
        
        var width: Int = 0
        while try runMachine(code, x, y) == 1 {
            x += 1
            width += 1
        }
        x -= 1
        
        return width
    }
    
    enum TractorBeamMapperError : Error {
        case UnexpectedOutputValue
    }
}
