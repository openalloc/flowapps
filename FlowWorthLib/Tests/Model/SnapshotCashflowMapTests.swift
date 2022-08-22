//
//  SnapshotCashflowMapTests.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

@testable import FlowWorthLib
import XCTest

import AllocData

import FlowBase

class SnapshotCashflowMapTests: XCTestCase {
    var df: ISO8601DateFormatter!
    var timestamp1: Date!
    var timestamp2: Date!
    var timestamp3: Date!
    var timestamp4: Date!
    var model: BaseModel!
    var ax: WorthContext!

    override func setUpWithError() throws {
        df = ISO8601DateFormatter()
        timestamp1 = df.date(from: "2020-06-01T12:00:00Z")!
        timestamp2 = df.date(from: "2020-06-01T13:00:00Z")! // one hour later
        timestamp3 = df.date(from: "2020-06-01T13:00:01Z")! // one hour and one second later
        timestamp4 = df.date(from: "2020-06-02T12:00:00Z")! // one day later
        model = BaseModel()
        ax = WorthContext(model)
    }
    
    func testEmpty() {
        let actual = MValuationCashflow.getSnapshotCashflowsMap(orderedSnapshots: [], orderedCashflows: [], snapshotDateIntervalMap: [:])
        let expected: SnapshotCashflowsMap = [:]
        XCTAssertEqual(expected, actual)
    }
    
    func testOneSnapshot() {
        let snapshot = MValuationSnapshot(snapshotID: "1", capturedAt: timestamp1)
        let actual = MValuationCashflow.getSnapshotCashflowsMap(orderedSnapshots: [snapshot], orderedCashflows: [], snapshotDateIntervalMap: [:])
        let expected: SnapshotCashflowsMap = [snapshot.primaryKey: []]
        XCTAssertEqual(expected, actual)
    }
    
    func testOneSnapshotAndOneCashflow() {
        let snapshot1 = MValuationSnapshot(snapshotID: "1", capturedAt: timestamp1)
        let cashflow1 = MValuationCashflow(transactedAt: timestamp1, accountID: "1", assetID: "Bond")
        let actual = MValuationCashflow.getSnapshotCashflowsMap(orderedSnapshots: [snapshot1], orderedCashflows: [cashflow1], snapshotDateIntervalMap: [:])
        let expected: SnapshotCashflowsMap = [snapshot1.primaryKey: []]
        XCTAssertEqual(expected, actual)
    }
    
    func testTwoSnapshotsAndOneCashflowOutOfRangePrior() {
        let snapshot1 = MValuationSnapshot(snapshotID: "1", capturedAt: timestamp1)
        let snapshot2 = MValuationSnapshot(snapshotID: "2", capturedAt: timestamp2)
        let snapshots = [snapshot1, snapshot2]
        let cashflow1 = MValuationCashflow(transactedAt: timestamp1, accountID: "1", assetID: "Bond")
        let map = MValuationSnapshot.getSnapshotDateIntervalMap(orderedSnapshots: snapshots[...])
        let actual = MValuationCashflow.getSnapshotCashflowsMap(orderedSnapshots: snapshots[...], orderedCashflows: [cashflow1], snapshotDateIntervalMap: map)
        let expected: SnapshotCashflowsMap = [snapshot1.primaryKey: []]
        XCTAssertEqual(expected, actual)
    }
    
    func testTwoSnapshotsAndOneCashflowOutOfRangeFollowing() {
        let snapshot1 = MValuationSnapshot(snapshotID: "1", capturedAt: timestamp1)
        let snapshot2 = MValuationSnapshot(snapshotID: "2", capturedAt: timestamp2)
        let snapshots = [snapshot1, snapshot2]
        let cashflow1 = MValuationCashflow(transactedAt: timestamp3, accountID: "1", assetID: "Bond")
        let map = MValuationSnapshot.getSnapshotDateIntervalMap(orderedSnapshots: snapshots[...])
        let actual = MValuationCashflow.getSnapshotCashflowsMap(orderedSnapshots: snapshots[...], orderedCashflows: [cashflow1], snapshotDateIntervalMap: map)
        let expected: SnapshotCashflowsMap = [snapshot1.primaryKey: []]
        XCTAssertEqual(expected, actual)
    }

