//
//  MatrixResultTests.swift
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

class MatrixResultTests: XCTestCase {
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
    
    func testNoHoldings() throws {
        ax = WorthContext(model)
        let pending1 = PendingSnapshot(timestamp: timestamp1a)
        try model.commitPendingSnapshot(pending1)

        ax = WorthContext(model)
        let pending2 = PendingSnapshot(timestamp: timestamp2a)
        try model.commitPendingSnapshot(pending2)

        ax = WorthContext(model)

        let mr = MatrixResult(orderedSnapshots: ax.orderedSnapshots[...],
                              rawOrderedCashflow: ax.orderedCashflow,
                              valuationPositions: ax.model.valuationPositions)
        XCTAssertEqual([:], mr.matrixValuesByAsset)
        XCTAssertEqual([timestamp1a, timestamp2a], mr.capturedAts)
        XCTAssertEqual(0.0...0.0, mr.marketValueRange)
        XCTAssertEqual([], mr.orderedAccountKeys)
        XCTAssertTrue(mr.periodSummary!.dietz!.performance.isNaN)
    }

    func testOnePositiveAssetNoChange() throws {
        let asset1 = MAsset(assetID: "Bond")
        let security1 = MSecurity(securityID: "BND", assetID: "Bond", sharePrice: 3)
        let account1 = MAccount(accountID: "1")
        let holding1 = MHolding(accountID: "1", securityID: "BND", lotID: "", shareCount: 5, shareBasis: 7)
        model.assets = [asset1]
        model.securities = [security1]
        model.accounts = [account1]

        model.holdings = [holding1]
        ax = WorthContext(model)
        let pending1 = PendingSnapshot(snapshotID: "1a", timestamp: timestamp1a, holdings: [holding1], assetMap: ax.assetMap, securityMap: ax.securityMap)
        try model.commitPendingSnapshot(pending1)

        model.holdings = [holding1]
        ax = WorthContext(model)
        let pending2 = PendingSnapshot(snapshotID: "2a", timestamp: timestamp2a, holdings: [holding1], assetMap: ax.assetMap, securityMap: ax.securityMap)
        try model.commitPendingSnapshot(pending2)

        ax = WorthContext(model)

        let mr = MatrixResult(orderedSnapshots: ax.orderedSnapshots[...],
                              rawOrderedCashflow: ax.orderedCashflow,
                              valuationPositions: ax.model.valuationPositions)
        XCTAssertEqual([MAsset.Key(assetID: "Bond"): [15, 15]], mr.matrixValuesByAsset)
        XCTAssertEqual([snapshot1a, snapshot2a], mr.orderedSnapshots)
        XCTAssertEqual(15...15, mr.marketValueRange)
        XCTAssertEqual([MAccount.Key(accountID: "1")], mr.orderedAccountKeys)
        XCTAssertEqual(0, mr.periodSummary!.dietz!.performance)
    }
    
    func testOneNegativeAssetNoChange() throws {
        let asset1 = MAsset(assetID: "Bond")
        let security1 = MSecurity(securityID: "BND", assetID: "Bond", sharePrice: 3)
        let account1 = MAccount(accountID: "1")
        let holding1 = MHolding(accountID: "1", securityID: "BND", lotID: "", shareCount: -5, shareBasis: 7) // liability (short position)
        model.assets = [asset1]
        model.securities = [security1]
        model.accounts = [account1]

        model.holdings = [holding1]
        ax = WorthContext(model)
        let pending1 = PendingSnapshot(snapshotID: "1a", timestamp: timestamp1a, holdings: [holding1], assetMap: ax.assetMap, securityMap: ax.securityMap)
        try model.commitPendingSnapshot(pending1)

        model.holdings = [holding1]
        ax = WorthContext(model)
        let pending2 = PendingSnapshot(snapshotID: "2a", timestamp: timestamp2a, holdings: [holding1], assetMap: ax.assetMap, securityMap: ax.securityMap)
        try model.commitPendingSnapshot(pending2)

        ax = WorthContext(model)

        let mr = MatrixResult(orderedSnapshots: ax.orderedSnapshots[...],
                              rawOrderedCashflow: ax.orderedCashflow,
                              valuationPositions: ax.model.valuationPositions)
        XCTAssertEqual([MAsset.Key(assetID: "Bond"): [-15, -15]], mr.matrixValuesByAsset)
        XCTAssertEqual([snapshot1a, snapshot2a], mr.orderedSnapshots)
        XCTAssertEqual((-15)...(-15), mr.marketValueRange)
        XCTAssertEqual([MAccount.Key(accountID: "1")], mr.orderedAccountKeys)
        XCTAssertEqual(0, mr.periodSummary!.dietz!.performance)
    }
    
