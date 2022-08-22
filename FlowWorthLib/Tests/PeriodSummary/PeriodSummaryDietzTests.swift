//
//  PeriodSummaryDietzTests.swift
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

class PeriodSummaryDietzTests: XCTestCase {
    
    var tz: TimeZone!
    var df: ISO8601DateFormatter!
    var timestamp1a: Date!
    var timestamp1b: Date!
    var timestamp1c: Date!
    var timestamp2a: Date!
    var timestamp2b: Date!

    override func setUpWithError() throws {
        tz = TimeZone.init(identifier: "EST")!
        df = ISO8601DateFormatter()
        timestamp1a = df.date(from: "2020-06-01T12:00:00Z")! // anchor
        timestamp1b = df.date(from: "2020-06-01T13:00:00Z")! // one hour later
        timestamp1c = df.date(from: "2020-06-01T18:00:00Z")! // six hours later
        timestamp2a = df.date(from: "2020-06-02T12:00:00Z")! // one day later
        timestamp2b = df.date(from: "2020-06-03T00:00:01Z")! // one day, 12 hours and one second later
    }
    
    func testNoHoldings() throws {
        let period = DateInterval(start: timestamp1a, end: timestamp2a)
        let ps = PeriodSummary(period: period, begPositions: [], endPositions: [], cashflows: [])
        XCTAssertTrue( ps.dietz!.performance.isNaN)
    }
}
