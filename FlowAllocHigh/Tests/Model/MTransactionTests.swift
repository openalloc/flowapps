//
//  MTransactionTests.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import XCTest

import FlowAllocLow
import FlowBase
import AllocData

@testable import FlowAllocHigh

class MTransactionTests: XCTestCase {
    var df: ISO8601DateFormatter!
    var timestamp1: Date!
    var timestamp2: Date!
    var timestamp3: Date!

    var bondKey: MAsset.Key!
    var lcKey: MAsset.Key!

    var spx: MTracker!
    var spxKey: MTracker.Key!

    var spy: MSecurity!
    var voo: MSecurity!
    var bnd: MSecurity!
    var agg: MSecurity!
    
    var spyKey: MSecurity.Key!
    var vooKey: MSecurity.Key!
    var bndKey: MSecurity.Key!
    var aggKey: MSecurity.Key!

    var securityMap: SecurityMap!
    var trackerSecuritiesMap: TrackerSecuritiesMap!

    var hA: MTransaction!
    var hB: MTransaction!
    var hC: MTransaction!
    var hD: MTransaction!
    var hE: MTransaction!
    var hF: MTransaction!
    var hG: MTransaction!
    var hH: MTransaction!
    var hI: MTransaction!

    var transactions: [MTransaction]!

    override func setUpWithError() throws {
        df = ISO8601DateFormatter()
        timestamp1 = df.date(from: "2020-10-01T00:00:00Z")!
        timestamp2 = df.date(from: "2020-11-01T00:00:00Z")!
        timestamp3 = df.date(from: "2020-12-01T00:00:00Z")!
        
        bondKey = MAsset.Key(assetID: "Bond")
        lcKey = MAsset.Key(assetID: "LC")

        spx = MTracker(trackerID: "SPX", title: "S&P 500")

        spxKey = spx.primaryKey

        spy = MSecurity(securityID: "SPY", assetID: "LC", trackerID: "SPX")
        voo = MSecurity(securityID: "VOO", assetID: "LC", trackerID: "SPX")
        bnd = MSecurity(securityID: "BND", assetID: "Bond")
        agg = MSecurity(securityID: "AGG", assetID: "Bond")

        spyKey = spy.primaryKey
        vooKey = voo.primaryKey
        bndKey = bnd.primaryKey
        aggKey = agg.primaryKey

        hA = MTransaction(action: .buysell, transactedAt: timestamp1, accountID: "1", securityID: "SPY", shareCount: 1, sharePrice: 1)
        hB = MTransaction(action: .buysell, transactedAt: timestamp1, accountID: "2", securityID: "VOO", shareCount: 1, sharePrice: 1)
        hC = MTransaction(action: .buysell, transactedAt: timestamp1, accountID: "3", securityID: "BND", shareCount: -1, sharePrice: 1)
        hD = MTransaction(action: .buysell, transactedAt: timestamp1, accountID: "4", securityID: "AGG", shareCount: 1, sharePrice: 1)
        hE = MTransaction(action: .buysell, transactedAt: timestamp1, accountID: "5", securityID: "SPY", shareCount: -1, sharePrice: 1)
        hF = MTransaction(action: .buysell, transactedAt: timestamp1, accountID: "6", securityID: "VOO", shareCount: 1, sharePrice: 1)
        hG = MTransaction(action: .buysell, transactedAt: timestamp1, accountID: "7", securityID: "BND", shareCount: -1, sharePrice: 1)
        hH = MTransaction(action: .buysell, transactedAt: timestamp1, accountID: "8", securityID: "AGG", shareCount: 1, sharePrice: 1)
        hI = MTransaction(action: .buysell, transactedAt: timestamp1, accountID: "9", securityID: "UNKNOWN", shareCount: -1, sharePrice: 1)
    }


    override func setUp() {
        securityMap = [
            spyKey: spy,
            vooKey: voo,
            bndKey: bnd,
            aggKey: agg,
        ]
        trackerSecuritiesMap = [spxKey: [spy, voo]]
        transactions = [hA, hB, hC, hD, hE, hF, hG, hH, hI]
    }

    func testGetAssetTxnsMap() throws {
        let expected: AssetTxnsMap = [lcKey: [hA, hB, hE, hF], bondKey: [hC, hD, hG, hH]]
        let actual = MTransaction.getAssetTxnsMap(transactions, securityMap)
        XCTAssertEqual(expected, actual)
    }