    func testTwoPositiveAssets() throws {
        let asset1 = MAsset(assetID: "Bond")
        let asset2 = MAsset(assetID: "LC")
        let account1 = MAccount(accountID: "1")
        let security1a = MSecurity(securityID: "BND", assetID: "Bond", sharePrice: 5)
        let security1b = MSecurity(securityID: "VOO", assetID: "LC", sharePrice: 10)
        let holding1a = MHolding(accountID: "1", securityID: "BND", lotID: "", shareCount: 10, shareBasis: 1)
        let holding1b = MHolding(accountID: "1", securityID: "VOO", lotID: "", shareCount: 20, shareBasis: 1)
        model.assets = [asset1, asset2]
        model.accounts = [account1]
        model.securities = [security1a, security1b]
        model.holdings = [holding1a, holding1b]
        ax = WorthContext(model)
        let pending1 = PendingSnapshot(snapshotID: "1a", timestamp: timestamp1a, holdings: [holding1a, holding1b], assetMap: ax.assetMap, securityMap: ax.securityMap)
        try model.commitPendingSnapshot(pending1)

        let security2a = MSecurity(securityID: "BND", assetID: "Bond", sharePrice: 10)
        let security2b = MSecurity(securityID: "VOO", assetID: "LC", sharePrice: 20)
        let holding2a = MHolding(accountID: "1", securityID: "BND", lotID: "", shareCount: 10, shareBasis: 1)
        let holding2b = MHolding(accountID: "1", securityID: "VOO", lotID: "", shareCount: 20, shareBasis: 1)
        model.securities = [security2a, security2b]
        model.holdings = [holding2a, holding2b]
        ax = WorthContext(model)
        let pending2 = PendingSnapshot(snapshotID: "2a", timestamp: timestamp2a, holdings: [holding2a, holding2b], assetMap: ax.assetMap, securityMap: ax.securityMap)
        try model.commitPendingSnapshot(pending2)
        ax = WorthContext(model)

        let mr = MatrixResult(orderedSnapshots: ax.orderedSnapshots[...],
                              rawOrderedCashflow: ax.orderedCashflow,
                              valuationPositions: ax.model.valuationPositions)
        XCTAssertEqual([MAsset.Key(assetID: "Bond"): [50, 100], MAsset.Key(assetID: "LC"): [200, 400]], mr.matrixValuesByAsset)
        XCTAssertEqual([snapshot1a, snapshot2a], mr.orderedSnapshots)
        XCTAssertEqual(250...500, mr.marketValueRange)
        XCTAssertEqual([MAccount.Key(accountID: "1")], mr.orderedAccountKeys)
        XCTAssertEqual(1.0, mr.periodSummary!.dietz!.performance) // share price doubled (+100%)
    }
    
    func testOnePositiveOneNegativeAssets() throws {
        let asset1 = MAsset(assetID: "Bond")
        let asset2 = MAsset(assetID: "LC")
        let account1 = MAccount(accountID: "1")
        let security1a = MSecurity(securityID: "BND", assetID: "Bond", sharePrice: 5)
        let security1b = MSecurity(securityID: "VOO", assetID: "LC", sharePrice: 10)
        let holding1a = MHolding(accountID: "1", securityID: "BND", lotID: "", shareCount: 10, shareBasis: 1)
        let holding1b = MHolding(accountID: "1", securityID: "VOO", lotID: "", shareCount: -20, shareBasis: 1)
        model.assets = [asset1, asset2]
        model.accounts = [account1]
        model.securities = [security1a, security1b]
        model.holdings = [holding1a, holding1b]
        ax = WorthContext(model)
        let pending1 = PendingSnapshot(snapshotID: "1a", timestamp: timestamp1a, holdings: [holding1a, holding1b], assetMap: ax.assetMap, securityMap: ax.securityMap)
        try model.commitPendingSnapshot(pending1)

        let security2a = MSecurity(securityID: "BND", assetID: "Bond", sharePrice: 10)
        let security2b = MSecurity(securityID: "VOO", assetID: "LC", sharePrice: 20)
        let holding2a = MHolding(accountID: "1", securityID: "BND", lotID: "", shareCount: 10, shareBasis: 1)
        let holding2b = MHolding(accountID: "1", securityID: "VOO", lotID: "", shareCount: -20, shareBasis: 1)
        model.securities = [security2a, security2b]
        model.holdings = [holding2a, holding2b]
        ax = WorthContext(model)
        let pending2 = PendingSnapshot(snapshotID: "2a", timestamp: timestamp2a, holdings: [holding2a, holding2b], assetMap: ax.assetMap, securityMap: ax.securityMap)
        try model.commitPendingSnapshot(pending2)
        ax = WorthContext(model)

        let mr = MatrixResult(orderedSnapshots: ax.orderedSnapshots[...],
                              rawOrderedCashflow: ax.orderedCashflow,
                              valuationPositions: ax.model.valuationPositions)
        XCTAssertEqual([MAsset.Key(assetID: "Bond"): [50, 100], MAsset.Key(assetID: "LC"): [-200, -400]], mr.matrixValuesByAsset)
        XCTAssertEqual([snapshot1a, snapshot2a], mr.orderedSnapshots)
        XCTAssertEqual((-300)...(-150), mr.marketValueRange)
        XCTAssertEqual([MAccount.Key(accountID: "1")], mr.orderedAccountKeys)
        XCTAssertEqual(1.0, mr.periodSummary!.dietz!.performance) // share price doubled (+100%)
    }
    
