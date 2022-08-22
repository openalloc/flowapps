//
//  BasicTests.swift
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

class BasicTests: XCTestCase {
    var tz: TimeZone!
    var df: ISO8601DateFormatter!
    var timestamp1a: Date!
    var timestamp1b: Date!
    var timestamp1c: Date!
    var timestamp1d: Date!
    var timestamp2a: Date!
    var timestamp3a: Date!
    var model: BaseModel!
    var ax: WorthContext!
    var account: MAccount!
    var asset1: MAsset!
    var asset2: MAsset!
    var security1: MSecurity!
    var security2: MSecurity!
    var holding1: MHolding!
    var holding2: MHolding!
    
    override func setUpWithError() throws {
        tz = TimeZone.init(identifier: "EST")!
        df = ISO8601DateFormatter()
        timestamp1a = df.date(from: "2020-10-01T19:00:00Z")!
        timestamp1b = df.date(from: "2020-10-01T20:00:00Z")!  // one hour after
        timestamp1c = df.date(from: "2020-10-01T21:00:00Z")!  // two hours after
        timestamp1d = df.date(from: "2020-10-17T07:00:00Z")!  // halfway through month
        timestamp2a = df.date(from: "2020-11-01T19:00:00Z")!
        timestamp3a = df.date(from: "2020-12-01T19:00:00Z")!
        model = BaseModel()
        ax = WorthContext(model)
        account = MAccount(accountID: "1")
        asset1 = MAsset(assetID: "RE")
        asset2 = MAsset(assetID: "Cash")
        security1 = MSecurity(securityID: "VNQ", assetID: "RE", sharePrice: 100)
        security2 = MSecurity(securityID: "CORE", assetID: "Cash", sharePrice: 1)
        holding1 = MHolding(accountID: "1", securityID: "VNQ", lotID: "", shareCount: 300, shareBasis: 85)
        holding2 = MHolding(accountID: "1", securityID: "CORE", lotID: "", shareCount: 1000, shareBasis: 1)
    }
        
    func helperFirstPendingSnapshot(holdings: [MHolding]) -> PendingSnapshot {
        model.accounts = [account]
        model.assets = [asset1, asset2]
        model.securities = [security1, security2]
        model.holdings = holdings
        ax = WorthContext(model)
        return PendingSnapshot(snapshotID: "A",
                               timestamp: timestamp1a,
                               holdings: holdings,
                               transactions: [],
                               accountMap: ax.accountMap,
                               assetMap: ax.assetMap,
                               securityMap: ax.securityMap)
    }
    
    func testFirstSnapshot() throws {
        let pending1 = helperFirstPendingSnapshot(holdings: [holding1])
        let expectedP1 = MValuationPosition(snapshotID: "A", accountID: "1", assetID: "RE", totalBasis: 300*85, marketValue: 300*100)
        let expectedSS1 = MValuationSnapshot(snapshotID: "A", capturedAt: timestamp1a)
        //let expectedCF1 = MValuationCashflow(transactedAt: timestamp1a, accountID: "1", assetID: "RE", amount: 300*100, reconciled: true)
        XCTAssertEqual([], pending1.nuCashflows)
        XCTAssertEqual([expectedP1], pending1.nuPositions)
        
        try model.commitPendingSnapshot(pending1)
        XCTAssertEqual([expectedSS1], model.valuationSnapshots)
        XCTAssertEqual([], model.transactions)
        XCTAssertEqual([], model.holdings)
        XCTAssertEqual([expectedP1], model.valuationPositions)
        XCTAssertEqual([], model.valuationCashflows)
    }
    
    func testNoChange() throws {
        let pending1 = helperFirstPendingSnapshot(holdings: [holding1])
        try model.commitPendingSnapshot(pending1)
    
        model.transactions = []
        ax = WorthContext(model)

        let pending2 = PendingSnapshot(snapshotID: "B",
                                       timestamp: timestamp2a,
                                       holdings: [holding1],
                                       transactions: [],
                                       previousSnapshot: ax.lastSnapshot,
                                       previousPositions: ax.lastSnapshotPositions,
                                       accountMap: ax.accountMap,
                                       assetMap: ax.assetMap,
                                       securityMap: ax.securityMap)
        try model.commitPendingSnapshot(pending2)
        XCTAssertEqual(2, model.valuationPositions.count)
        XCTAssertEqual(0, model.valuationCashflows.count)
        
        let mr = MatrixResult(orderedSnapshots: model.valuationSnapshots[...],
                              rawOrderedCashflow: model.valuationCashflows,
                              valuationPositions: model.valuationPositions)
        
        XCTAssertEqual(0.0, mr.periodSummary!.dietz!.performance, accuracy: 0.001)
    }
    
