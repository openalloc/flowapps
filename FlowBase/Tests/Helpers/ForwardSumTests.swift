//
//  ForwardSumTests.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import XCTest

import FlowBase
import AllocData

@testable import FlowBase

class ForwardSumTests: XCTestCase {
    
    func testForwardSum() {
        let capacities = [0.13, 0.20, 0.18, 0.02]

        let bar0 = capacities.forwardSum()

        XCTAssertEqual(bar0, 0.13 + 0.20 + 0.18 + 0.02)

        let bar1 = capacities.forwardSum(start: 1)

        XCTAssertEqual(bar1, 0.20 + 0.18 + 0.02)

        let bar2 = capacities.forwardSum(start: 2)

        XCTAssertEqual(bar2, 0.18 + 0.02)

        let bar3 = capacities.forwardSum(start: 3)

        XCTAssertEqual(bar3, 0.02)

        let bar4 = capacities.forwardSum(start: 4)

        XCTAssertEqual(bar4, 0.0)
    }
    
    func testForwardSumDict() {
        let capacities = ["d": 0.13, "c": 0.20, "a": 0.18, "b": 0.02, "e": 0.07]

        let order = ["a", "b", "c", "d"]
        
        let bar0 = capacities.forwardSum(order: order, start: 0)

        XCTAssertEqual(bar0, 0.18 + 0.02 + 0.20 + 0.13)

        let bar1 = capacities.forwardSum(order: order, start: 1)

        XCTAssertEqual(bar1, 0.02 + 0.20 + 0.13)

        let bar2 = capacities.forwardSum(order: order, start: 2)

        XCTAssertEqual(bar2, 0.20 + 0.13)

        let bar3 = capacities.forwardSum(order: order, start: 3)

        XCTAssertEqual(bar3, 0.13)

        let bar4 = capacities.forwardSum(order: order, start: 4)

        XCTAssertEqual(bar4, 0.0)
    }
    
    func testForwardSumDictMissing() {
        let capacities = ["d": 0.13, "c": 0.20, "a": 0.18, "b": 0.02, "e": 0.07]

        let order = ["a", "b", "c", "x", "d"]
        
        let bar0 = capacities.forwardSum(order: order, start: 0)

        XCTAssertEqual(bar0, 0.18 + 0.02 + 0.20 + 0.13)

        let bar1 = capacities.forwardSum(order: order, start: 1)

        XCTAssertEqual(bar1, 0.02 + 0.20 + 0.13)

        let bar2 = capacities.forwardSum(order: order, start: 2)

        XCTAssertEqual(bar2, 0.20 + 0.13)

        let bar3 = capacities.forwardSum(order: order, start: 3)

        XCTAssertEqual(bar3, 0.13)

        let bar4 = capacities.forwardSum(order: order, start: 4)

        XCTAssertEqual(bar4, 0.13)
        
        let bar5 = capacities.forwardSum(order: order, start: 5)

        XCTAssertEqual(bar5, 0)
    }
}
