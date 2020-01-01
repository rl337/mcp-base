//
//  Day13Logic.swift
//  AdventOfCode2019
//
//  Created by Richard Lee on 12/24/19.
//  Copyright © 2019 Richard Lee. All rights reserved.
//

import Foundation

class DayThirteenSolution : DayOfCodeSolution {
    
    func calculatePart1() throws -> Int {
        let day13InputFile = getFileFromProject(named: "Day13Input.txt")
        let machine = try IntCodeMachine(fromURL: day13InputFile)
        
        try machine.run()
        var output = machine.output()
        machine.clearOutput()
        var board = SparseBitmap()
        while output.count > 0 {
            let x = output.removeFirst()
            let y = output.removeFirst()
            let v = output.removeFirst()
            board.points[BitmapPoint(x, y)] = v
        }
        
        var totalBlocks = 0
        for v in board.points.values {
            if v == 2 {
                totalBlocks += 1
            }
        }
        
        return totalBlocks
    }
    
    func renderBoard(board: SparseBitmap) -> String {
        return board.asBitmap(mapping: [
            0: Character("⬜️"),
            1: Character("⬛️"),
            2: Character("🟧"),
            3: Character("🟦"),
            4: Character("🟣")
        ])
    }
    
    func drawBoard() throws -> String {
        let day13InputFile = getFileFromProject(named: "Day13Input.txt")
        let i = try IntFileIterator(contentsOf: day13InputFile, delimitedBy: ",")
        let code = i.array()
        let machine = IntCodeMachine(withCode: code)
        
        try machine.run()
        var output = machine.output()
        machine.clearOutput()
        var board = SparseBitmap()
        while output.count > 0 {
            let x = output.removeFirst()
            let y = output.removeFirst()
            let v = output.removeFirst()
            board.points[BitmapPoint(x, y)] = v
        }
        
        return renderBoard(board: board)
    }
    
    func calculatePart2() throws -> [UIEntry]  {
        let day13InputFile = getFileFromProject(named: "Day13Input.txt")
        let i = try IntFileIterator(contentsOf: day13InputFile, delimitedBy: ",")
        var code = i.array()
        code[0] = 2
        let machine = IntCodeMachine(withCode: code)
        
        var score = 0
        var ballX = 0
        var paddleX = 0
        var board = SparseBitmap()

        while !machine.isHalted() {
            do {
                try machine.run()
            } catch IntCodeMachine.IntCodeMachineError.UnexpectedEndOfInput {
                
            }
            var output = machine.output()
            machine.clearOutput()

            while output.count > 0 {
                let x = output.removeFirst()
                let y = output.removeFirst()
                let v = output.removeFirst()
                
                board.points[BitmapPoint(x, y)] = v

                if x == -1 && y == 0 {
                    score = v
                }
                
                if v == 4 {
                    ballX = x
                }
                
                if v == 3 {
                    paddleX = x
                }
            }
            
            if ballX == paddleX {
                machine.addInput(value: 0)
            } else if ballX > paddleX {
                machine.addInput(value: 1)
            } else {
                machine.addInput(value: -1)
            }
        }
        
        return [
            UIEntry(withId: 500, thatDisplays: String(score), labeledWith: "Score"),
            UIEntry(withId: 501, thatDisplays: renderBoard(board: board), labeledWith: "Ending Board", isMonospaced: true, size: 4),
        ]
    }
    
    public override func heading() -> [UIEntry] {
        return [
            UIEntry(withId: 0, thatDisplays: "Day 13 Solution"),
        ]
    }
    
    public override func execute() -> [UIEntry] {
        let part1Entry = getEntryForFunction(10, method: calculatePart1, labeledWith: "Part 1")
        let board = getEntryForStringFunction(80, method: drawBoard, labeledWith: "Board", monospaced: true, size: 4)
        var list = [
            part1Entry,
            board
        ]
        
        do {
            list.append(contentsOf: try calculatePart2())
        } catch {
            list.append(
                UIEntry(
                    withId: 999,
                    thatDisplays: "\(error)",
                    labeledWith: "Error",
                    isError: true
                )
            )
        }
        return list
    }

}
