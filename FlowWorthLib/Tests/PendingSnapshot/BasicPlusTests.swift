//
//  BasicPlusTests.swift
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

class BasicPlusTests: XCTestCase {
    var tz: TimeZone!
    var df: ISO8601DateFormatter!
    var timestamp1a: Date!
    var timestamp1b: Date!
    var timestamp1c: Date!
    var timestamp2a: Date!
    var timestamp2b: Date!
    var timestamp2c: Date!
    var timestamp3a: Date!
    var model: BaseModel!
    var ax: WorthContext!
    var account: MAccount!
    var asset1: MAsset!
    var asset2: MAsset!
    var asset3: MAsset!
    var security1: MSecurity!
    var security2: MSecurity!
    var security3: MSecurity!
    var holding1: MHolding!
    
    override func setUpWithError() throws {
        tz = TimeZone.init(identifier: "EST")!
        df = ISO8601DateFormatter()
        timestamp1a = df.date(from: "2020-10-01T19:00:00Z")!
        timestamp1b = df.date(from: "2020-10-01T20:00:00Z")!  // one hour later
        timestamp1c = df.date(from: "2020-10-01T21:00:00Z")!  // two hours later
        
        timestamp2a = df.date(from: "2020-11-01T19:00:00Z")!
        timestamp2b = df.date(from: "2020-11-01T20:00:00Z")!  // one hour later
        timestamp2c = df.date(from: "2020-11-01T21:00:00Z")!  // two hours later
        
        timestamp3a = df.date(from: "2020-12-01T19:00:00Z")!
        model = BaseModel()
        ax = WorthContext(model)
        account = MAccount(accountID: "1")
        asset1 = MAsset(assetID: "RE")
        asset2 = MAsset(assetID: "Cash")
        asset3 = MAsset(assetID: "LC")
        security1 = MSecurity(securityID: "VNQ", assetID: "RE", sharePrice: 100)
        security2 = MSecurity(securityID: "CORE", assetID: "Cash", sharePrice: 1)
        security3 = MSecurity(securityID: "SPY", assetID: "LC", sharePrice: 200)
        holding1 = MHolding(accountID: "1", securityID: "VNQ", lotID: "", shareCount: 300, shareBasis: 85)
    }
    
    func helperFirstPendingSnapshot(holdings: [MHolding]) -> PendingSnapshot {
        model.accounts = [account]
        model.assets = [asset1, asset2, asset3]
        model.securities = [security1, security2, security3]
        model.holdings = holdings
        ax = WorthContext(model)
        return PendingSnapshot(snapshotID: "1",
                               timestamp: timestamp1a,
                               holdings: holdings,
                               transactions: [],
                               accountMap: ax.accountMap,
                               assetMap: ax.assetMap,
                               securityMap: ax.securityMap)
    }
    
    func testSellAndTransferProceedsToExternal() throws {
        let pending1 = helperFirstPendingSnapshot(holdings: [holding1])
        try model.commitPendingSnapshot(pending1)
        XCTAssertEqual(1, model.valuationPositions.count)
        
        // SECOND SNAPSHOT - sell off all the shares and transfer cash out
        
        let txn2a = MTransaction(action: .buysell,
                                 transactedAt: timestamp1b, // one hour later
                                 accountID: "1",
                                 securityID: "VNQ",
                                 lotID: "",
                                 shareCount: -300, // sell all shares
                                 sharePrice: 110)
        let txn2b = MTransaction(action: .transfer,
                                 transactedAt: timestamp1c, // two hours later
                                 accountID: "1",
                                 securityID: "CORE",
                                 lotID: "",
                                 shareCount: -33000,
                                 sharePrice: 1)
        model.transactions = [txn2a, txn2b]
        ax = WorthContext(model)
        
        let pending2 = PendingSnapshot(snapshotID: "2",
                                       timestamp: timestamp2a, // end of period
                                       holdings: [], // no proceeds remaining due to transfer
                                       transactions: [txn2a, txn2b],
                                       previousSnapshot: ax.lastSnapshot,
                                       previousPositions: ax.lastSnapshotPositions,
                                       accountMap: ax.accountMap,
                                       assetMap: ax.assetMap,
                                       securityMap: ax.securityMap)
        XCTAssertEqual(0, pending2.periodSummary!.endMarketValue)
        try model.commitPendingSnapshot(pending2)
        
        XCTAssertEqual(1, model.valuationPositions.count) // no additional positions for 2nd snapshot
        
        let expectedCF = [ MValuationCashflow(transactedAt: timestamp1b,
                                              accountID: "1",
                                              assetID: "Cash",
                                              amount: 300*110),
                           MValuationCashflow(transactedAt: timestamp1b,
                                              accountID: "1",
                                              assetID: "RE",
                                              amount: -300*110),
                           MValuationCashflow(transactedAt: timestamp1c, // OLD timestamp2a, // needs to flow out at end of period
                                              accountID: "1",
                                              assetID: "Cash",
                                              amount: -300*110)
        ]
        XCTAssertEqual(expectedCF, model.valuationCashflows)
        
        let mr = MatrixResult(orderedSnapshots: model.valuationSnapshots[...],
                              rawOrderedCashflow: model.valuationCashflows,
                              valuationPositions: model.valuationPositions)
        
        XCTAssertEqual(0.1, mr.periodSummary!.dietz!.performance, accuracy: 0.001)
    }
    
