//
//  SaleWashTests.swift
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

class SaleWashTests: XCTestCase {
    
    let bnd = MSecurity.Key(securityID: "BND")
    let spy = MSecurity.Key(securityID: "SPY")
    let voo = MSecurity.Key(securityID: "VOO")
    let xlk = MSecurity.Key(securityID: "XLK")
    
    let lc = MAsset.Key(assetID: "LC")

    func testGetWashAmount() throws {
        let securities = [
            MSecurity(securityID: "VOO", assetID: "LC", sharePrice: 100.0),
            MSecurity(securityID: "SPY", assetID: "LC", sharePrice: 200.0),
        ]
        let securityMap = MSecurity.makeAllocMap(securities)
        let trackerSecuritiesMap = MTracker.getTrackerSecuritiesMap(securities)

        let recentPurchasesMap = [
            spy: [
                PurchaseInfo(tickerKey: spy, shareCount: 10, shareBasis: 1), // purchase of $10 (now worth $2.50)
                PurchaseInfo(tickerKey: spy, shareCount: -2, shareBasis: 1), // shed two shares from position (which may include ancient shares, and itself was a wash sale)
            ],
        ]

        let holding = MHolding(accountID: "1", securityID: "SPY", lotID: "", shareCount: 8, shareBasis: 1)
        let lh = LiquidateHolding(holding, presentValue: 2.0, fraction: 1.0)
        let sale = Sale(assetKey: lc, targetAmount: 100.0, liquidateHoldings: [lh])
        let expected = 6.0 // wash, ((10-2) * 1) - ((10-2) * 0.25) = 8 - 2 = 6
        let actual = sale.getWashAmount(recentPurchasesMap: recentPurchasesMap,
                                        securityMap: securityMap,
                                        trackerSecuritiesMap: trackerSecuritiesMap)
        XCTAssertEqual(expected, actual)
    }

    func testEquivalentTickerKeys() throws {
        let tracker = MTracker(trackerID: "1", title: "S&P500")

        let securities = [
            MSecurity(securityID: "VOO", assetID: "LC", sharePrice: 100.0, trackerID: tracker.trackerID),
            MSecurity(securityID: "SPY", assetID: "LC", sharePrice: 200.0, trackerID: tracker.trackerID),
        ]
        let securityMap = MSecurity.makeAllocMap(securities)
        let trackerSecuritiesMap = MTracker.getTrackerSecuritiesMap(securities)

        let recentPurchasesMap = [
            voo: [
                PurchaseInfo(tickerKey: voo, shareCount: 10, shareBasis: 90.0), // purchase of $10 (now worth $2.50)
            ],
        ]

        let holding = MHolding(accountID: "1", securityID: "SPY", lotID: "", shareCount: 8, shareBasis: 150.0)
        let lh = LiquidateHolding(holding, presentValue: 125.0 * 8, fraction: 1.0) // selling at a loss
        let sale = Sale(assetKey: lc, targetAmount: 1000.0, liquidateHoldings: [lh])
        let expected = 200.0
        let actual = sale.getWashAmount(recentPurchasesMap: recentPurchasesMap,
                                        securityMap: securityMap,
                                        trackerSecuritiesMap: trackerSecuritiesMap)
        XCTAssertEqual(expected, actual)
    }

    func testSchwabExampleSellingHalf() throws {
        let recentTxns = [
            PurchaseInfo(tickerKey: spy, shareCount: 100, shareBasis: 2),
        ]
        let sellShareCount = 50.0
        let sellSharePrice = 1.0
        let netGainLoss = sellShareCount * (sellSharePrice - 2)
        let actual = Sale.getSaleWash(recentTxns,
                                      netGainLoss: netGainLoss)
        let expected = 50.0 // wash!
        XCTAssertEqual(expected, actual)
    }

    func testSchwabExampleSellingAll() throws {
        let recentTxns = [
            PurchaseInfo(tickerKey: spy, shareCount: 100, shareBasis: 2),
        ]
        let sellShareCount = 100.0
        let sellSharePrice = 1.0
        let netGainLoss = sellShareCount * (sellSharePrice - 2)
        let actual = Sale.getSaleWash(recentTxns,
                                      netGainLoss: netGainLoss)
        let expected = 100.0 // wash!
        XCTAssertEqual(expected, actual)
    }

    func testLosingSaleNoRecentPurchase() throws {
        let recentTxns: [PurchaseInfo] = []
        let sellShareCount = 100.0
        let sellSharePrice = 0.25
        let netGainLoss = sellShareCount * (sellSharePrice - 0)
        let actual = Sale.getSaleWash(recentTxns,
                                      netGainLoss: netGainLoss)
        let expected = 0.0 // no wash
        XCTAssertEqual(expected, actual)
    }

