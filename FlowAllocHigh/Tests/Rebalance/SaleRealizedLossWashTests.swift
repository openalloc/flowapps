//
//  SaleRealizedLossWashTests.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

import XCTest

import SimpleTree

import FlowAllocLow
import FlowBase
import AllocData

@testable import FlowAllocHigh

class SaleRecentlyRealizedLossWashTests: XCTestCase {
    var df: ISO8601DateFormatter!
    var timestamp1: Date!
    var timestamp2: Date!
    var timestamp3: Date!

    let spy = MSecurity.Key(securityID: "SPY")
    let voo = MSecurity.Key(securityID: "VOO")
    let vv = MSecurity.Key(securityID: "VV")
    
    let lc = MAsset.Key(assetID: "LC")

    override func setUpWithError() throws {
        df = ISO8601DateFormatter()
        timestamp1 = df.date(from: "2020-10-01T00:00:00Z")!
        timestamp2 = df.date(from: "2020-11-01T00:00:00Z")!
        timestamp3 = df.date(from: "2020-12-01T00:00:00Z")!
    }

    func testRecentRealizedShortTermLosses() throws {
        let largeCaps = "LC"
        let bonds = "Bond"

        let accounts = [
            MAccount(accountID: "1", title: "Taxable", isActive: true, isTaxable: true),
            MAccount(accountID: "2", title: "IRA", isActive: true, isTaxable: false),
        ]

        let securities = [
            MSecurity(securityID: "SPY", assetID: largeCaps, sharePrice: 1),
            MSecurity(securityID: "VOO", assetID: largeCaps, sharePrice: 1),
            MSecurity(securityID: "VV", assetID: largeCaps, sharePrice: 1),
            MSecurity(securityID: "BND", assetID: bonds, sharePrice: 1),
        ]

        let recentTxns = [
            MTransaction(action: .buysell, transactedAt: timestamp1, accountID: "1", securityID: "SPY", shareCount: -1, sharePrice: 1, realizedGainShort: -40),
            MTransaction(action: .buysell, transactedAt: timestamp1, accountID: "1", securityID: "SPY", shareCount: -1, sharePrice: 1, realizedGainShort: -100),
            MTransaction(action: .buysell, transactedAt: timestamp2, accountID: "1", securityID: "VOO", shareCount: -1, sharePrice: 1, realizedGainShort: -300),
            MTransaction(action: .buysell, transactedAt: timestamp2, accountID: "1", securityID: "VOO", shareCount: -1, sharePrice: 1, realizedGainShort: nil), // should ignore (not specified)
            MTransaction(action: .buysell, transactedAt: timestamp2, accountID: "1", securityID: "BND", shareCount: -1, sharePrice: 1, realizedGainShort: -500), // should ignore (diff asset class)
            MTransaction(action: .buysell, transactedAt: timestamp2, accountID: "1", securityID: "VV", shareCount: -1, sharePrice: 1, realizedGainShort: -700),
            MTransaction(action: .buysell, transactedAt: timestamp2, accountID: "1", securityID: "SPY", shareCount: -1, sharePrice: 1, realizedGainShort: 1100), // it's a gain!
            MTransaction(action: .buysell, transactedAt: timestamp2, accountID: "1", securityID: "SPY", shareCount: 1, sharePrice: 1, realizedGainShort: -1300), // should ignore (purchase)
            MTransaction(action: .buysell, transactedAt: timestamp2, accountID: "1", securityID: "SPY", shareCount: 0, sharePrice: 1, realizedGainShort: -1700), // should ignore (unknown)
            MTransaction(action: .buysell, transactedAt: timestamp2, accountID: "2", securityID: "SPY", shareCount: -1, sharePrice: 1, realizedGainShort: -2300), // should ignore (not taxable)
        ]

        let securityMap = MSecurity.makeAllocMap(securities)
        let accountMap = MAccount.makeAllocMap(accounts)
        let ahMap = MTransaction.getAssetTxnsMap(recentTxns, securityMap)

        let expected: TickerAmountMap = [spy: 960, voo: -300, vv: -700]
        let recentTxns2 = ahMap[lc]!
        let actual = MTransaction.getNetRealizedGainMap(recentSellTxns: recentTxns2, accountMap: accountMap)
        XCTAssertEqual(expected, actual)
    }

