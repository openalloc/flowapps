//
//  AllocPriorityBaseTests.swift
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

@testable import FlowAllocHigh

final class AllocPriorityBaseTests: XCTestCase {
    func testIgnoreInvalidPriority() throws {
        var allocs: [MAllocation] = []
        XCTAssertThrowsError(try MAllocation.normies(&allocs, controlIndex: 0)) { error in
            XCTAssertEqual(error as! FlowBaseError, FlowBaseError.invalidControlIndex)
        }
    }

    func testOneLock() throws {
        var allocs: [MAllocation] = [MAllocation(strategyID: "1", assetID: "a", targetPct: 0.0, isLocked: true)]
        try MAllocation.normies(&allocs, controlIndex: 0)
        let expected: [MAllocation] = [MAllocation(strategyID: "1", assetID: "a", targetPct: 1.0, isLocked: true)]
        XCTAssertEqual(expected, allocs)
    }

    func testOneLockInvalidPriority() throws {
        var allocs: [MAllocation] = [MAllocation(strategyID: "1", assetID: "a", targetPct: 0.0, isLocked: true)]
        XCTAssertThrowsError(try MAllocation.normies(&allocs, controlIndex: 1)) { error in
            XCTAssertEqual(error as! FlowBaseError, FlowBaseError.invalidControlIndex)
        }
    }

    func testOneUnlock() throws {
        var allocs: [MAllocation] = [MAllocation(strategyID: "1", assetID: "a", targetPct: 0.0, isLocked: false)]
        try MAllocation.normies(&allocs, controlIndex: 0)
        let expected: [MAllocation] = [MAllocation(strategyID: "1", assetID: "a", targetPct: 1.0, isLocked: false)]
        XCTAssertEqual(expected, allocs)
    }

    func testOneUnlockInvalidPriority() throws {
        var allocs: [MAllocation] = [MAllocation(strategyID: "1", assetID: "a", targetPct: 0.0, isLocked: false)]
        XCTAssertThrowsError(try MAllocation.normies(&allocs, controlIndex: 1)) { error in
            XCTAssertEqual(error as! FlowBaseError, FlowBaseError.invalidControlIndex)
        }
    }

    func testBalanced6040() throws {
        var allocs = [
            MAllocation(strategyID: "1", assetID: "a", targetPct: 0.60, isLocked: true),
            MAllocation(strategyID: "1", assetID: "b", targetPct: 0.40, isLocked: true),
        ]
        let expected: [MAllocation] = allocs
        for priority in 0 ..< allocs.count {
            try MAllocation.normies(&allocs, controlIndex: priority)
            XCTAssertEqual(expected, allocs)
        }
    }

    func testBalanced() throws {
        var allocs = [
            MAllocation(strategyID: "1", assetID: "a", targetPct: 0.10, isLocked: true),
            MAllocation(strategyID: "1", assetID: "b", targetPct: 0.20, isLocked: false),
            MAllocation(strategyID: "1", assetID: "c", targetPct: 0.30, isLocked: true),
            MAllocation(strategyID: "1", assetID: "d", targetPct: 0.05, isLocked: true),
            MAllocation(strategyID: "1", assetID: "e", targetPct: 0.35, isLocked: false),
        ]
        let expected: [MAllocation] = allocs
        for priority in 0 ..< allocs.count {
            try MAllocation.normies(&allocs, controlIndex: priority)
            XCTAssertTrue(areEqual(expected, allocs))
            // XCTAssertEqual(expected, allocs)
        }
    }
}
