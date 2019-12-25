//
//  BigGrid.swift
//  AdventOfCode2019
//
//  Created by Richard Lee on 12/23/19.
//  Copyright © 2019 Richard Lee. All rights reserved.
//

import Foundation

class BugGrid {
    let bugValue = "#".asCharacterInt()
    let spaceValue = ".".asCharacterInt()

    var grid: SparseBitmap
    var gridSize: Int
    
    init(_ gridSize: Int, _ data: String) {
        self.gridSize = gridSize
        grid = SparseBitmap()
        let rows = data.trim().components(separatedBy: "\n")
        for y in 0..<rows.count {
            let row = rows[y]
            let rowData = Array<Character>(row)
            for x in 0..<rowData.count {
                grid.points[BitmapPoint(x, y)] = rowData[x].asInt()
            }
        }
    }
    
    func adjacentCount(point: BitmapPoint) -> Int {
        var total = 0
        for value in [point.north, point.south, point.east, point.west] {
            if grid.points[value] == bugValue {
                total += 1
            }
        }
        return total
    }
    
    func step() {
        var newGrid = SparseBitmap()
        for y in 0..<gridSize {
            for x in 0..<gridSize {
                let p = BitmapPoint(x, y)
                let adjacent = adjacentCount(point: p)
                if grid.points[p] == bugValue {
                    if adjacent == 1 {
                        newGrid.points[p] = bugValue
                    } else {
                        newGrid.points[p] = spaceValue
                    }
                } else {
                    if adjacent == 1 || adjacent == 2 {
                        newGrid.points[p] = bugValue
                    } else {
                        newGrid.points[p] = spaceValue
                    }
                }
            }
        }
        
        self.grid = newGrid
    }
    
    func computeBiodiversity() -> Int {
        var total = 0
        for y in 0..<gridSize {
            for x in 0..<gridSize {
                let p = BitmapPoint(x, y)
                if grid.points[p] == bugValue {
                    let shift = y * gridSize + x
                    total += (1 << shift)
                }
            }
        }
        return total
    }
    
    func asString() -> String {
        return self.grid.asBitmap(mapping: [
            "#".asCharacterInt(): "#".asCharacter(),
            ".".asCharacterInt(): ".".asCharacter()
        ])
    }
}