    func testTransfersInEachOfTwoSnapshots() throws {
        let pending1 = helperFirstPendingSnapshot(holdings: [holding1])
        try model.commitPendingSnapshot(pending1)
        XCTAssertEqual(1, model.valuationPositions.count)
        
        // SECOND SNAPSHOT - sell off half the shares (at $110/share) and transfer cash out
        
        security1 = MSecurity(securityID: "VNQ", assetID: "RE", sharePrice: 110)
        let txn2a = MTransaction(action: .buysell,
                                 transactedAt: timestamp1b, // one hour later
                                 accountID: "1",
                                 securityID: "VNQ",
                                 lotID: "",
                                 shareCount: -150, // sell half shares
                                 sharePrice: 110)
        let txn2b = MTransaction(action: .transfer,
                                 transactedAt: timestamp1c, // two hours later
                                 accountID: "1",
                                 securityID: "CORE",
                                 lotID: "",
                                 shareCount: -150*110,
                                 sharePrice: 1)
        model.transactions = [txn2a, txn2b]
        model.securities = [security1, security2]
        ax = WorthContext(model)
        
        let halfShares = MHolding(accountID: "1", securityID: "VNQ", lotID: "", shareCount: 150, shareBasis: 85)
        let pending2 = PendingSnapshot(snapshotID: "2",
                                       timestamp: timestamp2a,
                                       holdings: [halfShares], // no proceeds remaining due to transfer
                                       transactions: [txn2a, txn2b],
                                       previousSnapshot: ax.lastSnapshot,
                                       previousPositions: ax.lastSnapshotPositions,
                                       accountMap: ax.accountMap,
                                       assetMap: ax.assetMap,
                                       securityMap: ax.securityMap)
        XCTAssertEqual(150*110, pending2.periodSummary!.endMarketValue)
        try model.commitPendingSnapshot(pending2)
        
        XCTAssertEqual(2, model.valuationPositions.count)
        
        let expectedCF2 = [
            MValuationCashflow(transactedAt: timestamp1b,
                               accountID: "1",
                               assetID: "Cash",
                               amount: 150*110),
            MValuationCashflow(transactedAt: timestamp1b,
                               accountID: "1",
                               assetID: "RE",
                               amount: -150*110),
            MValuationCashflow(transactedAt: timestamp1c, // OLD timestamp2a, // needs to flow out at end of period
                               accountID: "1",
                               assetID: "Cash",
                               amount: -150*110)
        ]
        XCTAssertEqual(expectedCF2, model.valuationCashflows)
        
        let mr2 = MatrixResult(orderedSnapshots: model.valuationSnapshots[...],
                               rawOrderedCashflow: model.valuationCashflows,
                               valuationPositions: model.valuationPositions)
        
        let expected = (16500.0 - 30000 - (-16500)) / (30000 - 16500) // 22%
        XCTAssertEqual(expected, mr2.periodSummary!.dietz!.performance, accuracy: 0.001)
        print(mr2.periodSummary!.dietz!.description)
        
        // THIRD SNAPSHOT - sell remainder of shares (at $110/share) and transfer cash out
        
        let txn3a = MTransaction(action: .buysell,
                                 transactedAt: timestamp2b, // one hour later
                                 accountID: "1",
                                 securityID: "VNQ",
                                 lotID: "",
                                 shareCount: -150, // sell remaining shares
                                 sharePrice: 110)
        let txn3b = MTransaction(action: .transfer,
                                 transactedAt: timestamp2c, // two hours later
                                 accountID: "1",
                                 securityID: "CORE",
                                 lotID: "",
                                 shareCount: -16500,
                                 sharePrice: 1)
        model.transactions = [txn3a, txn3b]
        ax = WorthContext(model)
        
        let pending3 = PendingSnapshot(snapshotID: "3",
                                       timestamp: timestamp3a,
                                       holdings: [], // no proceeds remaining due to transfer
                                       transactions: [txn3a, txn3b],
                                       previousSnapshot: ax.lastSnapshot,
                                       previousPositions: ax.lastSnapshotPositions,
                                       accountMap: ax.accountMap,
                                       assetMap: ax.assetMap,
                                       securityMap: ax.securityMap)
        XCTAssertEqual(0, pending3.periodSummary!.endMarketValue)
        try model.commitPendingSnapshot(pending3)
        
        XCTAssertEqual(2, model.valuationPositions.count) // no additional positions for 3nd snapshot
        
        let expectedCF3 = [
            MValuationCashflow(transactedAt: timestamp2b,
                               accountID: "1",
                               assetID: "Cash",
                               amount: 150*110),
            MValuationCashflow(transactedAt: timestamp2b,
                               accountID: "1",
                               assetID: "RE",
                               amount: -150*110),
            MValuationCashflow(transactedAt: timestamp2c, // OLD timestamp3a, // needs to flow out at end of period
                               accountID: "1",
                               assetID: "Cash",
                               amount: -150*110)
        ]
        XCTAssertEqual(expectedCF2 + expectedCF3, model.valuationCashflows)
        
        let mr3 = MatrixResult(orderedSnapshots: model.valuationSnapshots[...],
                               rawOrderedCashflow: model.valuationCashflows,
                               valuationPositions: model.valuationPositions)
        
        let expected3 = (16500.0 - 30000 - (-16500)) / (30000 - 16500) // 22%
        XCTAssertEqual(expected3, mr3.periodSummary!.dietz!.performance, accuracy: 0.001)
        //print(mr3.periodSummary!.dietz.description)
    }
    
