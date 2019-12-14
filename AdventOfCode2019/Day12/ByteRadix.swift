//
//  ByteRadix.swift
//  AdventOfCode2019
//
//  Created by Richard Lee on 12/12/19.
//  Copyright © 2019 Richard Lee. All rights reserved.
//

import Foundation

class ByteRadixNode {
    var data: Array<ByteRadixNode?>
    
    init() {
        data = Array(repeating: nil, count: 256)
    }
}

class ByteRadix {
    var root: ByteRadixNode
    
    init() {
        root = ByteRadixNode()
    }
    
    func set(value: Int) {
        let byte1 = value & 0x00000000000000FF
        var arr1 = root.data[byte1]
        if arr1 == nil {
            arr1 = ByteRadixNode()
            root.data[byte1] = arr1
        }
        
        let byte2 = (value & 0x000000000000FF00)>>8
        var arr2 = arr1!.data[byte2]
        if arr2 == nil {
            arr2 = ByteRadixNode()
            arr1!.data[byte2] = arr2
        }
        
        let byte3 = (value & 0x0000000000FF0000)>>16
        var arr3 = arr2!.data[byte3]
        if arr3 == nil {
            arr3 = ByteRadixNode()
            arr2!.data[byte3] = arr3
        }
        
        let byte4 = (value & 0x00000000FF000000)>>24
        var arr4 = arr3!.data[byte4]
        if arr4 == nil {
            arr4 = ByteRadixNode()
            arr3!.data[byte4] = arr4
        }

        let byte5 = (value & 0x000000FF00000000)>>32
        var arr5 = arr4!.data[byte5]
        if arr5 == nil {
            arr5 = ByteRadixNode()
            arr4!.data[byte5] = arr5
        }
        
        let byte6 = (value & 0x0000FF0000000000)>>40
        var arr6 = arr5!.data[byte6]
        if arr6 == nil {
            arr6 = ByteRadixNode()
            arr5!.data[byte6] = arr6
        }
        
        let byte7 = (value & 0x00FF000000000000)>>48
        var arr7 = arr6!.data[byte7]
        if arr7 == nil {
            arr7 = ByteRadixNode()
            arr6!.data[byte7] = arr7
        }
        
        let byte8 = (value & 0x7F00000000000000)>>56 + (value < 0 ? 128 : 0)
        if arr7!.data[byte8] == nil {
            arr7!.data[byte8] = ByteRadixNode()
        }
    }
    
    func isSet(value: Int) -> Bool {
        let byte1 = value & 0x00000000000000FF
        guard let arr1 = root.data[byte1] else {
            return false
        }
        
        let byte2 = (value & 0x000000000000FF00)>>8
        guard let arr2 = arr1.data[byte2] else {
            return false
        }
        let byte3 = (value & 0x0000000000FF0000)>>16
        guard let arr3 = arr2.data[byte3] else {
            return false
        }
        let byte4 = (value & 0x00000000FF000000)>>24
        guard let arr4 = arr3.data[byte4] else {
            return false
        }
        let byte5 = (value & 0x000000FF00000000)>>32
        guard let arr5 = arr4.data[byte5] else {
            return false
        }
        let byte6 = (value & 0x0000FF0000000000)>>40
        guard let arr6 = arr5.data[byte6] else {
            return false
        }
        let byte7 = (value & 0x00FF000000000000)>>48
        guard let arr7 = arr6.data[byte7] else {
            return false
        }
        
        let byte8 = (value & 0x7F00000000000000)>>56 + (value < 0 ? 128 : 0)
        guard let _ = arr7.data[byte8] else {
            return false
        }
        
        return true
    }
    
}
