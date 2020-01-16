//
//  BinaryHeap.swift
//  AdventOfCode2019
//
//  Created by Richard Lee on 1/9/20.
//  Copyright © 2020 Richard Lee. All rights reserved.
//

import Foundation

class BinaryHeap<T> {
    var storage: [T]
    var compare: (_ a: T, _ b: T) -> Bool
    
    var count: Int {
        get { storage.count }
    }
    
    init(withReserveCapacity capacity: Int = 1000, _ comparator: @escaping (_ a: T, _ b: T) -> Bool) {
        storage = Array()
        storage.reserveCapacity(capacity)
        self.compare = comparator
    }
    
    private func indexForParent(_ index: Int) -> Int {
        return (index - 1) / 2
    }
    
    private func indexForLeftChild(_ index: Int) -> Int {
        return index * 2 + 1
    }
    
    private func indexForRightChild(_ index: Int) -> Int {
        return index * 2 + 2
    }
    
    private func doesLeftChildExist(_ index: Int) -> Bool {
        return indexForLeftChild(index) < storage.count
    }
    
    private func doesRightChildExist(_ index: Int) -> Bool {
        return indexForRightChild(index) < storage.count
    }
    
    private func swap(_ a: Int, _ b: Int) throws {
        guard a >= 0, b >= 0, a < storage.count, b < storage.count else {
            throw BinaryHeapError.IndexOutOfBound
        }
        
        let tmp = storage[a]
        storage[a] = storage[b]
        storage[b] = tmp
    }
    
    private func percolateDown(_ index: Int) throws {
        guard index < storage.count else {
            return
        }
        
        let leftChildExists = doesLeftChildExist(index)
        let rightChildExists = doesRightChildExist(index)
        
        // If neither child exists, there's nothing to percolate to
        guard leftChildExists || rightChildExists else {
            return
        }
        
        var indexToUse: Int
        if leftChildExists && !rightChildExists {
            indexToUse = indexForLeftChild(index)
        } else if rightChildExists && !leftChildExists {
            indexToUse = indexForRightChild(index)
        } else {
            let leftIndex = indexForLeftChild(index)
            let rightIndex = indexForRightChild(index)
            if self.compare(storage[rightIndex], storage[leftIndex]) {
                indexToUse = leftIndex
            } else {
                indexToUse = rightIndex
            }
        }
        
        try swap(index, indexToUse)
        try percolateDown(indexToUse)
    }
    
    private func percolateUp(_ index: Int) throws {
        if index == 0 {
            return
        }
        
        let parentIndex = indexForParent(index)
        if self.compare(storage[index], storage[parentIndex]) {
            return
        }
        
        try swap(index, parentIndex)
        try percolateUp(parentIndex)
    }
    
    public func enqueue(_ value: T) throws {
        storage.append(value)
        try percolateUp(storage.count - 1)
    }
    
    public func dequeue() throws -> T {
        // If we had no items, throw error.
        if storage.count < 1 {
            throw BinaryHeapError.DequeueOfEmptyHeap
        }
        
        // We had exactly one item. Simply remove it and return
        let last = storage.removeLast()
        if storage.count < 1 {
            return last
        }
        
        let result = storage[0]
        storage[0] = last
        try percolateDown(0)
        
        return result
    }
    
    
    enum BinaryHeapError: Error {
        case IndexOutOfBound,
            DequeueOfEmptyHeap
    }
}