    func testTransferCashInAndBuySecurities() throws {
        let pending1 = helperFirstPendingSnapshot(holdings: [holding1])
        try model.commitPendingSnapshot(pending1)
        XCTAssertEqual(1, model.valuationPositions.count)
        
        // SECOND SNAPSHOT - transfer cash in and purchase MORE securities
        
        let txn2a = MTransaction(action: .transfer,
                                 transactedAt: timestamp1b, // one hour later
                                 accountID: "1",
                                 securityID: "",
                                 lotID: "",
                                 shareCount: 20000, // transfer cash in
                                 sharePrice: 1)
        let txn2b = MTransaction(action: .buysell,
                                 transactedAt: timestamp1c, // one hour later
                                 accountID: "1",
                                 securityID: "SPY",
                                 lotID: "",
                                 shareCount: 100, // buy
                                 sharePrice: 200)
        model.transactions = [txn2a, txn2b]
        
        // boost prices for calculating RoR
        security1.sharePrice = 115 // up!
        security3.sharePrice = 190 // down!
        model.securities = [security1, security2, security3]
        ax = WorthContext(model)
        
        let holdings = [
            MHolding(accountID: "1", securityID: "VNQ", lotID: "", shareCount: 300, shareBasis: 85),
            MHolding(accountID: "1", securityID: "SPY", lotID: "", shareCount: 100, shareBasis: 200),
            ]
        let pending2 = PendingSnapshot(snapshotID: "2",
                                       timestamp: timestamp2a,
                                       holdings: holdings,
                                       transactions: [txn2a, txn2b],
                                       previousSnapshot: ax.lastSnapshot,
                                       previousPositions: ax.lastSnapshotPositions,
                                       accountMap: ax.accountMap,
                                       assetMap: ax.assetMap,
                                       securityMap: ax.securityMap) // with prices at time of snapshot
        let mve: Double = (300*115 + 100*190)
        XCTAssertEqual(mve, pending2.periodSummary!.endMarketValue)
        try model.commitPendingSnapshot(pending2)
        
        XCTAssertEqual(3, model.valuationPositions.count)
        
        let expectedCF2 = [
            MValuationCashflow(transactedAt: timestamp1b,
                               accountID: "1",
                               assetID: "Cash",
                               amount: 100*200),
            MValuationCashflow(transactedAt: timestamp1c,
                               accountID: "1",
                               assetID: "Cash",
                               amount: -100*200),
            MValuationCashflow(transactedAt: timestamp1c,
                               accountID: "1",
                               assetID: "LC",
                               amount: 100*200), // buy
        ]
        XCTAssertEqual(expectedCF2, model.valuationCashflows)

        let mr2 = MatrixResult(orderedSnapshots: model.valuationSnapshots[...],
                               rawOrderedCashflow: model.valuationCashflows,
                               valuationPositions: model.valuationPositions)
        
        let gainOrLoss: Double = mve - 300*100 - 20000
        let averageCapital: Double = (300*100) + 20000
        let expected = gainOrLoss / averageCapital // 7%
        XCTAssertEqual(expected, mr2.periodSummary!.dietz!.performance, accuracy: 0.001)
        //print(mr2.periodSummary!.dietz!.description)
    }
    
