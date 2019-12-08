//
//  Day8Tests.swift
//  AdventOfCode2019Tests
//
//  Created by Richard Lee on 12/7/19.
//  Copyright © 2019 Richard Lee. All rights reserved.
//

import Foundation
import XCTest
@testable import AdventOfCode2019

class Day8Tests: XCTestCase {

    func testGetLayers() throws {
        let img = SpaceImageFormat(width: 3, height: 2, data: "123456789012")
        XCTAssertEqual(img.getLayer(n: 0), [1,2,3,4,5,6])
        XCTAssertEqual(img.getLayer(n: 1), [7,8,9,0,1,2])
    }

}
