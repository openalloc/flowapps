//
//  ExampleTests.swift
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

class ExampleTests: XCTestCase {
    var tz: TimeZone!
    var df: ISO8601DateFormatter!

    override func setUpWithError() throws {
        tz = TimeZone.init(identifier: "EST")!
        df = ISO8601DateFormatter()
    }

    // https://en.wikipedia.org/wiki/Modified_Dietz_method#Adjustments
    func testWP1() throws {
        let ts1 = df.date(from: "2016-01-01T00:00:00Z")!
        let ts2 = df.date(from: "2016-12-30T23:59:59Z")!
        let ts3 = df.date(from: "2016-12-31T23:59:59Z")!
        
        let account = MAccount(accountID: "1")
        let accountMap = [account.primaryKey: account]
        let asset2 = MAsset(assetID: "Cash")
        let asset3 = MAsset(assetID: "LC")
        let assetMap = [asset2.primaryKey: asset2, asset3.primaryKey: asset3]
        let security2 = MSecurity(securityID: "CORE", assetID: "Cash", sharePrice: 1)
        let security3 = MSecurity(securityID: "SPY", assetID: "LC", sharePrice: 8.181)
        let securityMap = [security2.primaryKey: security2, security3.primaryKey: security3]
        let txn2a = MTransaction(action: .transfer,
                                 transactedAt: ts2,
                                 accountID: "1",
                                 securityID: "CORE",
                                 lotID: "",
                                 shareCount: 8_100_000,
                                 sharePrice: 1)
        let txn2b = MTransaction(action: .buysell,
                                 transactedAt: ts2,
                                 accountID: "1",
                                 securityID: "SPY",
                                 lotID: "",
                                 shareCount: 1_000_000, // buy
                                 sharePrice: 8.1)
        let holding = MHolding(accountID: "1", securityID: "SPY", lotID: "", shareCount: 1_000_000, shareBasis: 8.1)
        let prevSnapshot = MValuationSnapshot(snapshotID: "1", capturedAt: ts1)
        let pending = PendingSnapshot(snapshotID: "2",
                                      timestamp: ts3, // end of period
                                      holdings: [holding],
                                      transactions: [txn2a, txn2b],
                                      previousSnapshot: prevSnapshot,
                                      previousPositions: [],
                                      accountMap: accountMap,
                                      assetMap: assetMap,
                                      securityMap: securityMap)
        XCTAssertEqual(8_181_000, pending.periodSummary?.endMarketValue ?? 0, accuracy: 0.01)
        XCTAssertEqual(0.01, pending.periodSummary?.dietz?.performance ?? -1, accuracy: 0.01)
    }
    
    // https://en.wikipedia.org/wiki/Modified_Dietz_method#Second_example
    func testWP2() throws {
        let ts1 = df.date(from: "2016-01-01T00:00:00Z")!
        let ts2 = df.date(from: "2016-11-14T12:00:00Z")!
        let ts3 = df.date(from: "2016-11-17T12:00:00Z")!
        
        let account = MAccount(accountID: "1")
        let accountMap = [account.primaryKey: account]
        let asset2 = MAsset(assetID: "Cash")
        let asset3 = MAsset(assetID: "Bond")
        let assetMap = [asset2.primaryKey: asset2, asset3.primaryKey: asset3]
        let security2 = MSecurity(securityID: "CORE", assetID: "Cash", sharePrice: 1)
        let security3 = MSecurity(securityID: "BND", assetID: "Bond", sharePrice: 1_125_990)
        let securityMap = [security2.primaryKey: security2, security3.primaryKey: security3]
        let txn2a = MTransaction(action: .transfer,
                                 transactedAt: ts2,
                                 accountID: "1",
                                 securityID: "CORE",
                                 lotID: "",
                                 shareCount: 1_128_728,
                                 sharePrice: 1)
        let txn2b = MTransaction(action: .buysell,
                                 transactedAt: ts2,
                                 accountID: "1",
                                 securityID: "BND",
                                 lotID: "",
                                 shareCount: 1, // buy
                                 sharePrice: 1_128_728)
        let txn2c = MTransaction(action: .buysell,
                                 transactedAt: ts3,
                                 accountID: "1",
                                 securityID: "BND",
                                 lotID: "",
                                 shareCount: -1, // sold
                                 sharePrice: 1_125_990)
        let holding = MHolding(accountID: "1", securityID: "BND", lotID: "", shareCount: 1, shareBasis: 1_128_728)
        let prevSnapshot = MValuationSnapshot(snapshotID: "1", capturedAt: ts1)
        let pending = PendingSnapshot(snapshotID: "2",
                                      timestamp: ts3, // end of period
                                      holdings: [holding],
                                      transactions: [txn2a, txn2b, txn2c],
                                      previousSnapshot: prevSnapshot,
                                      previousPositions: [],
                                      accountMap: accountMap,
                                      assetMap: assetMap,
                                      securityMap: securityMap)
        XCTAssertEqual(1_125_990, pending.periodSummary?.endMarketValue ?? 0, accuracy: 0.01)
        XCTAssertEqual(-0.00243, pending.periodSummary?.dietz?.performance ?? -1, accuracy: 0.00001)
    }
    
