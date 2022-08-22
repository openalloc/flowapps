//
//  AllocateGetPercentTests.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
//

import XCTest

import FlowBase
import AllocData

@testable import FlowAllocLow

class AllocateGetPercentTests: XCTestCase {
    func testNothingToDo() {
        let pct = getStrategyPct(remainingAccountCapacity: 0.0,
                                 remainingAssetClassCapacity: 0.75,
                                 forwardAssetClassCapacity: 0.2,
                                 userMaxLimit: 1.0, userVertLimit: 0)
        
        XCTAssertEqual(pct, 0.0, accuracy: 0.001)
    }
    
    func testMaximalSliceAllocation() {
        let pct = getStrategyPct(remainingAccountCapacity: 0.5,
                                 remainingAssetClassCapacity: 0.75,
                                 forwardAssetClassCapacity: 0.2,
                                 userMaxLimit: 1.0, userVertLimit: 0)
        
        XCTAssertEqual(pct, 0.5, accuracy: 0.001)
    }
    
    func testIgnoreUserLimit() {
        let pct = getStrategyPct(remainingAccountCapacity: 0.5,
                                 remainingAssetClassCapacity: 0.75,
                                 forwardAssetClassCapacity: 0.2,
                                 userMaxLimit: 0.0, userVertLimit: 0)
        
        XCTAssertEqual(pct, 0.3, accuracy: 0.001)
    }
    
    func testLimitedByExhaustedSlice() {
        let pct = getStrategyPct(remainingAccountCapacity: 0.5,
                                 remainingAssetClassCapacity: 0.41,
                                 forwardAssetClassCapacity: 0.2,
                                 userMaxLimit: 1.0, userVertLimit: 0)
        
        XCTAssertEqual(pct, 0.41, accuracy: 0.001)
    }
    
    func testRespectUserLimit() {
        let pct = getStrategyPct(remainingAccountCapacity: 0.5,
                                 remainingAssetClassCapacity: 0.75,
                                 forwardAssetClassCapacity: 0.5,
                                 userMaxLimit: 0.1, userVertLimit: 0)
        
        XCTAssertEqual(pct, 0.1, accuracy: 0.001)
    }
    
    func testRespectUserVertLimit() {
        let pct = getStrategyPct(remainingAccountCapacity: 0.5,
                                 remainingAssetClassCapacity: 0.75,
                                 forwardAssetClassCapacity: 0.5,
                                 userMaxLimit: 0.1, userVertLimit: 0.15)
        
        XCTAssertEqual(pct, 0.15, accuracy: 0.001) //TODO is this correct?
    }

    func testLastSliceOverrideUser() {
        let pct = getStrategyPct(remainingAccountCapacity: 0.5,
                                 remainingAssetClassCapacity: 0.75,
                                 forwardAssetClassCapacity: 0.0,
                                 userMaxLimit: 0.0, userVertLimit: 0)
        
        XCTAssertEqual(pct, 0.5, accuracy: 0.001)
    }
}
