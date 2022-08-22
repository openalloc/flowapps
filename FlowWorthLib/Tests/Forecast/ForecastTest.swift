//
//  ForecastTests.swift
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

class ForecastTests: XCTestCase {
    
    var tz: TimeZone!
    var df: ISO8601DateFormatter!
    var timestamp1a: Date!
    var timestamp1b: Date!
    var timestamp1c: Date!
    var timestamp2a: Date!
    var timestamp2b: Date!
    var timestamp3a: Date!
    var timestamp3b: Date!
    var snapshot1a: MValuationSnapshot!
    var snapshot1b: MValuationSnapshot!
    var snapshot1c: MValuationSnapshot!
    var snapshot2a: MValuationSnapshot!
    var snapshot2b: MValuationSnapshot!
    var snapshot3a: MValuationSnapshot!
    var snapshot3b: MValuationSnapshot!

    var model: BaseModel!
    var ax: WorthContext!

    override func setUpWithError() throws {
        tz = TimeZone.init(identifier: "EST")!
        df = ISO8601DateFormatter()
        timestamp1a = df.date(from: "2020-06-01T12:00:00Z")! // anchor
        timestamp1b = df.date(from: "2020-06-01T13:00:00Z")! // one hour later
        timestamp1c = df.date(from: "2020-06-01T18:00:00Z")! // six hours later
        timestamp2a = df.date(from: "2020-06-02T12:00:00Z")! // one day later
        timestamp2b = df.date(from: "2020-06-03T00:00:01Z")! // one day, 12 hours and one second later
        timestamp3a = df.date(from: "2020-06-03T06:00:00Z")! // one day beyond start of day (for 2a)
        timestamp3b = df.date(from: "2020-06-03T12:00:00Z")!
        
        snapshot1a = MValuationSnapshot(snapshotID: "1a", capturedAt: timestamp1a)
        snapshot1b = MValuationSnapshot(snapshotID: "1b", capturedAt: timestamp1b)
        snapshot1c = MValuationSnapshot(snapshotID: "1c", capturedAt: timestamp1c)
        snapshot2a = MValuationSnapshot(snapshotID: "2a", capturedAt: timestamp2a)
        snapshot2b = MValuationSnapshot(snapshotID: "2b", capturedAt: timestamp2b)
        snapshot3a = MValuationSnapshot(snapshotID: "3a", capturedAt: timestamp3a)
        snapshot3b = MValuationSnapshot(snapshotID: "3b", capturedAt: timestamp3b)
        
        model = BaseModel()
        ax = WorthContext(model)
    }
}
