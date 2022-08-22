//
//  TxnBuySellTests.swift
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

class TxnBuySellTests: XCTestCase {
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
    var agg: MSecurity!
    var spy: MSecurity!
    var account: MAccount!
    var aggHold1: MHolding!
    var aggHold2: MHolding!
    var spyHold1: MHolding!
    var accountMap: AccountMap!
    var assetMap: AssetMap!
    var securityMap: SecurityMap!
    var purchase: MTransaction!
    var sale: MTransaction!
    var interestIncome: MTransaction!
    var bondPos1: MValuationPosition!
    var bondPos2: MValuationPosition!
    var spyPos1: MValuationPosition!
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
        agg = MSecurity(securityID: "AGG", assetID: "Bond", sharePrice: 7)
        spy = MSecurity(securityID: "SPY", assetID: "LC", sharePrice: 100)
        account = MAccount(accountID: "A")
        aggHold1 = MHolding(accountID: "A", securityID: "AGG", lotID: "", shareCount: 5, shareBasis: 6)
        aggHold2 = MHolding(accountID: "A", securityID: "AGG", lotID: "", shareCount: 3, shareBasis: 6)
        spyHold1 = MHolding(accountID: "A", securityID: "SPY", lotID: "", shareCount: 10, shareBasis: 90)
        accountMap = [MAccount.Key(accountID: "A"): account]
        assetMap = [MAsset.Key(assetID: "Bond"): bond, MAsset.Key(assetID: "LC"): lc]
        securityMap = [MSecurity.Key(securityID: "AGG"): agg, MSecurity.Key(securityID: "SPY"): spy]
        purchase = MTransaction(action: .buysell, transactedAt: timestamp2a, accountID: "A", securityID: "AGG", shareCount: 1, sharePrice: 3)
        sale = MTransaction(action: .buysell, transactedAt: timestamp2a, accountID: "A", securityID: "AGG", shareCount: -1, sharePrice: 3)
        interestIncome = MTransaction(action: .income, transactedAt: timestamp2a, accountID: "A", securityID: "", shareCount: 1, sharePrice: 20)
        bondPos1 = MValuationPosition(snapshotID: snapshotID, accountID: "A", assetID: "Bond", totalBasis: 30, marketValue: 35)
        bondPos2 = MValuationPosition(snapshotID: snapshotID, accountID: "A", assetID: "Bond", totalBasis: 18, marketValue: 21)
        spyPos1 = MValuationPosition(snapshotID: snapshotID, accountID: "A", assetID: "LC", totalBasis: 900, marketValue: 1000)
        prevSnapshot = MValuationSnapshot(snapshotID: "y", capturedAt: timestamp1a)
    }
    
    // MARK: - Buy/Sell Transaction
    
    func testFirstEmpty() throws {
        let ps = PendingSnapshot()
        XCTAssertEqual(ps.nuCashflows.count, 0)
        //XCTAssertEqual(ps.reconciledCashflows.count, 0)
        XCTAssertEqual(ps.nuPositions.count, 0)
    }
    
    func testFirst1hold0txn() throws {
        let ps = PendingSnapshot(snapshotID: snapshotID,
                                 timestamp: timestamp3a,
                                 holdings: [aggHold1],
                                 transactions: [],
                                 assetMap: assetMap,
                                 securityMap: securityMap)
        XCTAssertEqual(ps.nuCashflows.count, 0)
        //XCTAssertEqual(ps.reconciledCashflows.count, 0)
        XCTAssertEqual(ps.nuPositions.count, 1)
        XCTAssertEqual(bondPos1, ps.nuPositions.first)
    }
    
    func testFirst1hold1txn() throws {
        let ps = PendingSnapshot(snapshotID: snapshotID,
                                 timestamp: timestamp3a,
                                 holdings: [aggHold1],
                                 transactions: [purchase],
                                 assetMap: assetMap,
                                 securityMap: securityMap)
        XCTAssertEqual(ps.nuCashflows.count, 0)
        //XCTAssertEqual(ps.reconciledCashflows.count, 0)
        XCTAssertEqual(ps.nuPositions.count, 1)
        XCTAssertEqual(bondPos1, ps.nuPositions.first)
    }
    
    // prev snapshot was empty; no holdings yet
    func test0pos0hold0txn() throws {
        let ps = PendingSnapshot(snapshotID: snapshotID,
                                 timestamp: timestamp3a,
                                 previousSnapshot: prevSnapshot,
                                 previousPositions: [],
                                 assetMap: assetMap,
                                 securityMap: securityMap)
        XCTAssertEqual(ps.nuCashflows.count, 0)
        //XCTAssertEqual(ps.reconciledCashflows.count, 0)
        XCTAssertEqual(ps.nuPositions.count, 0)
    }
    
    // first snapshot was empty; now have one holding (missing transaction showing a purchase!)
    func test0pos1hold0txn() throws {
        let ps = PendingSnapshot(snapshotID: snapshotID,
                                 timestamp: timestamp3a,
                                 holdings: [aggHold1],
                                 previousSnapshot: prevSnapshot,
                                 previousPositions: [],
                                 assetMap: assetMap,
                                 securityMap: securityMap)
        XCTAssertEqual(ps.nuCashflows.count, 0)
        //XCTAssertEqual(ps.reconciledCashflows.count, 0)
        XCTAssertEqual(ps.nuPositions.count, 1)
        XCTAssertEqual(bondPos1, ps.nuPositions.first)
    }
    
    // first snapshot was empty; now have two holdings (missing transactions showing a purchase!)
    func test0pos2hold0txn() throws {
        let ps = PendingSnapshot(snapshotID: snapshotID,
                                 timestamp: timestamp3a,
                                 holdings: [aggHold1, spyHold1],
                                 previousSnapshot: prevSnapshot,
                                 previousPositions: [],
                                 assetMap: assetMap,
                                 securityMap: securityMap)
        XCTAssertEqual(ps.nuCashflows.count, 0)
        //XCTAssertEqual(ps.reconciledCashflows.count, 0)
        XCTAssertEqual(ps.nuPositions.count, 2)
    }
        
    // the position just disappeared (without any transaction). Assume value dropped to 0.
    func test1pos0hold() throws {
        let ps = PendingSnapshot(snapshotID: snapshotID,
                                 timestamp: timestamp3a,
                                 previousSnapshot: prevSnapshot,
                                 previousPositions: [bondPos1],
                                 assetMap: assetMap,
                                 securityMap: securityMap)
        XCTAssertEqual(ps.nuCashflows.count, 0)
        //XCTAssertEqual(ps.reconciledCashflows.count, 0)
        XCTAssertEqual(ps.nuPositions.count, 0)
    }
        
    // position replaced with another (no transactions)
    func test1pos1hold0txnSwap() throws {
        let ps = PendingSnapshot(snapshotID: snapshotID,
                                 timestamp: timestamp3a,
                                 holdings: [aggHold1],
                                 previousSnapshot: prevSnapshot,
                                 previousPositions: [spyPos1],
                                 assetMap: assetMap,
                                 securityMap: securityMap)
        XCTAssertEqual(ps.nuCashflows.count, 0)
        //XCTAssertEqual(ps.reconciledCashflows.count, 0)
        XCTAssertEqual(ps.nuPositions.count, 1)
    }
}
