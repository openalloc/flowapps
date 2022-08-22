//
//  TxnIncomeTests.swift
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

class TxnIncomeTests: XCTestCase {
    var tz: TimeZone!
    var df: ISO8601DateFormatter!
    var timestamp1a: Date!
    var timestamp1b: Date!
    var timestamp2a: Date!
    var timestamp2b: Date!
    var timestamp3a: Date!
    var snapshotID: SnapshotID!
    var bond: MAsset!
    var lc: MAsset!
    var cash: MAsset!
    var agg: MSecurity!
    var spy: MSecurity!
    var core: MSecurity!
    var account: MAccount!
    var aggHold1: MHolding!
    var aggHold2: MHolding!
    var spyHold1: MHolding!
    var cashHold1: MHolding!
    var accountMap: AccountMap!
    var assetMap: AssetMap!
    var securityMap: SecurityMap!
    var purchase: MTransaction!
    var sale: MTransaction!
    var interestIncome: MTransaction!
    var dividendIncome: MTransaction!
    var bondPos1: MValuationPosition!
    var bondPos2: MValuationPosition!
    var spyPos1: MValuationPosition!
    var cashPos1: MValuationPosition!
    var prevSnapshot: MValuationSnapshot!

    override func setUpWithError() throws {
        tz = TimeZone.init(identifier: "EST")!
        df = ISO8601DateFormatter()
        timestamp1a = df.date(from: "2020-06-01T12:00:00Z")! // anchor
        timestamp1b = df.date(from: "2020-06-01T13:00:00Z")! // one hour later
        timestamp2a = df.date(from: "2020-06-02T12:00:00Z")! // one day later
        timestamp2b = df.date(from: "2020-06-03T00:00:01Z")! // one day, 12 hours and one second later
        timestamp3a = df.date(from: "2020-06-03T06:00:00Z")! // one day beyond start of day (for 2a)
        snapshotID = "x"
        bond = MAsset(assetID: "Bond", title: "Aggregate Bonds")
        lc = MAsset(assetID: "LC", title: "Large Cap")
        cash = MAsset(assetID: "Cash", title: "Cash & Equivalent")
        agg = MSecurity(securityID: "AGG", assetID: "Bond", sharePrice: 7)
        spy = MSecurity(securityID: "SPY", assetID: "LC", sharePrice: 100)
        core = MSecurity(securityID: "CORE", assetID: "Cash", sharePrice: 1)
        account = MAccount(accountID: "A")
        aggHold1 = MHolding(accountID: "A", securityID: "AGG", lotID: "", shareCount: 5, shareBasis: 6)
        aggHold2 = MHolding(accountID: "A", securityID: "AGG", lotID: "", shareCount: 3, shareBasis: 6)
        spyHold1 = MHolding(accountID: "A", securityID: "SPY", lotID: "", shareCount: 10, shareBasis: 90)
        cashHold1 = MHolding(accountID: "A", securityID: "CORE", lotID: "", shareCount: 20, shareBasis: 1)
        accountMap = [MAccount.Key(accountID: "A"): account]
        assetMap = [MAsset.Key(assetID: "Bond"): bond,
                    MAsset.Key(assetID: "LC"): lc,
                    MAsset.Key(assetID: "Cash"): cash]
        securityMap = [MSecurity.Key(securityID: "AGG"): agg,
                       MSecurity.Key(securityID: "SPY"): spy,
                       MSecurity.Key(securityID: "CORE"): core]
        purchase = MTransaction(action: .buysell, transactedAt: timestamp2a, accountID: "A", securityID: "AGG", shareCount: 1, sharePrice: 3)
        sale = MTransaction(action: .buysell, transactedAt: timestamp2a, accountID: "A", securityID: "AGG", shareCount: -1, sharePrice: 3)

        interestIncome = MTransaction(action: .income, transactedAt: timestamp2a, accountID: "A", securityID: "", shareCount: 1, sharePrice: 20)
        dividendIncome = MTransaction(action: .income, transactedAt: timestamp2a, accountID: "A", securityID: "AGG", shareCount: 1, sharePrice: 20)

        bondPos1 = MValuationPosition(snapshotID: snapshotID, accountID: "A", assetID: "Bond", totalBasis: 30, marketValue: 35)
        bondPos2 = MValuationPosition(snapshotID: snapshotID, accountID: "A", assetID: "Bond", totalBasis: 18, marketValue: 21)
        spyPos1 = MValuationPosition(snapshotID: snapshotID, accountID: "A", assetID: "LC", totalBasis: 900, marketValue: 1000)
        cashPos1 = MValuationPosition(snapshotID: snapshotID, accountID: "A", assetID: "Cash", totalBasis: 20, marketValue: 20)
        prevSnapshot = MValuationSnapshot(snapshotID: "y", capturedAt: timestamp1a)
    }
    