    func testDepositCash() throws {
        let pending1 = helperFirstPendingSnapshot(holdings: [holding1])
        try model.commitPendingSnapshot(pending1)
    
        let txn1 = MTransaction(action: .transfer,
                                transactedAt: timestamp1b,
                                accountID: "1",
                                securityID: "CORE",
                                lotID: "",
                                shareCount: 1000,
                                sharePrice: 1)
        model.transactions = [txn1]
        ax = WorthContext(model)

        let pending2 = PendingSnapshot(snapshotID: "B",
                                       timestamp: timestamp2a,
                                       holdings: [holding1, holding2],
                                       transactions: [txn1],
                                       previousSnapshot: ax.lastSnapshot,
                                       previousPositions: ax.lastSnapshotPositions,
                                       accountMap: ax.accountMap,
                                       assetMap: ax.assetMap,
                                       securityMap: ax.securityMap)
        let expectedCF1 = [
            MValuationCashflow(transactedAt: timestamp1b, accountID: "1", assetID: "Cash", amount: 1000)
        ]
        XCTAssertEqual(expectedCF1, pending2.nuCashflows)

        try model.commitPendingSnapshot(pending2)
        XCTAssertEqual(3, model.valuationPositions.count)
        XCTAssertEqual(1, model.valuationCashflows.count)
        
        let mr = MatrixResult(orderedSnapshots: model.valuationSnapshots[...],
                              rawOrderedCashflow: model.valuationCashflows,
                              valuationPositions: model.valuationPositions)
        
        XCTAssertEqual(0.0, mr.periodSummary!.dietz!.performance, accuracy: 0.001)
    }
    
    func testWithdrawCash() throws {

        let beforeWithdrawl = MHolding(accountID: "1", securityID: "CORE", lotID: "", shareCount: 1000, shareBasis: 1)
        let afterWithdrawl = MHolding(accountID: "1", securityID: "CORE", lotID: "", shareCount: 250, shareBasis: 1)

        let pending1 = helperFirstPendingSnapshot(holdings: [beforeWithdrawl])
        try model.commitPendingSnapshot(pending1)
    
        let txn1 = MTransaction(action: .transfer,
                                transactedAt: timestamp1b,
                                accountID: "1",
                                securityID: "CORE",
                                lotID: "",
                                shareCount: -750, // withdraw!
                                sharePrice: 1)
        model.transactions = [txn1]
        ax = WorthContext(model)
        
        let pending2 = PendingSnapshot(snapshotID: "B",
                                       timestamp: timestamp2a,
                                       holdings: [afterWithdrawl],
                                       transactions: [txn1],
                                       previousSnapshot: ax.lastSnapshot,
                                       previousPositions: ax.lastSnapshotPositions,
                                       accountMap: ax.accountMap,
                                       assetMap: ax.assetMap,
                                       securityMap: ax.securityMap)
        let expectedCF1 = [
            MValuationCashflow(transactedAt: timestamp1b, accountID: "1", assetID: "Cash", amount: -750)
        ]
        XCTAssertEqual(expectedCF1, pending2.nuCashflows)

        try model.commitPendingSnapshot(pending2)
        XCTAssertEqual(2, model.valuationPositions.count)
        XCTAssertEqual(1, model.valuationCashflows.count)
        
        let mr = MatrixResult(orderedSnapshots: model.valuationSnapshots[...],
                              rawOrderedCashflow: model.valuationCashflows,
                              valuationPositions: model.valuationPositions)
        
        XCTAssertEqual(0.0, mr.periodSummary!.dietz!.performance, accuracy: 0.001)
    }

