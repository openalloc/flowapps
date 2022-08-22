//
//  ConsolidateTests.swift
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

import FlowBase

class ConsolidateTests: XCTestCase {
    var df: ISO8601DateFormatter!
    var timestamp1: Date!
    var timestamp2: Date!
    
    override func setUpWithError() throws {
        df = ISO8601DateFormatter()
        timestamp1 = df.date(from: "2020-06-01T12:00:00Z")!
        timestamp2 = df.date(from: "2020-06-01T13:00:00Z")! // one hour later
    }
    
    func testEliminateZeroNetCashflow() {
        let cashflows = [
            MValuationCashflow(transactedAt: timestamp1, accountID: "1", assetID: "Bond", amount: 1.009999),
            MValuationCashflow(transactedAt: timestamp1, accountID: "1", assetID: "Bond", amount: -1)
        ]
        let actual = MValuationCashflow.consolidateCashflows(cashflows, epsilon: 0.01)
        XCTAssertEqual(0, actual.count)
    }
    
    func testConsolidateIfOutsideEpsilon() {
        let cashflows = [
            MValuationCashflow(transactedAt: timestamp1, accountID: "1", assetID: "Bond", amount: 10.0),
            MValuationCashflow(transactedAt: timestamp1, accountID: "1", assetID: "Bond", amount: -10.2)
        ]
        let actual = MValuationCashflow.consolidateCashflows(cashflows, epsilon: 0.1)
        let expected = MValuationCashflow(transactedAt: timestamp1, accountID: "1", assetID: "Bond", amount: -0.1999999999999993)
        XCTAssertEqual(expected, actual.values.first)
    }
    
    func testDoNotConsolidateIfDiffDates() {
        let cashflows: [MValuationCashflow] = [
            MValuationCashflow(transactedAt: timestamp1, accountID: "1", assetID: "Bond", amount: 1),
            MValuationCashflow(transactedAt: timestamp2, accountID: "1", assetID: "Bond", amount: -1)
        ]
        let actual = MValuationCashflow.consolidateCashflows(cashflows, epsilon: 0.01)
        XCTAssertEqual(cashflows.sorted(), actual.map { $0.value }.sorted())
    }
    
    func testDoNotConsolidateIfDiffAssets() {
        let cashflows = [
            MValuationCashflow(transactedAt: timestamp1, accountID: "1", assetID: "Bond", amount: 1),
            MValuationCashflow(transactedAt: timestamp1, accountID: "1", assetID: "LC", amount: -1)
        ]
        let actual = MValuationCashflow.consolidateCashflows(cashflows, epsilon: 0.01)
        XCTAssertEqual(cashflows.sorted(), actual.map { $0.value }.sorted())
    }
}
