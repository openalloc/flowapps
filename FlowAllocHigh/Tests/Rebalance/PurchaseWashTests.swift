//
//  PurchaseWashTests.swift
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

class PurchaseWashTests: XCTestCase {
    var df: ISO8601DateFormatter!
    var timestamp1: Date!
    var timestamp2: Date!
    var timestamp3: Date!

    override func setUpWithError() throws {
        df = ISO8601DateFormatter()
        timestamp1 = df.date(from: "2020-10-01T00:00:00Z")!
        timestamp2 = df.date(from: "2020-11-01T00:00:00Z")!
        timestamp3 = df.date(from: "2020-12-01T00:00:00Z")!
    }
    
    func testAmountOnPotentialWash() throws {
        let assetTxnsMap = [
            MAsset.Key(assetID: "LC"): [
                MTransaction(action: .buysell, transactedAt: timestamp1, accountID: "1", securityID: "SPY", shareCount: 10, sharePrice: 1), // purchase of $10
                MTransaction(action: .buysell, transactedAt: timestamp1, accountID: "1", securityID: "SPY", shareCount: -1, realizedGainShort: -5), // had sold, at a realized loss of $5
            ],
        ]
        let purchase = Purchase(assetKey: MAsset.Key(assetID: "LC"), amount: 100.0)
        let expected = -5.0 // wash
        let actual = purchase.getWashAmount(assetSellTxnsMap: assetTxnsMap) // NOTE map not properly filtered
        XCTAssertEqual(expected, actual)
    }

    func testSchwabRepurchaseExample() throws {
        let recentTxns = [
            MTransaction(action: .buysell, transactedAt: timestamp1, accountID: "1", securityID: "SPY", shareCount: -100, realizedGainShort: -200),
        ]
        let buyAmount = 600.0
        let actual = Purchase.getPurchaseWash(recentTxns, buyAmount: buyAmount)
        let expected = -200.0 // wash
        XCTAssertEqual(expected, actual)
    }

    func testSmallPurchaseSinceLosingSale() throws {
        let recentTxns = [
            MTransaction(action: .buysell, transactedAt: timestamp1, accountID: "1", securityID: "SPY", shareCount: -1, realizedGainShort: -5), // had sold, at a realized loss of $5
        ]
        let buyAmount = 1.0
        let actual = Purchase.getPurchaseWash(recentTxns, buyAmount: buyAmount)
        let expected = -1.0 // wash
        XCTAssertEqual(expected, actual)
    }

    func testLargePurchaseSinceLosingSale() throws {
        let recentTxns = [
            MTransaction(action: .buysell, transactedAt: timestamp1, accountID: "1", securityID: "SPY", shareCount: -1, realizedGainShort: -5), // had sold, at a realized loss of $5
        ]
        let buyAmount = 100.0
        let actual = Purchase.getPurchaseWash(recentTxns, buyAmount: buyAmount)
        let expected = -5.0 // wash
        XCTAssertEqual(expected, actual)
    }

    func testPurchaseSinceProfitableSale() throws {
        let recentTxns = [
            MTransaction(action: .buysell, transactedAt: timestamp1, accountID: "1", securityID: "SPY", realizedGainShort: 5), // had sold, at a realized gain of $5
        ]
        let buyAmount = 20.0
        let actual = Purchase.getPurchaseWash(recentTxns, buyAmount: buyAmount)
        let expected = 0.0 // no wash
        XCTAssertEqual(expected, actual)
    }

    func testLongGainShortLoss() throws {
        let recentTxns = [
            MTransaction(action: .buysell, transactedAt: timestamp1, accountID: "1", securityID: "SPY", shareCount: -1, realizedGainShort: -13, realizedGainLong: 7),
        ]
        let buyAmount = 20.0
        let actual = Purchase.getPurchaseWash(recentTxns, buyAmount: buyAmount)
        let expected = -6.0
        XCTAssertEqual(expected, actual)
    }

    func testPurchaseSinceUnknownSale() throws {
        let recentTxns = [
            MTransaction(action: .buysell, transactedAt: timestamp1, accountID: "1", securityID: "SPY", shareCount: -1, realizedGainShort: nil), // had sold, at a realized gain of $5
        ]
        let buyAmount = 20.0
        let actual = Purchase.getPurchaseWash(recentTxns, buyAmount: buyAmount)
        let expected = 0.0
        XCTAssertEqual(expected, actual)
    }

    func testSmallPurchaseSincePurchaseAndSaleLoss() throws {
        let recentTxns = [
            MTransaction(action: .buysell, transactedAt: timestamp1, accountID: "1", securityID: "SPY", shareCount: 10, sharePrice: 1), // purchase of $10
            MTransaction(action: .buysell, transactedAt: timestamp1, accountID: "1", securityID: "SPY", shareCount: -1, realizedGainShort: -5), // had sold, at a realized loss of $5
        ]
        let buyAmount = 1.0
        let actual = Purchase.getPurchaseWash(recentTxns, buyAmount: buyAmount)
        let expected = -1.0 // wash
        XCTAssertEqual(expected, actual)
    }

    func testLargePurchaseSincePurchaseAndSaleLoss() throws {
        let recentTxns = [
            MTransaction(action: .buysell, transactedAt: timestamp1, accountID: "1", securityID: "SPY", shareCount: 10, sharePrice: 1), // purchase of $10
            MTransaction(action: .buysell, transactedAt: timestamp1, accountID: "1", securityID: "SPY", shareCount: -1, realizedGainShort: -5), // had sold, at a realized loss of $5
        ]
        let buyAmount = 100.0
        let actual = Purchase.getPurchaseWash(recentTxns, buyAmount: buyAmount)
        let expected = -5.0 // wash
        XCTAssertEqual(expected, actual)
    }

    func testSmallPurchaseSincePurchaseAndLargeSaleLoss() throws {
        let recentTxns = [
            MTransaction(action: .buysell, transactedAt: timestamp1, accountID: "1", securityID: "SPY", shareCount: 10, sharePrice: 4), // purchase of $40
            MTransaction(action: .buysell, transactedAt: timestamp1, accountID: "1", securityID: "SPY", shareCount: -1, realizedGainShort: -50), // had sold, at a realized loss of $50 (from ancient shares)
        ]
        let buyAmount = 20.0
        let actual = Purchase.getPurchaseWash(recentTxns, buyAmount: buyAmount)
        let expected = -20.0 // wash
        XCTAssertEqual(expected, actual)
    }

    func testLargePurchaseSincePurchaseAndLargeSaleLoss() throws {
        let recentTxns = [
            MTransaction(action: .buysell, transactedAt: timestamp1, accountID: "1", securityID: "SPY", shareCount: 10, sharePrice: 4), // purchase of $40
            MTransaction(action: .buysell, transactedAt: timestamp1, accountID: "1", securityID: "SPY", shareCount: -1, sharePrice: 1, realizedGainShort: -50), // had sold, at a realized loss of $50 (could be from ancient shares too)
        ]
        let buyAmount = 100.0
        let actual = Purchase.getPurchaseWash(recentTxns, buyAmount: buyAmount)
        let expected = -50.0 // wash  (TODO is this correct?)
        XCTAssertEqual(expected, actual)
    }
}