    func testTransferSecuritiesOut() throws {
        let pending1 = helperFirstPendingSnapshot(holdings: [holding1])
        try model.commitPendingSnapshot(pending1)
    
        let txn1 = MTransaction(action: .transfer,
                                transactedAt: timestamp1b, // one hour later
                                accountID: "1",
                                securityID: "VNQ",
                                lotID: "",
                                shareCount: -300, // out!
                                sharePrice: 110)
        model.transactions = [txn1]
        ax = WorthContext(model)

        let pending2 = PendingSnapshot(snapshotID: "B",
                                       timestamp: timestamp2a,
                                       holdings: [],
                                       transactions: [txn1],
                                       previousSnapshot: ax.lastSnapshot,
                                       previousPositions: ax.lastSnapshotPositions,
                                       accountMap: ax.accountMap,
                                       assetMap: ax.assetMap,
                                       securityMap: ax.securityMap)
        try model.commitPendingSnapshot(pending2)
        XCTAssertEqual(1, model.valuationPositions.count)
        //XCTAssertEqual(3, model.valuationCashflows.count)
        
        let mr = MatrixResult(orderedSnapshots: model.valuationSnapshots[...],
                              rawOrderedCashflow: model.valuationCashflows,
                              valuationPositions: model.valuationPositions)
        
        XCTAssertEqual(0.1, mr.periodSummary!.dietz!.performance, accuracy: 0.001)
    }
    
    func testTransferSecuritiesIn() throws {
        let pending1 = helperFirstPendingSnapshot(holdings: [])
        try model.commitPendingSnapshot(pending1)
    
        let txn1 = MTransaction(action: .transfer,
                                transactedAt: timestamp1d, // halfway through month
                                accountID: "1",
                                securityID: "VNQ",
                                lotID: "",
                                shareCount: 300, // in!
                                sharePrice: 85)
        model.transactions = [txn1]
        ax = WorthContext(model)

        let pending2 = PendingSnapshot(snapshotID: "B",
                                       timestamp: timestamp2a, // a month later
                                       holdings: [holding1],
                                       transactions: [txn1],
                                       previousSnapshot: ax.lastSnapshot,
                                       previousPositions: ax.lastSnapshotPositions,
                                       accountMap: ax.accountMap,
                                       assetMap: ax.assetMap,
                                       securityMap: ax.securityMap)
        try model.commitPendingSnapshot(pending2)
        XCTAssertEqual(1, model.valuationPositions.count)
        XCTAssertEqual(1, model.valuationCashflows.count)
        
        let mr = MatrixResult(orderedSnapshots: model.valuationSnapshots[...],
                              rawOrderedCashflow: model.valuationCashflows,
                              valuationPositions: model.valuationPositions)
        
        let gainShare = 15.0
        let gainLoss = txn1.shareCount * gainShare
        let averageCapital = txn1.marketValue!
        let expected = gainLoss / averageCapital // TODO should this be * 2? because half-way through month, double the performance
        XCTAssertEqual(expected, mr.periodSummary!.dietz!.performance, accuracy: 0.001) // VNQ now at $100/share
    }
    
    func testTransferMiscIn() throws {
        let pending1 = helperFirstPendingSnapshot(holdings: [holding1])
        try model.commitPendingSnapshot(pending1)
    
        let txn1 = MTransaction(action: .miscflow,
                                transactedAt: timestamp1d, // halfway through month
                                accountID: "1",
                                securityID: "",
                                lotID: "",
                                shareCount: 120, // in!
                                sharePrice: 1)
        model.transactions = [txn1]
        ax = WorthContext(model)

        let miscHolding = MHolding(accountID: "1", securityID: "CORE", lotID: "", shareCount: 120, shareBasis: 1)
        
        let pending2 = PendingSnapshot(snapshotID: "B",
                                       timestamp: timestamp2a, // a month later
                                       holdings: [holding1, miscHolding],
                                       transactions: [txn1],
                                       previousSnapshot: ax.lastSnapshot,
                                       previousPositions: ax.lastSnapshotPositions,
                                       accountMap: ax.accountMap,
                                       assetMap: ax.assetMap,
                                       securityMap: ax.securityMap)
        try model.commitPendingSnapshot(pending2)
        XCTAssertEqual(3, model.valuationPositions.count)
        XCTAssertEqual(1, model.valuationCashflows.count)
        
        let mr = MatrixResult(orderedSnapshots: model.valuationSnapshots[...],
                              rawOrderedCashflow: model.valuationCashflows,
                              valuationPositions: model.valuationPositions)
        
        XCTAssertEqual(0.0, mr.periodSummary!.dietz!.performance, accuracy: 0.001) // VNQ now at $100/share
    }
    
