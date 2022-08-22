//
//  MatrixResultFilterTests.swift
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

class MatrixResultFilterTests: XCTestCase {
    var tz: TimeZone!
    var df: ISO8601DateFormatter!
    var timestamp1a: Date!
    var timestamp1b: Date!
    var timestamp2a: Date!
    var timestamp2b: Date!
    var timestamp3a: Date!
    var snapshot1a: MValuationSnapshot!
    var snapshot1b: MValuationSnapshot!
    var snapshot2a: MValuationSnapshot!
    var snapshot2b: MValuationSnapshot!
    var snapshot3a: MValuationSnapshot!
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

        snapshot1a = MValuationSnapshot(snapshotID: "1a", capturedAt: timestamp1a)
        snapshot1b = MValuationSnapshot(snapshotID: "1b", capturedAt: timestamp1b)
        snapshot2a = MValuationSnapshot(snapshotID: "2a", capturedAt: timestamp2a)
        snapshot2b = MValuationSnapshot(snapshotID: "2b", capturedAt: timestamp2b)
        snapshot3a = MValuationSnapshot(snapshotID: "3a", capturedAt: timestamp3a)

        model = BaseModel()
        ax = WorthContext(model)
    }
        
    func testTwoAccountsOneFiltered() throws {
        let asset1 = MAsset(assetID: "Bond")
        let security1 = MSecurity(securityID: "BND", assetID: "Bond", sharePrice: 3)
        let security2 = MSecurity(securityID: "AGG", assetID: "Bond", sharePrice: 17)
        let account1 = MAccount(accountID: "1")
        let account2 = MAccount(accountID: "2")
        let holding1 = MHolding(accountID: "1", securityID: "BND", lotID: "", shareCount: 5, shareBasis: 7)
        let holding2 = MHolding(accountID: "2", securityID: "AGG", lotID: "", shareCount: 11, shareBasis: 13)
        model.assets = [asset1]
        model.securities = [security1, security2]
        model.accounts = [account1, account2]
        
        model.holdings = [holding1, holding2]
        ax = WorthContext(model)
        let pending1 = PendingSnapshot(snapshotID: "1a", timestamp: timestamp1a, holdings: [holding1, holding2], assetMap: ax.assetMap, securityMap: ax.securityMap)
        try model.commitPendingSnapshot(pending1)
        
        model.holdings = [holding1, holding2]
        ax = WorthContext(model)
        let pending2 = PendingSnapshot(snapshotID: "2a", timestamp: timestamp2a, holdings: [holding1, holding2], assetMap: ax.assetMap, securityMap: ax.securityMap)
        try model.commitPendingSnapshot(pending2)
        
        ax = WorthContext(model)
        
        let mr = MatrixResult(orderedSnapshots: ax.orderedSnapshots[...],
                              rawOrderedCashflow: ax.orderedCashflow,
                              valuationPositions: ax.model.valuationPositions,
                              accountKeyFilter: { $0 != MAccount.Key(accountID: "1") }) // exclude account "1"
    
        let val: Double = 17 * 11
        XCTAssertEqual([MAsset.Key(assetID: "Bond"): [val, val]], mr.matrixValuesByAsset)
        XCTAssertEqual([snapshot1a, snapshot2a], mr.orderedSnapshots)
        XCTAssertEqual(val...val, mr.marketValueRange)
        XCTAssertEqual([MAccount.Key(accountID: "2")], mr.orderedAccountKeys)

    }    
}
