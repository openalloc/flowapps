//
//  MissingHoldingsTests.swift
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

class MissingHoldingsTests: XCTestCase {
    var tz: TimeZone!
    var df: ISO8601DateFormatter!
    var timestamp1a: Date!
    var timestamp1b: Date!
    var timestamp2a: Date!
    var timestamp2b: Date!
    var timestamp3a: Date!
    var model: BaseModel!
    var ax: WorthContext!

    override func setUpWithError() throws {
        tz = TimeZone.init(identifier: "EST")!
        df = ISO8601DateFormatter()
        timestamp1a = df.date(from: "2020-06-01T12:00:00Z")! // anchor
        timestamp1b = df.date(from: "2020-06-01T13:00:00Z")! // one hour later
        timestamp2a = df.date(from: "2020-06-02T12:00:00Z")! // one day later
        timestamp2b = df.date(from: "2020-06-03T00:00:01Z")! // one day, 12 hours and one second later
        timestamp3a = df.date(from: "2020-06-03T06:00:00Z")! // one day beyond start of day (for 2a)
        model = BaseModel()
        ax = WorthContext(model)
    }

    func testSimple() throws {
        let asset = MAsset(assetID: "Bond", title: "Aggregate Bonds")
        let security = MSecurity(securityID: "AGG", assetID: "Bond", sharePrice: 7)
        let account = MAccount(accountID: "1")
        let holding = MHolding(accountID: "1", securityID: "AGG", lotID: "", shareCount: 5, shareBasis: 7)
        model.assets = [asset]
        model.securities = [security]
        model.accounts = [account]
        model.holdings = [holding]
        ax = WorthContext(model)
        let pending1 = PendingSnapshot(timestamp: timestamp1a)
        try model.commitPendingSnapshot(pending1)
        
        //XCTAssertEqual(1, model.valuationHoldings.count)
        
        // clear out the 'helper' records
        //model.valuationHoldings = []
        
        // same holdings as in first snapshot
        model.holdings = [holding]
        ax = WorthContext(model)
        
        let pending2 = PendingSnapshot(timestamp: timestamp2a)
        try model.commitPendingSnapshot(pending2)
        
        let expectedCF: [MValuationCashflow] = [
            //MValuationCashflow(transactedAt: timestamp2a, accountID: "1", assetID: "Bond", amount: -1 * 5 * 7, reconciled: true)
        ]
        
        XCTAssertEqual(expectedCF, model.valuationCashflows)
    }

}
