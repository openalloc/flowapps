//
//  AllocPriorityTests.swift
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

final class AllocPriorityTests: XCTestCase {
    func testUnlock7550Priority0() throws {
        var allocs = [
            MAllocation(strategyID: "1", assetID: "a", targetPct: 0.75, isLocked: false), // priority
            MAllocation(strategyID: "1", assetID: "b", targetPct: 0.50, isLocked: false),
        ]
        let expected = [
            MAllocation(strategyID: "1", assetID: "a", targetPct: 0.75, isLocked: false),
            MAllocation(strategyID: "1", assetID: "b", targetPct: 0.25, isLocked: false),
        ]
        try MAllocation.normies(&allocs, controlIndex: 0)
        XCTAssertEqual(expected, allocs)
    }

    func testUnlock7550Priority1() throws {
        var allocs = [
            MAllocation(strategyID: "1", assetID: "a", targetPct: 0.75, isLocked: false),
            MAllocation(strategyID: "1", assetID: "b", targetPct: 0.50, isLocked: false), // priority
        ]
        let expected = [
            MAllocation(strategyID: "1", assetID: "a", targetPct: 0.50, isLocked: false),
            MAllocation(strategyID: "1", assetID: "b", targetPct: 0.50, isLocked: false),
        ]
        try MAllocation.normies(&allocs, controlIndex: 1)
        XCTAssertEqual(expected, allocs)
    }

    func testLock7550Priority0() throws {
        var allocs = [
            MAllocation(strategyID: "1", assetID: "a", targetPct: 0.75, isLocked: true), // priority
            MAllocation(strategyID: "1", assetID: "b", targetPct: 0.50, isLocked: true),
        ]
        let expected = [
            MAllocation(strategyID: "1", assetID: "a", targetPct: 0.75, isLocked: true),
            MAllocation(strategyID: "1", assetID: "b", targetPct: 0.25, isLocked: true),
        ]
        try MAllocation.normies(&allocs, controlIndex: 0)
        XCTAssertEqual(expected, allocs)
    }

    func testLock7550Priority1() throws {
        var allocs = [
            MAllocation(strategyID: "1", assetID: "a", targetPct: 0.75, isLocked: true),
            MAllocation(strategyID: "1", assetID: "b", targetPct: 0.50, isLocked: true), // priority
        ]
        let expected = [
            MAllocation(strategyID: "1", assetID: "a", targetPct: 0.50, isLocked: true),
            MAllocation(strategyID: "1", assetID: "b", targetPct: 0.50, isLocked: true),
        ]
        try MAllocation.normies(&allocs, controlIndex: 1)
        XCTAssertEqual(expected, allocs)
    }

    func testLocked75Unlocked50Priority0() throws {
        var allocs = [
            MAllocation(strategyID: "1", assetID: "a", targetPct: 0.75, isLocked: true), // priority
            MAllocation(strategyID: "1", assetID: "b", targetPct: 0.50, isLocked: false),
        ]
        let expected = [
            MAllocation(strategyID: "1", assetID: "a", targetPct: 0.75, isLocked: true),
            MAllocation(strategyID: "1", assetID: "b", targetPct: 0.25, isLocked: false),
        ]
        try MAllocation.normies(&allocs, controlIndex: 0)
        XCTAssertEqual(expected, allocs)
    }

    func testUnlocked75Locked50Priority0() throws {
        var allocs = [
            MAllocation(strategyID: "1", assetID: "a", targetPct: 0.75, isLocked: false), // priority
            MAllocation(strategyID: "1", assetID: "b", targetPct: 0.50, isLocked: true),
        ]
        let expected = [
            MAllocation(strategyID: "1", assetID: "a", targetPct: 0.50, isLocked: false), // snaps back to 50
            MAllocation(strategyID: "1", assetID: "b", targetPct: 0.50, isLocked: true),
        ]
        try MAllocation.normies(&allocs, controlIndex: 0)
        XCTAssertEqual(expected, allocs)
    }

    func testLocked75Unlocked50Priority1() throws {
        var allocs = [
            MAllocation(strategyID: "1", assetID: "a", targetPct: 0.75, isLocked: true),
            MAllocation(strategyID: "1", assetID: "b", targetPct: 0.50, isLocked: false), // priority
        ]
        let expected = [
            MAllocation(strategyID: "1", assetID: "a", targetPct: 0.75, isLocked: true),
            MAllocation(strategyID: "1", assetID: "b", targetPct: 0.25, isLocked: false), // snaps back to 25
        ]
        try MAllocation.normies(&allocs, controlIndex: 1)
        XCTAssertEqual(expected, allocs)
    }

