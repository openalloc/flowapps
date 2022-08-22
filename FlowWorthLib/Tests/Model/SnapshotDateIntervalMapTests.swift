//
//  SnapshotDateIntervalMapTests.swift
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

class SnapshotDateIntervalMapTests: XCTestCase {
    var df: ISO8601DateFormatter!
    var timestamp1a: Date!
    var timestamp1b: Date!
    var timestamp1c: Date!
    var timestamp3b: Date!
    var snapshot1a: MValuationSnapshot!
    var snapshot1b: MValuationSnapshot!
    var snapshot1c: MValuationSnapshot!
    var snapshot3b: MValuationSnapshot!
    let epoch = Date.init(timeIntervalSinceReferenceDate: 0)

    override func setUpWithError() throws {
        df = ISO8601DateFormatter()
        timestamp1a = df.date(from: "2020-06-01T12:00:00Z")! // anchor
        timestamp1b = df.date(from: "2020-06-01T13:00:00Z")! // one hour later
        timestamp1c = df.date(from: "2020-06-01T18:00:00Z")! // six hours later
        timestamp3b = df.date(from: "2020-06-03T12:00:00Z")!
        
        snapshot1a = MValuationSnapshot(snapshotID: "1a", capturedAt: timestamp1a)
        snapshot1b = MValuationSnapshot(snapshotID: "1b", capturedAt: timestamp1b)
        snapshot1c = MValuationSnapshot(snapshotID: "1c", capturedAt: timestamp1c)
        snapshot3b = MValuationSnapshot(snapshotID: "3b", capturedAt: timestamp3b)
    }
    
    func testEmpty() {
        let actual = MValuationSnapshot.getSnapshotDateIntervalMap(orderedSnapshots: [])
        let expected: SnapshotDateIntervalMap = [:]
        XCTAssertEqual(expected, actual)
    }

    func testOneSnapshot() {
        let actual = MValuationSnapshot.getSnapshotDateIntervalMap(orderedSnapshots: [snapshot1a])
        let expected: SnapshotDateIntervalMap = [snapshot1a.primaryKey: DateInterval(start: epoch, end: snapshot1a.capturedAt)]
        XCTAssertEqual(expected, actual)
    }

    func testTwoSnapshots() {
        let actual = MValuationSnapshot.getSnapshotDateIntervalMap(orderedSnapshots: [snapshot1a, snapshot1b])
        let expected: SnapshotDateIntervalMap = [snapshot1a.primaryKey: DateInterval(start: epoch, end: snapshot1a.capturedAt),
                                                 snapshot1b.primaryKey: DateInterval(start: timestamp1a, end: timestamp1b)]
        XCTAssertEqual(expected, actual)
    }
    
    func testThreeSnapshots() {
        let actual = MValuationSnapshot.getSnapshotDateIntervalMap(orderedSnapshots: [snapshot1a, snapshot1b, snapshot3b])
        let expected: SnapshotDateIntervalMap = [
            snapshot1a.primaryKey: DateInterval(start: epoch, end: snapshot1a.capturedAt),
            snapshot1b.primaryKey: DateInterval(start: timestamp1a, end: timestamp1b),
            snapshot3b.primaryKey: DateInterval(start: timestamp1b, end: timestamp3b)]
        XCTAssertEqual(expected, actual)
    }
}
