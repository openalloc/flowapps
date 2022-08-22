//
//  AllocNoPriorityTests.swift
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

final class AllocNoPriorityTests: XCTestCase {
    func testEmpty() throws {
        var allocs: [MAllocation] = []
        try MAllocation.normies(&allocs)
        let expected: [MAllocation] = []
        XCTAssertEqual(expected, allocs) // unable to do anything
    }

    func testOneLock() throws {
        var allocs: [MAllocation] = [MAllocation(strategyID: "1", assetID: "a", targetPct: 0.0, isLocked: true)]
        try MAllocation.normies(&allocs)
        let expected: [MAllocation] = [MAllocation(strategyID: "1", assetID: "a", targetPct: 1.0, isLocked: true)]
        XCTAssertEqual(expected, allocs)
    }

    func testOneUnlock() throws {
        var allocs: [MAllocation] = [MAllocation(strategyID: "1", assetID: "a", targetPct: 0.0, isLocked: false)]
        try MAllocation.normies(&allocs)
        let expected: [MAllocation] = [MAllocation(strategyID: "1", assetID: "a", targetPct: 1.0, isLocked: false)]
        XCTAssertEqual(expected, allocs)
    }

    func testLock1Unlock0() throws {
        var allocs: [MAllocation] = [MAllocation(strategyID: "1", assetID: "a", targetPct: 1.0, isLocked: true), MAllocation(strategyID: "1", assetID: "b", targetPct: 1.0, isLocked: false)]
        try MAllocation.normies(&allocs)
        let expected: [MAllocation] = [MAllocation(strategyID: "1", assetID: "a", targetPct: 1.0, isLocked: true), MAllocation(strategyID: "1", assetID: "b", targetPct: 0.0, isLocked: false)]
        XCTAssertEqual(expected, allocs)
    }

    func testLock0Unlock1() throws {
        var allocs: [MAllocation] = [MAllocation(strategyID: "1", assetID: "a", targetPct: 0.0, isLocked: true), MAllocation(strategyID: "1", assetID: "b", targetPct: 0.0, isLocked: false)]
        try MAllocation.normies(&allocs)
        let expected: [MAllocation] = [MAllocation(strategyID: "1", assetID: "a", targetPct: 0.0, isLocked: true), MAllocation(strategyID: "1", assetID: "b", targetPct: 1.0, isLocked: false)]
        XCTAssertEqual(expected, allocs)
    }

    func testLockTooBig() throws {
        var allocs: [MAllocation] = [MAllocation(strategyID: "1", assetID: "a", targetPct: 1.1, isLocked: true)]
        XCTAssertThrowsError(try MAllocation.normies(&allocs)) { error in
            XCTAssertEqual(error as! FlowBaseError, FlowBaseError.invalidPercent(1.1, "a"))
        }
    }

    func testUnlockTooBig() throws {
        var allocs: [MAllocation] = [MAllocation(strategyID: "1", assetID: "a", targetPct: 1.1, isLocked: false)]
        XCTAssertThrowsError(try MAllocation.normies(&allocs)) { error in
            XCTAssertEqual(error as! FlowBaseError, FlowBaseError.invalidPercent(1.1, "a"))
        }
    }

    func testLock0UnlockTooBig() throws {
        var allocs: [MAllocation] = [MAllocation(strategyID: "1", assetID: "a", targetPct: 0.0, isLocked: true), MAllocation(strategyID: "1", assetID: "b", targetPct: 1.1, isLocked: false)]
        XCTAssertThrowsError(try MAllocation.normies(&allocs)) { error in
            XCTAssertEqual(error as! FlowBaseError, FlowBaseError.invalidPercent(1.1, "b"))
        }
    }

    func testUnlock0LockTooBig() throws {
        var allocs: [MAllocation] = [MAllocation(strategyID: "1", assetID: "a", targetPct: 0.0, isLocked: false), MAllocation(strategyID: "1", assetID: "b", targetPct: 1.1, isLocked: true)]
        XCTAssertThrowsError(try MAllocation.normies(&allocs)) { error in
            XCTAssertEqual(error as! FlowBaseError, FlowBaseError.invalidPercent(1.1, "b"))
        }
    }

    func testLock1UnlockTooBig2() throws {
        var allocs: [MAllocation] = [MAllocation(strategyID: "1", assetID: "a", targetPct: 1.0, isLocked: true), MAllocation(strategyID: "1", assetID: "b", targetPct: 2.0, isLocked: false)]
        XCTAssertThrowsError(try MAllocation.normies(&allocs)) { error in
            XCTAssertEqual(error as! FlowBaseError, FlowBaseError.invalidPercent(2.0, "b"))
        }
    }

    func testUnlock1LockTooBig() throws {
        var allocs: [MAllocation] = [MAllocation(strategyID: "1", assetID: "a", targetPct: 1.0, isLocked: false), MAllocation(strategyID: "1", assetID: "b", targetPct: 2.0, isLocked: true)]
        XCTAssertThrowsError(try MAllocation.normies(&allocs)) { error in
            XCTAssertEqual(error as! FlowBaseError, FlowBaseError.invalidPercent(2.0, "b"))
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
        try MAllocation.normies(&allocs)
        XCTAssertEqual(expected, allocs)
    }

    func testUnlocked7550() throws {
        var allocs = [
            MAllocation(strategyID: "1", assetID: "a", targetPct: 0.75, isLocked: false),
            MAllocation(strategyID: "1", assetID: "b", targetPct: 0.50, isLocked: false),
        ]
        let expected = [
            MAllocation(strategyID: "1", assetID: "a", targetPct: 0.60, isLocked: false),
            MAllocation(strategyID: "1", assetID: "b", targetPct: 0.40, isLocked: false),
        ]
        try MAllocation.normies(&allocs)
        XCTAssertEqual(expected, allocs)
    }

    func testLocked7550() throws {
        var allocs = [
            MAllocation(strategyID: "1", assetID: "a", targetPct: 0.75, isLocked: true),
            MAllocation(strategyID: "1", assetID: "b", targetPct: 0.50, isLocked: true),
        ]
        let expected = [
            MAllocation(strategyID: "1", assetID: "a", targetPct: 0.5, isLocked: true),
            MAllocation(strategyID: "1", assetID: "b", targetPct: 0.5, isLocked: true),
        ]
        try MAllocation.normies(&allocs)
        XCTAssertEqual(expected, allocs)
    }

    func testLocked75Unlocked50() throws {
        var allocs = [
            MAllocation(strategyID: "1", assetID: "a", targetPct: 0.75, isLocked: true),
            MAllocation(strategyID: "1", assetID: "b", targetPct: 0.50, isLocked: false),
        ]
        let expected = [
            MAllocation(strategyID: "1", assetID: "a", targetPct: 0.75, isLocked: true),
            MAllocation(strategyID: "1", assetID: "b", targetPct: 0.25, isLocked: false),
        ]
        try MAllocation.normies(&allocs)
        XCTAssertEqual(expected, allocs)
    }

    func testUnlocked75Locked50() throws {
        var allocs = [
            MAllocation(strategyID: "1", assetID: "a", targetPct: 0.75, isLocked: false),
            MAllocation(strategyID: "1", assetID: "b", targetPct: 0.50, isLocked: true),
        ]
        let expected = [
            MAllocation(strategyID: "1", assetID: "a", targetPct: 0.50, isLocked: false),
            MAllocation(strategyID: "1", assetID: "b", targetPct: 0.50, isLocked: true),
        ]
        try MAllocation.normies(&allocs)
        XCTAssertEqual(expected, allocs)
    }
}
