//
//  MValuationCashflowUtilsTests.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

@testable import FlowWorthLib
import XCTest

import AllocData

class MValuationCashflowUtilsTests: XCTestCase {
    var df: ISO8601DateFormatter!
    var timestamp1: Date!
    var timestamp2: Date!

    override func setUpWithError() throws {
        df = ISO8601DateFormatter()
        timestamp1 = df.date(from: "2020-01-31T12:00:00Z")!
        timestamp2 = df.date(from: "2020-01-31T13:00:00Z")!
    }
    
    func testAttributes() {
        let txn = MValuationCashflow(transactedAt: timestamp1, accountID: "1", assetID: "Bond", amount: 100)

        XCTAssertEqual(timestamp1, txn.transactedAt)
        XCTAssertEqual("1", txn.accountID)
        XCTAssertEqual("Bond", txn.assetID)
        XCTAssertEqual(100, txn.amount)
    }
    
    func testCashflowPeriodNoBeg() {
        let actual = MValuationCashflow.getCashflowPeriod(begCapturedAt: nil, endCapturedAt: timestamp2)
        XCTAssertNil(actual)
    }
    
    func testCashflowPeriodBegEnd() {
        let actual = MValuationCashflow.getCashflowPeriod(begCapturedAt: timestamp1, endCapturedAt: timestamp1)
        XCTAssertNil(actual)
    }

    func testCashflowPeriodBegLessThanEnd() {
        let actual = MValuationCashflow.getCashflowPeriod(begCapturedAt: timestamp1, endCapturedAt: timestamp2)
        let expected = DateInterval(start: timestamp1.addingTimeInterval(60), end: timestamp2)
        XCTAssertEqual(expected, actual)
    }
}
