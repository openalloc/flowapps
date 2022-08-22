//
//  TxnMiscTests.swift
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

class TxnMiscTests: XCTestCase {
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
    var miscAdd: MTransaction!
    var miscSub: MTransaction!
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
        assetMap = [MAsset.Key(assetID: "Bond"): bond, MAsset.Key(assetID: "LC"): lc, MAsset.Key(assetID: "Cash"): cash]
        securityMap = [MSecurity.Key(securityID: "AGG"): agg, MSecurity.Key(securityID: "SPY"): spy, MSecurity.Key(securityID: "CORE"): core]
        purchase = MTransaction(action: .buysell, transactedAt: timestamp2a, accountID: "A", securityID: "AGG", shareCount: 1, sharePrice: 3)
        sale = MTransaction(action: .buysell, transactedAt: timestamp2a, accountID: "A", securityID: "AGG", shareCount: -1, sharePrice: 3)
        miscAdd = MTransaction(action: .miscflow, transactedAt: timestamp2a, accountID: "A", securityID: "", shareCount: 1, sharePrice: 20)
        miscSub = MTransaction(action: .miscflow, transactedAt: timestamp2a, accountID: "A", securityID: "", shareCount: -1, sharePrice: 20)
        bondPos1 = MValuationPosition(snapshotID: snapshotID, accountID: "A", assetID: "Bond", totalBasis: 30, marketValue: 35)
        bondPos2 = MValuationPosition(snapshotID: snapshotID, accountID: "A", assetID: "Bond", totalBasis: 18, marketValue: 21)
        spyPos1 = MValuationPosition(snapshotID: snapshotID, accountID: "A", assetID: "LC", totalBasis: 900, marketValue: 1000)
        cashPos1 = MValuationPosition(snapshotID: snapshotID, accountID: "A", assetID: "Cash", totalBasis: 20, marketValue: 20)
        prevSnapshot = MValuationSnapshot(snapshotID: "y", capturedAt: timestamp1a)
    }
    
    // MARK: - Add
    
    // transaction showing misc change, but it's not showing as a holding
    // because it happened prior to first snapshot, we'll ignore it
    func testFirst0hold1add() throws {
        let ps = PendingSnapshot(snapshotID: snapshotID,
                                 timestamp: timestamp3a,
                                 transactions: [miscAdd],
                                 assetMap: assetMap,
                                 securityMap: securityMap)
        XCTAssertEqual(ps.nuCashflows.count, 0)
        //XCTAssertEqual(ps.reconciledCashflows.count, 0)
        XCTAssertEqual(ps.nuPositions.count, 0)
    }
    
    // transaction showing misc change, and it's showing as a holding
    // (ensure it doesn't generate any cash flow)
    func testFirst1hold1add() throws {
        let ps = PendingSnapshot(snapshotID: snapshotID,
                                 timestamp: timestamp3a,
                                 holdings: [cashHold1],
                                 transactions: [miscAdd],
                                 assetMap: assetMap,
                                 securityMap: securityMap)
        XCTAssertEqual(ps.nuCashflows.count, 0)
        //XCTAssertEqual(ps.reconciledCashflows.count, 0)
        XCTAssertEqual(ps.nuPositions.count, 1)
        XCTAssertEqual(cashPos1, ps.nuPositions.first)
    }
    
    // MARK: - Subtract
    
    // transaction showing misc change, but it's not showing as a holding
    // because it happened prior to first snapshot, we'll ignore it
    func testFirst0hold1sub() throws {
        let ps = PendingSnapshot(snapshotID: snapshotID,
                                 timestamp: timestamp3a,
                                 transactions: [miscSub],
                                 assetMap: assetMap,
                                 securityMap: securityMap)
        XCTAssertEqual(ps.nuCashflows.count, 0)
        //XCTAssertEqual(ps.reconciledCashflows.count, 0)
        XCTAssertEqual(ps.nuPositions.count, 0)
    }
    
    // transaction showing misc change, and it's showing as a holding
    // (ensure it doesn't generate any cash flow)
    func testFirst1hold1sub() throws {
        let ps = PendingSnapshot(snapshotID: snapshotID,
                                 timestamp: timestamp3a,
                                 holdings: [cashHold1],
                                 transactions: [miscSub],
                                 assetMap: assetMap,
                                 securityMap: securityMap)
        XCTAssertEqual(ps.nuCashflows.count, 0)
        //XCTAssertEqual(ps.reconciledCashflows.count, 0)
        XCTAssertEqual(ps.nuPositions.count, 1)
        XCTAssertEqual(cashPos1, ps.nuPositions.first)
    }
}