    func testTransferMiscOut() throws {
        let pending1 = helperFirstPendingSnapshot(holdings: [holding2])
        try model.commitPendingSnapshot(pending1)
    
        let txn1 = MTransaction(action: .miscflow,
                                transactedAt: timestamp1d, // halfway through month
                                accountID: "1",
                                securityID: "",
                                lotID: "",
                                shareCount: -120, // out!
                                sharePrice: 1)
        model.transactions = [txn1]
        ax = WorthContext(model)

        let nuCash = MHolding(accountID: "1", securityID: "CORE", lotID: "", shareCount: 1000-120, shareBasis: 1)
        
        let pending2 = PendingSnapshot(snapshotID: "B",
                                       timestamp: timestamp2a, // a month later
                                       holdings: [nuCash],
                                       transactions: [txn1],
                                       previousSnapshot: ax.lastSnapshot,
                                       previousPositions: ax.lastSnapshotPositions,
                                       accountMap: ax.accountMap,
                                       assetMap: ax.assetMap,
                                       securityMap: ax.securityMap)
        try model.commitPendingSnapshot(pending2)
        XCTAssertEqual(2, model.valuationPositions.count)
        XCTAssertEqual(1, model.valuationCashflows.count)
        
        let mr = MatrixResult(orderedSnapshots: model.valuationSnapshots[...],
                              rawOrderedCashflow: model.valuationCashflows,
                              valuationPositions: model.valuationPositions)
        
        XCTAssertEqual(0.0, mr.periodSummary!.dietz!.performance, accuracy: 0.001) // VNQ now at $100/share
    }

    func testIncomeWithExplicitCashSecurity() throws {
        let pending1 = helperFirstPendingSnapshot(holdings: [holding1])
        try model.commitPendingSnapshot(pending1)
        XCTAssertEqual(1, model.valuationPositions.count)
        XCTAssertEqual(0, model.valuationCashflows.count)
    
        let txn1 = MTransaction(action: .income,
                                transactedAt: timestamp1d, // halfway through month
                                accountID: "1",
                                securityID: "CORE", // explicit Cash security
                                lotID: "",
                                shareCount: 300, // in!
                                sharePrice: 1)
        model.transactions = [txn1]
        ax = WorthContext(model)

        let cashHolding = MHolding(accountID: "1", securityID: "CORE", lotID: "", shareCount: 300, shareBasis: 1)
        
        let pending2 = PendingSnapshot(snapshotID: "B",
                                       timestamp: timestamp2a, // a month later
                                       holdings: [holding1, cashHolding],
                                       transactions: [txn1],
                                       previousSnapshot: ax.lastSnapshot,
                                       previousPositions: ax.lastSnapshotPositions,
                                       accountMap: ax.accountMap,
                                       assetMap: ax.assetMap,
                                       securityMap: ax.securityMap)
        XCTAssertEqual(30300, pending2.periodSummary!.endMarketValue)
        try model.commitPendingSnapshot(pending2)
        XCTAssertEqual(3, model.valuationPositions.count)
        XCTAssertEqual(0, model.valuationCashflows.count)
        
        let mr = MatrixResult(orderedSnapshots: model.valuationSnapshots[...],
                              rawOrderedCashflow: model.valuationCashflows,
                              valuationPositions: model.valuationPositions)
        
        let expected = 300.0 / 30000
        XCTAssertEqual(expected, mr.periodSummary!.dietz!.performance, accuracy: 0.001) // VNQ now at $100/share
    }
    
    func testIncomeWithoutExplicitCashSecurity() throws {
        let pending1 = helperFirstPendingSnapshot(holdings: [holding1])
        try model.commitPendingSnapshot(pending1)
    
        let txn1 = MTransaction(action: .income,
                                transactedAt: timestamp1d, // halfway through month
                                accountID: "1",
                                securityID: "", // no explicit security
                                lotID: "",
                                shareCount: 300, // in!
                                sharePrice: 1)
        model.transactions = [txn1]
        ax = WorthContext(model)

        let miscHolding = MHolding(accountID: "1", securityID: "CORE", lotID: "", shareCount: 300, shareBasis: 1)
        
        let pending2 = PendingSnapshot(snapshotID: "B",
                                       timestamp: timestamp2a, // a month later
                                       holdings: [holding1, miscHolding],
                                       transactions: [txn1],
                                       previousSnapshot: ax.lastSnapshot,
                                       previousPositions: ax.lastSnapshotPositions,
                                       accountMap: ax.accountMap,
                                       assetMap: ax.assetMap,
                                       securityMap: ax.securityMap)
        XCTAssertEqual(30300, pending2.periodSummary!.endMarketValue)
        try model.commitPendingSnapshot(pending2)
        XCTAssertEqual(3, model.valuationPositions.count)
        //XCTAssertEqual(3, model.valuationCashflows.count)
        
        let mr = MatrixResult(orderedSnapshots: model.valuationSnapshots[...],
                              rawOrderedCashflow: model.valuationCashflows,
                              valuationPositions: model.valuationPositions)
        
        let expected = 300.0 / 30000
        XCTAssertEqual(expected, mr.periodSummary!.dietz!.performance, accuracy: 0.001) // VNQ now at $100/share
    }
    