    func testTransferAssetsIn() throws {
        let pending1 = helperFirstPendingSnapshot(holdings: [holding1])
        try model.commitPendingSnapshot(pending1)
        XCTAssertEqual(1, model.valuationPositions.count)
        
        // SECOND SNAPSHOT - transfer securities in
        
        let txn2a = MTransaction(action: .transfer,
                                 transactedAt: timestamp1b, // one hour later
                                 accountID: "1",
                                 securityID: "SPY",
                                 lotID: "",
                                 shareCount: 100, // transfer shares in
                                 sharePrice: 210)
        
        // boost prices for calculating RoR
        security1.sharePrice = 115 // up!
        security3.sharePrice = 190 // down!
        model.securities = [security1, security2, security3]
        model.transactions = [txn2a]
        ax = WorthContext(model)
        
        let holdings = [
            MHolding(accountID: "1", securityID: "VNQ", lotID: "", shareCount: 300, shareBasis: 85),
            MHolding(accountID: "1", securityID: "SPY", lotID: "", shareCount: 100, shareBasis: 200),
            ]
        let pending2 = PendingSnapshot(snapshotID: "2",
                                       timestamp: timestamp2a,
                                       holdings: holdings,
                                       transactions: [txn2a],
                                       previousSnapshot: ax.lastSnapshot,
                                       previousPositions: ax.lastSnapshotPositions,
                                       accountMap: ax.accountMap,
                                       assetMap: ax.assetMap,
                                       securityMap: ax.securityMap) // with prices at time of snapshot
        let mve: Double = (300*115 + 100*190) // 53_500
        XCTAssertEqual(mve, pending2.periodSummary!.endMarketValue)
        try model.commitPendingSnapshot(pending2)
        
        XCTAssertEqual(3, model.valuationPositions.count)
        
        let expectedCF2 = [
            MValuationCashflow(transactedAt: timestamp1b,
                               accountID: "1",
                               assetID: "LC",
                               amount: 100*210), // transfer @ 210/share
        ]
        XCTAssertEqual(expectedCF2, model.valuationCashflows)

        let mr2 = MatrixResult(orderedSnapshots: model.valuationSnapshots[...],
                               rawOrderedCashflow: model.valuationCashflows,
                               valuationPositions: model.valuationPositions)
        
        let mvb: Double = 300*100
        let gainOrLoss: Double = mve - mvb - (100*210)
        let averageCapital: Double = mvb + (100*210)
        let expected = gainOrLoss / averageCapital // 4.9%
        XCTAssertEqual(expected, mr2.periodSummary!.dietz!.performance, accuracy: 0.001)
        //print(mr2.periodSummary!.dietz.description)
    }
}