    func testUnlocked75Locked50Priority1() throws {
        var allocs = [
            MAllocation(strategyID: "1", assetID: "a", targetPct: 0.75, isLocked: false),
            MAllocation(strategyID: "1", assetID: "b", targetPct: 0.50, isLocked: true),
        ]
        let expected = [
            MAllocation(strategyID: "1", assetID: "a", targetPct: 0.50, isLocked: false),
            MAllocation(strategyID: "1", assetID: "b", targetPct: 0.50, isLocked: true),
        ]
        try MAllocation.normies(&allocs, controlIndex: 1)
        XCTAssertEqual(expected, allocs)
    }

    func testDualUnlocked() throws {
        var allocs = [
            MAllocation(strategyID: "1", assetID: "a", targetPct: 1.0, isLocked: false), // priority
            MAllocation(strategyID: "1", assetID: "b", targetPct: 0.4, isLocked: false),
        ]
        let expected = [
            MAllocation(strategyID: "1", assetID: "a", targetPct: 1.0, isLocked: false),
            MAllocation(strategyID: "1", assetID: "b", targetPct: 0.0, isLocked: false),
        ]
        try MAllocation.normies(&allocs, controlIndex: 0)
        XCTAssertEqual(expected, allocs)
    }

    func testTripleLocked() throws {
        var allocs = [
            MAllocation(strategyID: "1", assetID: "a", targetPct: 1.0, isLocked: true), // priority
            MAllocation(strategyID: "1", assetID: "b", targetPct: 0.4, isLocked: true),
            MAllocation(strategyID: "1", assetID: "c", targetPct: 0.1, isLocked: true),
        ]
        let expected = [
            MAllocation(strategyID: "1", assetID: "a", targetPct: 1.0, isLocked: true),
            MAllocation(strategyID: "1", assetID: "b", targetPct: 0.0, isLocked: true),
            MAllocation(strategyID: "1", assetID: "c", targetPct: 0.0, isLocked: true),
        ]
        try MAllocation.normies(&allocs, controlIndex: 0)
        // XCTAssertEqual(expected, allocs)
        XCTAssertTrue(areEqual(expected, allocs))
    }

    func testTripleLocked2() throws {
        var allocs = [
            MAllocation(strategyID: "1", assetID: "a", targetPct: 0.90, isLocked: true), // priority
            MAllocation(strategyID: "1", assetID: "b", targetPct: 0.40, isLocked: true),
            MAllocation(strategyID: "1", assetID: "c", targetPct: 0.10, isLocked: true),
        ]
        let expected = [
            MAllocation(strategyID: "1", assetID: "a", targetPct: 0.90, isLocked: true),
            MAllocation(strategyID: "1", assetID: "b", targetPct: 0.00, isLocked: true),
            MAllocation(strategyID: "1", assetID: "c", targetPct: 0.10, isLocked: true),
        ]
        try MAllocation.normies(&allocs, controlIndex: 0)
        XCTAssertEqual(expected, allocs)
        // XCTAssertTrue(areEqual(expected, allocs))
    }

    func testTripleUnlocked() throws {
        var allocs = [
            MAllocation(strategyID: "1", assetID: "a", targetPct: 1.0, isLocked: false), // priority
            MAllocation(strategyID: "1", assetID: "b", targetPct: 0.4, isLocked: false),
            MAllocation(strategyID: "1", assetID: "c", targetPct: 0.1, isLocked: false),
        ]
        let expected = [
            MAllocation(strategyID: "1", assetID: "a", targetPct: 1.0, isLocked: false),
            MAllocation(strategyID: "1", assetID: "b", targetPct: 0.0, isLocked: false),
            MAllocation(strategyID: "1", assetID: "c", targetPct: 0.0, isLocked: false),
        ]
        try MAllocation.normies(&allocs, controlIndex: 0)
        XCTAssertEqual(expected, allocs)
    }

    func testTripleUnlocked2() throws {
        var allocs = [
            MAllocation(strategyID: "1", assetID: "a", targetPct: 0.90, isLocked: false), // priority
            MAllocation(strategyID: "1", assetID: "b", targetPct: 0.40, isLocked: false),
            MAllocation(strategyID: "1", assetID: "c", targetPct: 0.10, isLocked: false),
        ]
        let expected = [
            MAllocation(strategyID: "1", assetID: "a", targetPct: 0.90, isLocked: false),
            MAllocation(strategyID: "1", assetID: "b", targetPct: 0.08, isLocked: false),
            MAllocation(strategyID: "1", assetID: "c", targetPct: 0.02, isLocked: false),
        ]
        try MAllocation.normies(&allocs, controlIndex: 0)
        XCTAssertTrue(areEqual(expected, allocs))
    }
}