    func testTwoSnapshotsAndOneCashflowInRange() {
        let snapshot1 = MValuationSnapshot(snapshotID: "1", capturedAt: timestamp1)
        let snapshot2 = MValuationSnapshot(snapshotID: "2", capturedAt: timestamp2)
        let snapshots = [snapshot1, snapshot2]
        let cashflow1 = MValuationCashflow(transactedAt: timestamp2, accountID: "1", assetID: "Bond")
        let map = MValuationSnapshot.getSnapshotDateIntervalMap(orderedSnapshots: snapshots[...])
        let actual = MValuationCashflow.getSnapshotCashflowsMap(orderedSnapshots: snapshots[...], orderedCashflows: [cashflow1], snapshotDateIntervalMap: map)
        let expected: SnapshotCashflowsMap = [snapshot1.primaryKey: [],
                                              snapshot2.primaryKey: [cashflow1]]
        XCTAssertEqual(expected, actual)
    }
    
    func testBeforeStart() {
        let snapshot2 = MValuationSnapshot(snapshotID: "2", capturedAt: timestamp2)
        let snapshot3 = MValuationSnapshot(snapshotID: "3", capturedAt: timestamp3)
        let snapshots = [snapshot2, snapshot3]
        let cashflow1 = MValuationCashflow(transactedAt: timestamp1, accountID: "1", assetID: "Bond", amount: 1) // should skip
        let cashflow3 = MValuationCashflow(transactedAt: timestamp3, accountID: "1", assetID: "Bond", amount: 3) // should hit
        let map = MValuationSnapshot.getSnapshotDateIntervalMap(orderedSnapshots: snapshots[...])
        let actual = MValuationCashflow.getSnapshotCashflowsMap(orderedSnapshots: snapshots[...], orderedCashflows: [cashflow1, cashflow3], snapshotDateIntervalMap: map)
        let expected: SnapshotCashflowsMap = [snapshot2.primaryKey: [],
                                              snapshot3.primaryKey: [cashflow3]]
        XCTAssertEqual(expected, actual)
    }
    
    func testEnsureSecondSnapshotGetsLeftoverCashflow() {
        // note that cashflow1 is exclusive of snapshot at timestamp1, so it's not in results
        let snapshot1 = MValuationSnapshot(snapshotID: "1", capturedAt: timestamp1)
        let snapshot2 = MValuationSnapshot(snapshotID: "2", capturedAt: timestamp2)
        let snapshot3 = MValuationSnapshot(snapshotID: "3", capturedAt: timestamp3)
        let snapshots = [snapshot1, snapshot2, snapshot3]
        let cashflow1 = MValuationCashflow(transactedAt: timestamp1, accountID: "1", assetID: "Bond", amount: 1)
        let cashflow2 = MValuationCashflow(transactedAt: timestamp2, accountID: "1", assetID: "Bond", amount: 2)
        let cashflow3 = MValuationCashflow(transactedAt: timestamp3, accountID: "1", assetID: "Bond", amount: 3)
        let map = MValuationSnapshot.getSnapshotDateIntervalMap(orderedSnapshots: snapshots[...])
        let actual = MValuationCashflow.getSnapshotCashflowsMap(orderedSnapshots: snapshots[...], orderedCashflows: [cashflow1, cashflow2, cashflow3], snapshotDateIntervalMap: map)
        let expected: SnapshotCashflowsMap = [snapshot1.primaryKey: [],
                                              snapshot2.primaryKey: [cashflow2],
                                              snapshot3.primaryKey: [cashflow3]]
        XCTAssertEqual(expected, actual)
    }
}
