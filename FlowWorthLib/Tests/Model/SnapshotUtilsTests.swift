//
//  SnapshotUtilsTests.swift
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

class SnapshotUtilsTests: XCTestCase {
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
        timestamp2 = df.date(from: "2020-06-15T12:00:00Z")!
        timestamp3 = df.date(from: "2020-06-20T12:00:00Z")!
        timestamp4 = df.date(from: "2020-06-30T12:00:00Z")!
        model = BaseModel()
        ax = WorthContext(model)
    }

    func testLatestSnapshot() throws {
        XCTAssertNil(model.orderedSnapshots.last)
        let a = MValuationSnapshot(snapshotID: "A", capturedAt: timestamp2)
        let b = MValuationSnapshot(snapshotID: "B", capturedAt: timestamp1)
        model.valuationSnapshots = [a, b]
        let actual = model.orderedSnapshots.last
        XCTAssertEqual(a, actual)
    }
    
    func testGetSnapshotsByDate() throws {
        let snapshot1 = MValuationSnapshot(snapshotID: "1", capturedAt: timestamp1)
        let snapshot2 = MValuationSnapshot(snapshotID: "2", capturedAt: timestamp4)

        model.valuationSnapshots = [snapshot1, snapshot2]
        ax = WorthContext(model)
        
        let actual = MValuationSnapshot.getSnapshotsByDate(snapshotDateIntervalMap: ax.snapshotDateIntervalMap)
        let expected: [Date: SnapshotKey] = [timestamp1: snapshot1.primaryKey,
                                             timestamp4: snapshot2.primaryKey]
        XCTAssertEqual(expected, actual)
    }
    
    func testGetPreviousSnapshotKeyMap() throws {
        let snapshot1 = MValuationSnapshot(snapshotID: "1", capturedAt: timestamp1)
        let snapshot2 = MValuationSnapshot(snapshotID: "2", capturedAt: timestamp2)
        let snapshot3 = MValuationSnapshot(snapshotID: "3", capturedAt: timestamp3)
        let snapshot4 = MValuationSnapshot(snapshotID: "4", capturedAt: timestamp4)

        model.valuationSnapshots = [snapshot1, snapshot2, snapshot3, snapshot4]
        ax = WorthContext(model)
        
        let actual = MValuationSnapshot.getPreviousSnapshotKeyMap(snapshotDateIntervalMap: ax.snapshotDateIntervalMap)
        let expected: [SnapshotKey: SnapshotKey] = [snapshot2.primaryKey: snapshot1.primaryKey,
                                                    snapshot3.primaryKey: snapshot2.primaryKey,
                                                    snapshot4.primaryKey: snapshot3.primaryKey,
                                                    snapshot1.primaryKey: MValuationSnapshot.Key.empty]
        XCTAssertEqual(expected, actual)
    }
}