    func testThreeAssetsWithAssetMissingFromEnd() throws {
        let asset1 = MAsset(assetID: "Bond")
        let asset2 = MAsset(assetID: "LC")
        let asset3 = MAsset(assetID: "Gold")
        let account1 = MAccount(accountID: "1")

        model.assets = [asset1, asset2, asset3]
        model.accounts = [account1]

        let security1a = MSecurity(securityID: "BND", assetID: "Bond", sharePrice: 5)
        let security1b = MSecurity(securityID: "VOO", assetID: "LC", sharePrice: 10)
        let security1c = MSecurity(securityID: "IAU", assetID: "Gold", sharePrice: 40)
        let holding1a = MHolding(accountID: "1", securityID: "BND", lotID: "", shareCount: 10, shareBasis: 1)
        let holding1b = MHolding(accountID: "1", securityID: "VOO", lotID: "", shareCount: 20, shareBasis: 1)
        let holding1c = MHolding(accountID: "1", securityID: "IAU", lotID: "", shareCount: 5, shareBasis: 1)
        model.securities = [security1a, security1b, security1c]
        model.holdings = [holding1a, holding1b, holding1c]
        ax = WorthContext(model)
        
        let pending1 = PendingSnapshot(snapshotID: "1a",
                                       timestamp: timestamp1a,
                                       holdings: [holding1a, holding1b, holding1c],
                                       accountMap: ax.accountMap,
                                       assetMap: ax.assetMap,
                                       securityMap: ax.securityMap)
        try model.commitPendingSnapshot(pending1)
        
        let security2a = MSecurity(securityID: "BND", assetID: "Bond", sharePrice: 10)
        let security2b = MSecurity(securityID: "VOO", assetID: "LC", sharePrice: 20)
        let security2c = MSecurity(securityID: "IAU", assetID: "Gold", sharePrice: 60)  // price has increased, but this is irrelevant
        let holding2a = MHolding(accountID: "1", securityID: "BND", lotID: "", shareCount: 10, shareBasis: 1)
        let holding2b = MHolding(accountID: "1", securityID: "VOO", lotID: "", shareCount: 20, shareBasis: 1)
        // Gold is missing!
        model.securities = [security2a, security2b, security2c] // need security to generate fake cash flow (even if no holding)
        model.holdings = [holding2a, holding2b] // no IAU
        ax = WorthContext(model)
        
        let pending2 = PendingSnapshot(snapshotID: "2a",
                                       timestamp: timestamp2a,
                                       holdings: [holding2a, holding2b],
                                       previousSnapshot: ax.lastSnapshot,
                                       previousPositions: ax.lastSnapshotPositions,
                                       accountMap: ax.accountMap,
                                       assetMap: ax.assetMap,
                                       securityMap: ax.securityMap)
                
        try model.commitPendingSnapshot(pending2)
        ax = WorthContext(model)
        
        XCTAssertEqual(0, model.valuationCashflows.count) // NO fake cashflow created, Gold @ $225  (PRESENTLY AT -200!)
        
        let mr = MatrixResult(orderedSnapshots: ax.orderedSnapshots[...],
                              rawOrderedCashflow: ax.orderedCashflow,
                              valuationPositions: ax.model.valuationPositions)
        XCTAssertEqual([MAsset.Key(assetID: "Bond"): [50.0, 100.0],
                        MAsset.Key(assetID: "Gold"): [200.0, 0.0], // dropped to zero!
                        MAsset.Key(assetID: "LC"): [200.0, 400.0]], mr.matrixValuesByAsset)
        XCTAssertEqual([snapshot1a, snapshot2a], mr.orderedSnapshots)
        XCTAssertEqual(450...500, mr.marketValueRange)
        XCTAssertEqual([MAccount.Key(accountID: "1")], mr.orderedAccountKeys)
        
        let md = mr.periodSummary!.dietz!
        XCTAssertEqual(0, md.netCashflowTotal) // IGNORED $200 in gold assumed to be sold at end of period with fake transaction
        XCTAssertEqual(0, md.adjustedNetCashflow, accuracy: 0.01)
        
        let bmv: Double = (10.0 * 5.0) + (20.0 * 10.0) + (200) // 450
        let emv: Double = Double((10 * 10) + (20 * 20)) // 500 --- no gold at end
        let ncf: Double = 0 // IGNORED -200 // assume entire gold position sold at end point
        let ancf: Double = 0 // sold at end point, so no adjustment
        let expected = (emv - bmv - ncf) / (bmv + ancf) // 55.6%
        XCTAssertEqual(expected, md.performance, accuracy: 0.001)
    }
}