    func testGetRecentPurchasesMap() throws {
        let actual = MTransaction.getRecentPurchasesMap(recentBuyTxns: transactions)
        let expected = [aggKey: [PurchaseInfo(tickerKey: aggKey, shareCount: 1.0, shareBasis: 1.0),
                                PurchaseInfo(tickerKey: aggKey, shareCount: 1.0, shareBasis: 1.0)],
                        spyKey: [PurchaseInfo(tickerKey: spyKey, shareCount: 1.0, shareBasis: 1.0)],
                        vooKey: [PurchaseInfo(tickerKey: vooKey, shareCount: 1.0, shareBasis: 1.0),
                                PurchaseInfo(tickerKey: vooKey, shareCount: 1.0, shareBasis: 1.0)]]
        XCTAssertEqual(expected, actual)
    }

    func testGetRecentHistory() throws {
        let df = ISO8601DateFormatter()
        let since = df.date(from: "2020-05-31T14:00:00Z")! // baseline date

        //let noDate =   MTransaction(action: .buysell, transactedAt: timestamp1, accountID: "1", securityID: "SPY", shareCount: 12, sharePrice: 110)
        let outside =  MTransaction(action: .buysell, transactedAt: since - 1, accountID: "2", securityID: "SPY", shareCount: 12, sharePrice: 110)
        let atBorder = MTransaction(action: .buysell, transactedAt: since, accountID: "3", securityID: "SPY", shareCount: 12, sharePrice: 110)
        let inside =   MTransaction(action: .buysell, transactedAt: since + 1, accountID: "4", securityID: "SPY", shareCount: 12, sharePrice: 110)

        let model = BaseModel(transactions: [outside, atBorder, inside]) //noDate, 

        let expected = [inside, atBorder]
        let actual = model.getRecentTxns(since: since)
        XCTAssertEqual(Set(expected), Set(actual))
    }

    func testGetNetRealizedGainMap() throws {
        let account = MAccount(accountID: "1", title: "X", isActive: true, isTaxable: true, canTrade: true)
        let accountMap = MAccount.makeAllocMap([account])
        let hA = MTransaction(action: .buysell, transactedAt: timestamp1, accountID: "1", securityID: "SPY", shareCount: -1, sharePrice: 1, realizedGainShort: 3, realizedGainLong: -6)
        let hB = MTransaction(action: .buysell, transactedAt: timestamp1, accountID: "1", securityID: "SPY", shareCount: -1, sharePrice: 1, realizedGainShort: -5, realizedGainLong: 1)
        let hC = MTransaction(action: .buysell, transactedAt: timestamp1, accountID: "1", securityID: "BND", shareCount: -1, sharePrice: 1, realizedGainShort: 5, realizedGainLong: -3)
        let hD = MTransaction(action: .buysell, transactedAt: timestamp1, accountID: "1", securityID: "BND", shareCount: 1, sharePrice: 1, realizedGainShort: 5000, realizedGainLong: -300_000) // ignore
        let recentTxns = [hA, hB, hC, hD]
        let actual = MTransaction.getNetRealizedGainMap(recentSellTxns: recentTxns, accountMap: accountMap)
        let expected: TickerAmountMap = [spyKey: -7, bndKey: 2]
        XCTAssertEqual(expected, actual)
    }

    func testGetRecentPurchaseMap() throws {
        let hA = MTransaction(action: .buysell, transactedAt: timestamp1, accountID: "1", securityID: "SPY", shareCount: 1, sharePrice: 1)
        let hB = MTransaction(action: .buysell, transactedAt: timestamp1, accountID: "1", securityID: "SPY", shareCount: -1, sharePrice: 3) // ignore
        let hC = MTransaction(action: .buysell, transactedAt: timestamp1, accountID: "1", securityID: "BND", shareCount: 1, sharePrice: 5)
        let hD = MTransaction(action: .buysell, transactedAt: timestamp1, accountID: "1", securityID: "BND", shareCount: 1, sharePrice: 7)
        let recentTxns2 = [hA, hB, hC, hD]
        let actual = MTransaction.getRecentTickerPurchaseMap(recentBuyTxns: recentTxns2) // NOTE map not properly filtered
        let expected: TickerAmountMap = [spyKey: 1, bndKey: 12]
        XCTAssertEqual(expected, actual)
    }
}