    func testProfitableSaleNoRecentPurchase() throws {
        let recentTxns: [PurchaseInfo] = []
        let sellShareCount = 10.0 // at a realized gain of $2.50
        let sellSharePrice = 1.25
        let netGainLoss = sellShareCount * (sellSharePrice - 0)
        let actual = Sale.getSaleWash(recentTxns,
                                      netGainLoss: netGainLoss)
        let expected = 0.0 // no wash
        XCTAssertEqual(expected, actual)
    }

    func testProfitableSaleSinceRecentPurchase() throws {
        let recentTxns = [
            PurchaseInfo(tickerKey: spy, shareCount: 10, shareBasis: 1), // had purchased $10
        ]
        let sellShareCount = 10.0
        let sellSharePrice = 1.25
        let netGainLoss = sellShareCount * (sellSharePrice - 1)
        let actual = Sale.getSaleWash(recentTxns,
                                      netGainLoss: netGainLoss)
        let expected = 0.0 // no wash
        XCTAssertEqual(expected, actual)
    }

    func testSmallLosingSaleSinceRecentPurchase() throws {
        let recentTxns = [
            PurchaseInfo(tickerKey: spy, shareCount: 10, shareBasis: 1), // had purchased $10
        ]
        let sellShareCount = 10.0
        let sellSharePrice = 0.25
        let netGainLoss = sellShareCount * (sellSharePrice - 1)
        let actual = Sale.getSaleWash(recentTxns,
                                      netGainLoss: netGainLoss)
        let expected = 7.5 // wash!
        XCTAssertEqual(expected, actual)
    }

    func testLargeLosingSaleSinceRecentPurchase() throws {
        let recentTxns = [
            PurchaseInfo(tickerKey: spy, shareCount: 10, shareBasis: 1), // had purchased $10 (now worth $2.50)
        ]
        let netGainLoss = -7.5
        let actual = Sale.getSaleWash(recentTxns,
                                      netGainLoss: netGainLoss)
        let expected = 7.5 // wash!
        XCTAssertEqual(expected, actual)
    }

    func testSaleSinceRecentUnknownSharePrice() {
        let recentTxns: [PurchaseInfo] = []
        let sellShareCount = 10.0
        let sellSharePrice = 1.25
        let netGainLoss = sellShareCount * (sellSharePrice - 0)
        let actual = Sale.getSaleWash(recentTxns,
                                      netGainLoss: netGainLoss)
        let expected = 0.0
        XCTAssertEqual(expected, actual)
    }

    func testSaleSinceRecentUnknownShareCount() {
        let recentTxns: [PurchaseInfo] = []
        let sellShareCount = 10.0
        let sellSharePrice = 1.25
        let netGainLoss = sellShareCount * (sellSharePrice - 0)
        let actual = Sale.getSaleWash(recentTxns,
                                      netGainLoss: netGainLoss)
        let expected = 0.0
        XCTAssertEqual(expected, actual)
    }

    func testLosingSaleSincePurchaseAndSaleLoss() throws {
        let recentTxns = [
            PurchaseInfo(tickerKey: spy, shareCount: 10, shareBasis: 1), // purchase of $10 (now worth $2.50)
            PurchaseInfo(tickerKey: spy, shareCount: -2, shareBasis: 1), // shed two shares from position (which may include ancient shares, and itself was a wash sale)
        ]
        let sellShareCount = 8.0 // sell remaining shares
        let sellSharePrice = 0.25
        let netGainLoss = sellShareCount * (sellSharePrice - 1)
        let actual = Sale.getSaleWash(recentTxns,
                                      netGainLoss: netGainLoss)
        let expected = 6.0 // wash, ((10-2) * 1) - ((10-2) * 0.25) = 8 - 2 = 6
        XCTAssertEqual(expected, actual)
    }

    // shares have DROPPED in price since our purchase, which was within 30-day window,
    // SO we cannot claim the loss. It's a wash of $544
    func testXLK() throws {
        let recentTxns = [
            PurchaseInfo(tickerKey: xlk,
                         shareCount: 37.289936207677897, // recent purchase
                         shareBasis: 159.20643393845072),
        ]
        let netGainLoss = -544.35916977136003
        let actual = Sale.getSaleWash(recentTxns,
                                      netGainLoss: netGainLoss)
        let expected = 544.35916977136003
        XCTAssertEqual(expected, actual, accuracy: 0.0001)
    }
}