    func testRecentRealizedLongTermLosses() throws {
        let largeCaps = "LC"
        let bonds = "Bond"

        let accounts = [
            MAccount(accountID: "1", title: "Taxable", isActive: true, isTaxable: true),
            MAccount(accountID: "2", title: "IRA", isActive: true, isTaxable: false),
        ]

        let securities = [
            MSecurity(securityID: "SPY", assetID: largeCaps, sharePrice: 1),
            MSecurity(securityID: "VOO", assetID: largeCaps, sharePrice: 1),
            MSecurity(securityID: "VV", assetID: largeCaps, sharePrice: 1),
            MSecurity(securityID: "BND", assetID: bonds, sharePrice: 1),
        ]

        let recentTxns = [
            MTransaction(action: .buysell, transactedAt: timestamp1, accountID: "1", securityID: "SPY", shareCount: -1, sharePrice: 1, realizedGainLong: -40),
            MTransaction(action: .buysell, transactedAt: timestamp1, accountID: "1", securityID: "SPY", shareCount: -1, sharePrice: 1, realizedGainLong: -100),
            MTransaction(action: .buysell, transactedAt: timestamp2, accountID: "1", securityID: "VOO", shareCount: -1, sharePrice: 1, realizedGainLong: -300),
            MTransaction(action: .buysell, transactedAt: timestamp2, accountID: "1", securityID: "VOO", shareCount: -1, sharePrice: 1, realizedGainLong: nil), // should ignore (not specified)
            MTransaction(action: .buysell, transactedAt: timestamp2, accountID: "1", securityID: "BND", shareCount: -1, sharePrice: 1, realizedGainLong: -500), // should ignore (diff asset class)
            MTransaction(action: .buysell, transactedAt: timestamp2, accountID: "1", securityID: "VV", shareCount: -1, sharePrice: 1, realizedGainLong: -700),
            MTransaction(action: .buysell, transactedAt: timestamp2, accountID: "1", securityID: "SPY", shareCount: -1, sharePrice: 1, realizedGainLong: 1100), // it's a gain!
            MTransaction(action: .buysell, transactedAt: timestamp2, accountID: "1", securityID: "SPY", shareCount: 1, sharePrice: 1, realizedGainLong: -1300), // should ignore (purchase)
            MTransaction(action: .buysell, transactedAt: timestamp2, accountID: "1", securityID: "SPY", shareCount: 0, sharePrice: 1, realizedGainLong: -1700), // should ignore (unknown)
            MTransaction(action: .buysell, transactedAt: timestamp2, accountID: "2", securityID: "SPY", shareCount: -1, sharePrice: 1, realizedGainLong: -2300), // should ignore (not taxable)
        ]

        let securityMap = MSecurity.makeAllocMap(securities)
        let accountMap = MAccount.makeAllocMap(accounts)
        let ahMap = MTransaction.getAssetTxnsMap(recentTxns, securityMap)

        let expected: TickerAmountMap = [spy: 960, voo: -300, vv: -700]
        let recentTxns2 = ahMap[lc]!
        let actual = MTransaction.getNetRealizedGainMap(recentSellTxns: recentTxns2, accountMap: accountMap)
        XCTAssertEqual(expected, actual)
    }

    func testRecentRealizedMixedLossesAndGains() throws {
        let largeCaps = "LC"
        let bonds = "Bond"

        let accounts = [
            MAccount(accountID: "1", title: "Taxable", isActive: true, isTaxable: true),
            MAccount(accountID: "2", title: "IRA", isActive: true, isTaxable: false),
        ]

        let securities = [
            MSecurity(securityID: "SPY", assetID: largeCaps, sharePrice: 1),
            MSecurity(securityID: "VOO", assetID: largeCaps, sharePrice: 1),
            MSecurity(securityID: "VV", assetID: largeCaps, sharePrice: 1),
            MSecurity(securityID: "BND", assetID: bonds, sharePrice: 1),
        ]

        let recentTxns = [
            MTransaction(action: .buysell, transactedAt: timestamp1, accountID: "1", securityID: "SPY", shareCount: -1, sharePrice: 1, realizedGainShort: 10, realizedGainLong: -50),
            MTransaction(action: .buysell, transactedAt: timestamp1, accountID: "1", securityID: "SPY", shareCount: -1, sharePrice: 1, realizedGainShort: -100, realizedGainLong: 0),
            MTransaction(action: .buysell, transactedAt: timestamp2, accountID: "1", securityID: "VOO", shareCount: -1, sharePrice: 1, realizedGainShort: 0, realizedGainLong: -300),
            MTransaction(action: .buysell, transactedAt: timestamp2, accountID: "1", securityID: "VOO", shareCount: -1, sharePrice: 1, realizedGainShort: nil, realizedGainLong: nil), // should ignore (not specified)
            MTransaction(action: .buysell, transactedAt: timestamp2, accountID: "1", securityID: "BND", shareCount: -1, sharePrice: 1, realizedGainShort: -550, realizedGainLong: 50), // should ignore (diff asset class)
            MTransaction(action: .buysell, transactedAt: timestamp2, accountID: "1", securityID: "VV", shareCount: -1, sharePrice: 1, realizedGainShort: -1, realizedGainLong: -699),
            MTransaction(action: .buysell, transactedAt: timestamp2, accountID: "1", securityID: "SPY", shareCount: -1, sharePrice: 1, realizedGainShort: 100, realizedGainLong: 1000), // It's a gain!
            MTransaction(action: .buysell, transactedAt: timestamp2, accountID: "1", securityID: "SPY", shareCount: 1, sharePrice: 1, realizedGainShort: 0, realizedGainLong: -1300), // should ignore (purchase)
            MTransaction(action: .buysell, transactedAt: timestamp2, accountID: "1", securityID: "SPY", shareCount: 0, sharePrice: 1, realizedGainShort: 0, realizedGainLong: -1700), // should ignore (unknown)
            MTransaction(action: .buysell, transactedAt: timestamp2, accountID: "2", securityID: "SPY", shareCount: -1, sharePrice: 1, realizedGainShort: 0, realizedGainLong: -2300), // should ignore (not taxable)
        ]

        let securityMap = MSecurity.makeAllocMap(securities)
        let accountMap = MAccount.makeAllocMap(accounts)
        let ahMap = MTransaction.getAssetTxnsMap(recentTxns, securityMap)

        let expected: TickerAmountMap = [spy: 960, voo: -300, vv: -700]
        let recentTxns2 = ahMap[lc]!
        let actual = MTransaction.getNetRealizedGainMap(recentSellTxns: recentTxns2, accountMap: accountMap)
        XCTAssertEqual(expected, actual)
    }

