//
//  FlawedFrequencyTransmission.swift
//  AdventOfCode2019
//
//  Created by Richard Lee on 12/15/19.
//  Copyright © 2019 Richard Lee. All rights reserved.
//

import Foundation

class FlawedFrequencyTransmission {
    var signal: [Int]
    var repeatedInput: Int
    let repeating: [Int] = [0, 1, 0, -1]
    
    func getRepeatingValue(forElement element: Int, atOffset offset: Int) -> Int {
        let realIndex = (offset + 1) / (element + 1)
        return repeating[realIndex % repeating.count]
    }

    init(rawSignal: String, repeatInput: Int = 1) throws {
        self.signal = []
        for ch in Array(rawSignal) {
            guard let intval = ch.wholeNumberValue else {
                throw FlawedFrequencyTransmissionError.InputContainsBadCharacters
            }
            self.signal.append(intval)
        }
        self.repeatedInput = repeatInput
    }
    
    func phase(phase: Int) throws -> [Int] {
        if phase == 0 {
            return self.signal
        }
        
        let phaseSignal = try self.phase(phase: phase - 1)
        
        var result: [Int] = Array(repeating: 0, count: phaseSignal.count)
        for i in 0..<result.count {
            var iValue = 0
            for j in 0..<phaseSignal.count {
                let signalDigit = phaseSignal[j]
                let repeatingDigit = getRepeatingValue(forElement: i, atOffset: j)
                let thisTerm = (signalDigit * repeatingDigit)
                iValue += thisTerm
            }
            guard let lastDigit = String(iValue).last?.wholeNumberValue else {
                throw FlawedFrequencyTransmissionError.PhaseCalculationProducedBadString
            }
            result[i] = lastDigit
        }
        
        return result
    }
    
    enum FlawedFrequencyTransmissionError: Error {
        case InputContainsBadCharacters
        case PhaseCalculationProducedBadString
    }
    
}
