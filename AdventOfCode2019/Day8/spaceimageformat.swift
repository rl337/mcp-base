//
//  spaceimageformat.swift
//  AdventOfCode2019
//
//  Created by Richard Lee on 12/7/19.
//  Copyright © 2019 Richard Lee. All rights reserved.
//

import Foundation

struct SpaceImageFormat {
    var data: [Int]
    var width: Int
    var height: Int
    
    var count: Int {
        get {
            data.count / (width*height)
        }
    }
    
    init(width: Int, height: Int, data: String) {
        self.width = width
        self.height = height
        self.data = Array(repeating: 0, count: data.count)
        for i in 0..<data.count {
            self.data[i] = data[data.index(data.startIndex, offsetBy: i)].wholeNumberValue!
        }
    }
    
    func render() -> [Int] {
        var result = Array(repeating: 2, count: width*height)
        for n in 0..<count {
            let layer = getLayer(n:n)
            for i in 0..<layer.count {
                if result[i] != 2 {
                    continue // We already have a non-transparent value
                }
                result[i] = layer[i]
            }
        }
        return result
    }
    
    func getLayer(n: Int) -> [Int] {
        let layerSize = width * height
        let start = layerSize * n
        
        var result = Array(repeating: 0, count: layerSize)
        for i in 0..<layerSize {
            result[i] = data[start + i]
        }
        return result
    }
    
    
}