    func testHasMissingRealizedGains() throws {
        let now = Date()
        let thirtyDaysBack = getDaysBackMidnight(daysBack: 30, timestamp: now)!
        let weekAgo = getDaysBackMidnight(daysBack: 7, timestamp: now)!
        let thirtyPlusDaysBack = getDaysBackMidnight(daysBack: 30, timestamp: now)! - 1

        struct Foo {
            let id: Int
            let expected: Bool
            let isCash: Bool
            let isActive: Bool
            let isTaxable: Bool
            let shareCount: Double
            let realizedGainShort: Double?
            let transactedAt: Date
        }

        for foo in [
            Foo(id: 0, expected: true, isCash: false, isActive: true, isTaxable: true, shareCount: -1, realizedGainShort: nil, transactedAt: weekAgo),
            Foo(id: 1, expected: false, isCash: false, isActive: true, isTaxable: true, shareCount: 0, realizedGainShort: nil, transactedAt: weekAgo), // need negative share count
            Foo(id: 2, expected: false, isCash: false, isActive: true, isTaxable: true, shareCount: 1, realizedGainShort: nil, transactedAt: weekAgo), // need negative share count
            Foo(id: 3, expected: false, isCash: false, isActive: true, isTaxable: true, shareCount: 0, realizedGainShort: nil, transactedAt: weekAgo), // need negative share count
            Foo(id: 4, expected: false, isCash: false, isActive: true, isTaxable: true, shareCount: -1, realizedGainShort: -1, transactedAt: weekAgo), // gain/loss is specified
            Foo(id: 5, expected: false, isCash: false, isActive: true, isTaxable: true, shareCount: -1, realizedGainShort: 0, transactedAt: weekAgo), // gain/loss is specified
            Foo(id: 6, expected: false, isCash: false, isActive: true, isTaxable: true, shareCount: -1, realizedGainShort: 1, transactedAt: weekAgo), // gain/loss is specified
            Foo(id: 7, expected: false, isCash: false, isActive: false, isTaxable: true, shareCount: -1, realizedGainShort: nil, transactedAt: weekAgo), // only active accounts
            Foo(id: 8, expected: false, isCash: false, isActive: true, isTaxable: false, shareCount: -1, realizedGainShort: nil, transactedAt: weekAgo), // only taxable accounts
            Foo(id: 9, expected: false, isCash: false, isActive: true, isTaxable: true, shareCount: -1, realizedGainShort: nil, transactedAt: thirtyPlusDaysBack), // too old
            Foo(id: 10, expected: false, isCash: true, isActive: true, isTaxable: true, shareCount: -1, realizedGainShort: nil, transactedAt: weekAgo), // ignore cash
        ] {
            let account = MAccount(accountID: "1", isActive: foo.isActive, isTaxable: foo.isTaxable)
            let accountMap = MAccount.makeAllocMap([account])
            let assetID = foo.isCash ? "Cash" : "LC"
            let security = MSecurity(securityID: "SPY", assetID: assetID, sharePrice: 1)
            let securityMap = MSecurity.makeAllocMap([security])
            let txn = MTransaction(action: .buysell, transactedAt: foo.transactedAt, accountID: "1", securityID: "SPY", shareCount: foo.shareCount, sharePrice: 1, realizedGainShort: foo.realizedGainShort)
            let actual = txn.needsRealizedGain(thirtyDaysBack, securityMap, accountMap)
            XCTAssertEqual(foo.expected, actual, "FAILED \(foo.id)")
        }
    }
}