    // https://en.wikipedia.org/wiki/Modified_Dietz_method#Example_3
    func testWP3() throws {
        let ts0 = df.date(from: "2016-01-01T12:00:00Z")!
        let ts1 = df.date(from: "2016-01-01T12:00:01Z")!
        let ts2 = df.date(from: "2016-10-01T12:00:00Z")! // beg of 4th quarter
        let ts3 = df.date(from: "2016-12-31T12:00:00Z")!
        
        let account = MAccount(accountID: "1")
        let accountMap = [account.primaryKey: account]
        let asset2 = MAsset(assetID: "Cash")
        let asset3 = MAsset(assetID: "LC")
        let assetMap = [asset2.primaryKey: asset2, asset3.primaryKey: asset3]
        let security2 = MSecurity(securityID: "CORE", assetID: "Cash", sharePrice: 1)
        let security3 = MSecurity(securityID: "X", assetID: "LC", sharePrice: 110)
        let securityMap = [security2.primaryKey: security2, security3.primaryKey: security3]
        let txn2a = MTransaction(action: .transfer,
                                 transactedAt: ts1,
                                 accountID: "1",
                                 securityID: "CORE",
                                 lotID: "",
                                 shareCount: 10_000,
                                 sharePrice: 1)
        let txn2b = MTransaction(action: .buysell,
                                 transactedAt: ts2,
                                 accountID: "1",
                                 securityID: "X",
                                 lotID: "",
                                 shareCount: 80, // buy
                                 sharePrice: 100)
        let holding1 = MHolding(accountID: "1", securityID: "CORE", lotID: "", shareCount: 2100, shareBasis: 1)
        let holding2 = MHolding(accountID: "1", securityID: "X", lotID: "", shareCount: 80, shareBasis: 100)
        let prevSnapshot = MValuationSnapshot(snapshotID: "1", capturedAt: ts0)
        let pending = PendingSnapshot(snapshotID: "2",
                                      timestamp: ts3, // end of period
                                      holdings: [holding1, holding2],
                                      transactions: [txn2a, txn2b],
                                      previousSnapshot: prevSnapshot,
                                      previousPositions: [],
                                      accountMap: accountMap,
                                      assetMap: assetMap,
                                      securityMap: securityMap)
        XCTAssertEqual(10_900, pending.periodSummary?.endMarketValue ?? 0, accuracy: 0.01)
        XCTAssertEqual(0.09, pending.periodSummary?.dietz?.performance ?? -1, accuracy: 0.0001)
    }
    
    // https://www.wallstreetmojo.com/modified-dietz/
    func testMojo() throws {
        let ts0 = df.date(from: "2016-01-01T12:00:00Z")!
        let ts1 = df.date(from: "2016-01-01T12:00:01Z")!
        let ts2 = df.date(from: "2017-01-01T12:00:00Z")!
        let ts3 = df.date(from: "2018-01-01T12:00:00Z")!
        
        let account = MAccount(accountID: "1")
        let accountMap = [account.primaryKey: account]
        let asset2 = MAsset(assetID: "Cash")
        let asset3 = MAsset(assetID: "LC")
        let assetMap = [asset2.primaryKey: asset2, asset3.primaryKey: asset3]
        let security2 = MSecurity(securityID: "CORE", assetID: "Cash", sharePrice: 1)
        let security3 = MSecurity(securityID: "X", assetID: "LC", sharePrice: 2300)
        let securityMap = [security2.primaryKey: security2, security3.primaryKey: security3]
        let txn2a = MTransaction(action: .transfer,
                                 transactedAt: ts1,
                                 accountID: "1",
                                 securityID: "CORE",
                                 lotID: "",
                                 shareCount: 1_000_000,
                                 sharePrice: 1)
        let txn2b = MTransaction(action: .buysell,
                                 transactedAt: ts1,
                                 accountID: "1",
                                 securityID: "X",
                                 lotID: "",
                                 shareCount: 1000, // buy
                                 sharePrice: 1000)
        let txn2c = MTransaction(action: .transfer,
                                 transactedAt: ts2,
                                 accountID: "1",
                                 securityID: "CORE",
                                 lotID: "",
                                 shareCount: 500_000,
                                 sharePrice: 1)
        let txn2d = MTransaction(action: .buysell,
                                 transactedAt: ts2,
                                 accountID: "1",
                                 securityID: "X",
                                 lotID: "",
                                 shareCount: 500, // buy
                                 sharePrice: 1000)
        let holding1 = MHolding(accountID: "1", securityID: "X", lotID: "", shareCount: 1000, shareBasis: 1)
        let prevSnapshot = MValuationSnapshot(snapshotID: "1", capturedAt: ts0)
        let pending = PendingSnapshot(snapshotID: "2",
                                      timestamp: ts3, // end of period
                                      holdings: [holding1],
                                      transactions: [txn2a, txn2b, txn2c, txn2d],
                                      previousSnapshot: prevSnapshot,
                                      previousPositions: [],
                                      accountMap: accountMap,
                                      assetMap: assetMap,
                                      securityMap: securityMap)
        XCTAssertEqual(2_300_000, pending.periodSummary?.endMarketValue ?? 0, accuracy: 0.01)
        XCTAssertEqual(0.64, pending.periodSummary?.dietz?.performance ?? -1, accuracy: 0.01)
    }
}