    // MARK: - Dividend Income

    // transaction showing dividend income, but it's not showing as a holding
    // because it happened prior to first snapshot, we'll ignore it
    func testFirst0hold1div() throws {
        let ps = PendingSnapshot(snapshotID: snapshotID,
                                 timestamp: timestamp3a,
                                 transactions: [dividendIncome],
                                 previousSnapshot: nil,
                                 previousPositions: [],
                                 assetMap: assetMap,
                                 securityMap: securityMap)
        XCTAssertEqual(ps.nuCashflows.count, 0)
        XCTAssertEqual(ps.nuPositions.count, 0)
        XCTAssertNil(ps.periodSummary) // no period, because no previous snapshot
    }

    // transaction showing dividend income, but it's not showing as a holding
    // assume it was invested and lost
    func test0pos0hold1div() throws {
        let ps = PendingSnapshot(snapshotID: snapshotID,
                                 timestamp: timestamp3a,
                                 transactions: [dividendIncome],
                                 previousSnapshot: prevSnapshot,
                                 previousPositions: [],
                                 assetMap: assetMap,
                                 securityMap: securityMap)
        XCTAssertEqual(ps.nuCashflows.count, 2)
        let expected = [
            MValuationCashflow(transactedAt: timestamp2a, accountID: "A", assetID: "Bond", amount: -20),
            MValuationCashflow(transactedAt: timestamp2a, accountID: "A", assetID: "Cash", amount: 20),
            ]
        XCTAssertEqual(expected, ps.nuCashflows)
        //XCTAssertEqual(ps.reconciledCashflows.count, 0)
        XCTAssertEqual(ps.nuPositions.count, 0)
        XCTAssertEqual(ps.periodSummary!.endMarketValue, 0)
    }
    
    // transaction showing dividend income, and it's showing as a holding
    // (ensure it doesn't generate any cash flow records, because this is the first snapshot)
    func testFirst1hold1div() throws {
        let ps = PendingSnapshot(snapshotID: snapshotID,
                                 timestamp: timestamp3a,
                                 holdings: [cashHold1],
                                 transactions: [dividendIncome],
                                 previousSnapshot: nil,
                                 previousPositions: [],
                                 assetMap: assetMap,
                                 securityMap: securityMap)
        XCTAssertEqual(ps.nuCashflows.count, 0)
        //XCTAssertEqual(ps.reconciledCashflows.count, 0)
        XCTAssertEqual(ps.nuPositions.count, 1)
        XCTAssertEqual(cashPos1, ps.nuPositions.first)
        XCTAssertNil(ps.periodSummary)
    }

