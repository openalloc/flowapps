//
//  BaseSaleTests.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import XCTest

import FlowBase
import AllocData

@testable import FlowAllocLow

class BaseSaleTests: XCTestCase {
    var securityMap: SecurityMap!

    let account1 = MAccount.Key(accountID: "1")
    let account2 = MAccount.Key(accountID: "2")
    let bond = MAsset.Key(assetID: "Bond")
    let equities = MAsset.Key(assetID: "Equities")
    let bnd = MSecurity.Key(securityID: "BND")

    override func setUp() {
        securityMap = MSecurity.makeAllocMap([MSecurity(securityID: "BND", sharePrice: 1),
                                              MSecurity(securityID: "AGG", sharePrice: 1)])
    }

    func testNoHoldings() throws {
        let so = Sale(assetKey: MAsset.Key(assetID: "Bond"), targetAmount: 100)
        XCTAssertEqual(0, so.proceeds)
        XCTAssertEqual(0, so.netGainLoss)
        XCTAssertEqual(0, so.absoluteGains)
    }

    func testOneHoldingWithGain() throws {
        let h = MHolding(accountID: "1", securityID: "BND", lotID: "", shareCount: 2, shareBasis: 0.50)
        let pv = h.getPresentValue(securityMap)!
        let lh = LiquidateHolding(h, presentValue: pv)
        let so = Sale(assetKey: MAsset.Key(assetID: "Bond"), targetAmount: 100, liquidateHoldings: [lh])
        XCTAssertEqual(2, so.proceeds)
        XCTAssertEqual(1, so.netGainLoss)
        XCTAssertEqual(1, so.absoluteGains)
    }

    func testOneHoldingWithLoss() throws {
        let h = MHolding(accountID: "1", securityID: "BND", lotID: "", shareCount: 2, shareBasis: 1.50)
        let pv = h.getPresentValue(securityMap)!
        let lh = LiquidateHolding(h, presentValue: pv)
        let so = Sale(assetKey: MAsset.Key(assetID: "Bond"), targetAmount: 100, liquidateHoldings: [lh])
        XCTAssertEqual(2, so.proceeds)
        XCTAssertEqual(-1, so.netGainLoss)
        XCTAssertEqual(0, so.absoluteGains)
    }

    func testOneHoldingWithNilShareBasis() throws {
        let h = MHolding(accountID: "1", securityID: "BND", lotID: "", shareCount: 2, shareBasis: nil)
        let pv = h.getPresentValue(securityMap)!
        let lh = LiquidateHolding(h, presentValue: pv)
        let so = Sale(assetKey: MAsset.Key(assetID: "Bond"), targetAmount: 100, liquidateHoldings: [lh])
        XCTAssertEqual(2, so.proceeds)
        XCTAssertEqual(0, so.netGainLoss)
        XCTAssertEqual(0, so.absoluteGains)
    }

    func testOneHoldingWithGainAndFractionalSale() throws {
        let h = MHolding(accountID: "1", securityID: "BND", lotID: "", shareCount: 2, shareBasis: 0.50)
        let pv = h.getPresentValue(securityMap)!
        let lh = LiquidateHolding(h, presentValue: pv, fraction: 0.5) // sell half of position
        XCTAssertEqual(2.0, lh.presentValue)
        XCTAssertEqual(0.5, lh.fraction)
        XCTAssertEqual(0.5, lh.fractionalGainLoss)
        XCTAssertEqual(1.0, lh.fractionalShareCount)
        XCTAssertEqual(1.0, lh.fractionalValue)
        let so = Sale(assetKey: MAsset.Key(assetID: "Bond"), targetAmount: 100, liquidateHoldings: [lh])
        XCTAssertEqual(1, so.proceeds)
        XCTAssertEqual(0.5, so.netGainLoss)
        XCTAssertEqual(0.5, so.absoluteGains)
    }

    func testOneHoldingWithLossAndFractionalSale() throws {
        let h = MHolding(accountID: "1", securityID: "BND", lotID: "", shareCount: 2, shareBasis: 1.50)
        let pv = h.getPresentValue(securityMap)!
        let lh = LiquidateHolding(h, presentValue: pv, fraction: 0.5) // sell half of position
        XCTAssertEqual(2.0, lh.presentValue)
        XCTAssertEqual(0.5, lh.fraction)
        XCTAssertEqual(-0.5, lh.fractionalGainLoss)
        XCTAssertEqual(1.0, lh.fractionalShareCount)
        XCTAssertEqual(1.0, lh.fractionalValue)
        let so = Sale(assetKey: MAsset.Key(assetID: "Bond"), targetAmount: 100, liquidateHoldings: [lh])
        XCTAssertEqual(1, so.proceeds)
        XCTAssertEqual(-0.5, so.netGainLoss)
        XCTAssertEqual(0, so.absoluteGains)
    }

    func testTwoHoldingsWithGainAndLoss() throws {
        let h1 = MHolding(accountID: "1", securityID: "BND", lotID: "", shareCount: 2, shareBasis: 1.50) // loss 1.0
        let h2 = MHolding(accountID: "1", securityID: "AGG", lotID: "", shareCount: 2, shareBasis: 0.75) // gain 0.5
        let pv1 = h1.getPresentValue(securityMap)!
        let pv2 = h2.getPresentValue(securityMap)!
        let lh1 = LiquidateHolding(h1, presentValue: pv1)
        let lh2 = LiquidateHolding(h2, presentValue: pv2)
        let so = Sale(assetKey: MAsset.Key(assetID: "Bond"), targetAmount: 100, liquidateHoldings: [lh1, lh2])
        XCTAssertEqual(4, so.proceeds)
        XCTAssertEqual(-0.5, so.netGainLoss)
        XCTAssertEqual(0.5, so.absoluteGains)
    }
}