    func testIncomeWithNonCashSecurity() throws {
        let pending1 = helperFirstPendingSnapshot(holdings: [holding1])
        try model.commitPendingSnapshot(pending1)
    
        let txn1 = MTransaction(action: .income,
                                transactedAt: timestamp1d, // halfway through month
                                accountID: "1",
                                securityID: "VNQ",
                                lotID: "",
                                shareCount: 150, // in!
                                sharePrice: 1)
        model.transactions = [txn1]
        ax = WorthContext(model)

        let miscHolding = MHolding(accountID: "1", securityID: "CORE", lotID: "", shareCount: 150, shareBasis: 1)
        
        let pending2 = PendingSnapshot(snapshotID: "B",
                                       timestamp: timestamp2a, // a month later
                                       holdings: [holding1, miscHolding],
                                       transactions: [txn1],
                                       previousSnapshot: ax.lastSnapshot,
                                       previousPositions: ax.lastSnapshotPositions,
                                       accountMap: ax.accountMap,
                                       assetMap: ax.assetMap,
                                       securityMap: ax.securityMap)
        XCTAssertEqual(30150, pending2.periodSummary!.endMarketValue)
        try model.commitPendingSnapshot(pending2)
        XCTAssertEqual(3, model.valuationPositions.count)
        //XCTAssertEqual(3, model.valuationCashflows.count)
        
        let mr = MatrixResult(orderedSnapshots: model.valuationSnapshots[...],
                              rawOrderedCashflow: model.valuationCashflows,
                              valuationPositions: model.valuationPositions)
        
        let expected = 150.0 / 30000.0
        XCTAssertEqual(expected, mr.periodSummary!.dietz!.performance, accuracy: 0.001) // VNQ now at $100/share
    }
    
    func testSellForCash() throws {
        let pending1 = helperFirstPendingSnapshot(holdings: [holding1])
        try model.commitPendingSnapshot(pending1)

        // sold off all the shares at (110-85) profit per share, for 10% profit
        let txn1 = MTransaction(action: .buysell,
                               transactedAt: timestamp1b, // one hour later
                               accountID: "1",
                               securityID: "VNQ",
                               lotID: "",
                               shareCount: -300, // sell all shares
                               sharePrice: 110)
        model.transactions = [txn1]
        ax = WorthContext(model)

        let proceeds = MHolding(accountID: "1", securityID: "CORE", lotID: "", shareCount: 33000, shareBasis: 1)
        let pending2 = PendingSnapshot(snapshotID: "B",
                                       timestamp: timestamp2a,
                                       holdings: [proceeds],
                                       transactions: [txn1],
                                       previousSnapshot: ax.lastSnapshot,
                                       previousPositions: ax.lastSnapshotPositions,
                                       accountMap: ax.accountMap,
                                       assetMap: ax.assetMap,
                                       securityMap: ax.securityMap)
        XCTAssertEqual(33000, pending2.periodSummary!.endMarketValue)
        try model.commitPendingSnapshot(pending2)

        XCTAssertEqual(2, model.valuationPositions.count)
        
        let expectedCF = [ MValuationCashflow(transactedAt: timestamp1b,
                                              accountID: "1",
                                              assetID: "Cash",
                                              amount: 300*110),
                           MValuationCashflow(transactedAt: timestamp1b,
                                              accountID: "1",
                                              assetID: "RE",
                                              amount: -300*110),
        ]
        XCTAssertEqual(expectedCF, model.valuationCashflows)

        let mr = MatrixResult(orderedSnapshots: model.valuationSnapshots[...],
                              rawOrderedCashflow: model.valuationCashflows,
                              valuationPositions: model.valuationPositions)

        XCTAssertEqual(0.1, mr.periodSummary!.dietz!.performance, accuracy: 0.001)
    }
}