    // transaction showing dividend income, and it's showing as a holding
    // (ensure it doesn't generate any !0 cash flow)
    func test0pos1hold1div() throws {
        let ps = PendingSnapshot(snapshotID: snapshotID,
                                 timestamp: timestamp3a,
                                 holdings: [cashHold1],
                                 transactions: [dividendIncome],
                                 previousSnapshot: prevSnapshot,
                                 previousPositions: [],
                                 assetMap: assetMap,
                                 securityMap: securityMap)
        XCTAssertEqual(ps.nuCashflows.count, 2)
        let expected = [
            MValuationCashflow(transactedAt: timestamp2a, accountID: "A", assetID: "Bond", amount: -20),
            MValuationCashflow(transactedAt: timestamp2a, accountID: "A", assetID: "Cash", amount: 20),
            ]
        XCTAssertEqual(expected, ps.nuCashflows)
        //XCTAssertEqual(ps.reconciledCashflows.count, 0)
        XCTAssertEqual(ps.nuPositions.count, 1)
        XCTAssertEqual(cashPos1, ps.nuPositions.first)
        XCTAssertEqual(ps.periodSummary!.endMarketValue, 20)
    }

    // MARK: - Interest Income
    
    // transaction showing interest income, but it's not showing as a holding
    // because it happened prior to first snapshot, we'll ignore it
    func testFirst0hold1int() throws {
        let ps = PendingSnapshot(snapshotID: snapshotID,
                                 timestamp: timestamp3a,
                                 transactions: [interestIncome],
                                 previousSnapshot: nil,
                                 previousPositions: [],
                                 assetMap: assetMap,
                                 securityMap: securityMap)
        XCTAssertEqual(ps.nuCashflows.count, 0)
        //XCTAssertEqual(ps.reconciledCashflows.count, 0)
        XCTAssertEqual(ps.nuPositions.count, 0)
        XCTAssertNil(ps.periodSummary)
    }

    // transaction showing interest income, but it's not showing as a holding
    // assume it was invested and lost
    func test0pos0hold1int() throws {
        let ps = PendingSnapshot(snapshotID: snapshotID,
                                 timestamp: timestamp3a,
                                 transactions: [interestIncome],
                                 previousSnapshot: prevSnapshot,
                                 previousPositions: [],
                                 assetMap: assetMap,
                                 securityMap: securityMap)
        XCTAssertEqual(ps.nuCashflows.count, 0)
        //XCTAssertEqual(ps.reconciledCashflows.count, 0)
        XCTAssertEqual(ps.nuPositions.count, 0)
        XCTAssertEqual(ps.periodSummary!.endMarketValue, 0)
    }
    
    // transaction showing interest income, and it's showing as a holding
    // (ensure it doesn't generate any cash flow)
    func testFirst1hold1int() throws {
        let ps = PendingSnapshot(snapshotID: snapshotID,
                                 timestamp: timestamp3a,
                                 holdings: [cashHold1],
                                 transactions: [interestIncome],
                                 previousSnapshot: nil,
                                 assetMap: assetMap,
                                 securityMap: securityMap)
        XCTAssertEqual(ps.nuCashflows.count, 0)
        //XCTAssertEqual(ps.reconciledCashflows.count, 0)
        XCTAssertEqual(ps.nuPositions.count, 1)
        XCTAssertEqual(cashPos1, ps.nuPositions.first)
        XCTAssertNil(ps.periodSummary)
    }

    // transaction showing interest income, and it's showing as a holding
    // (ensure it doesn't generate any cash flow)
    func test0pos1hold1int() throws {
        let ps = PendingSnapshot(snapshotID: snapshotID,
                                 timestamp: timestamp3a,
                                 holdings: [cashHold1],
                                 transactions: [interestIncome],
                                 previousSnapshot: prevSnapshot,
                                 previousPositions: [],
                                 assetMap: assetMap,
                                 securityMap: securityMap)
        XCTAssertEqual(ps.nuCashflows.count, 0)
        //XCTAssertEqual(ps.reconciledCashflows.count, 0)
        XCTAssertEqual(ps.nuPositions.count, 1)
        XCTAssertEqual(cashPos1, ps.nuPositions.first)
        XCTAssertEqual(ps.periodSummary!.endMarketValue, 20)
    }
    
}
