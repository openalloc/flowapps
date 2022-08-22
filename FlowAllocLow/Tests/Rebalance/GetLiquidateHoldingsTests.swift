//
//  GetLiquidateHoldingsTests.swift
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

class GetLiquidateHoldingsTests: XCTestCase {
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
        let sm = [bnd: MSecurity(securityID: "BND", assetID: "Bond", sharePrice: 1)]
        var remainingToSell = 1.0
        let actual = LiquidateHolding.getLiquidations(sm, [], &remainingToSell)
        XCTAssertEqual([], actual)
        XCTAssertEqual(1.0, remainingToSell)
    }

    func testOneHoldingWithRemainder() throws {
        let sm = [bnd: MSecurity(securityID: "BND", assetID: "Bond", sharePrice: 1)]
        let h1 = MHolding(accountID: "1", securityID: "BND", lotID: "", shareCount: 1)
        var remainingToSell = 2.0
        let actual = LiquidateHolding.getLiquidations(sm, [h1], &remainingToSell)
        let pv = h1.getPresentValue(securityMap)!
        let expected = [LiquidateHolding(h1, presentValue: pv, fraction: 1.0)]
        XCTAssertEqual(expected, actual)
        XCTAssertEqual(1.0, remainingToSell)
    }

    func testOneHoldingComplete() throws {
        let sm = [bnd: MSecurity(securityID: "BND", assetID: "Bond", sharePrice: 1)]
        let h1 = MHolding(accountID: "1", securityID: "BND", lotID: "", shareCount: 2)
        var remainingToSell = 2.0
        let actual = LiquidateHolding.getLiquidations(sm, [h1], &remainingToSell)
        let pv = h1.getPresentValue(securityMap)!
        let expected = [LiquidateHolding(h1, presentValue: pv, fraction: 1.0)]
        XCTAssertEqual(expected, actual)
        XCTAssertEqual(0.0, remainingToSell)
    }

    func testOneHoldingWithFractionalLiquidation() throws {
        let sm = [bnd: MSecurity(securityID: "BND", assetID: "Bond", sharePrice: 1)]
        let h1 = MHolding(accountID: "1", securityID: "BND", lotID: "", shareCount: 2)
        var remainingToSell = 1.0
        let actual = LiquidateHolding.getLiquidations(sm, [h1], &remainingToSell)
        let pv = h1.getPresentValue(securityMap)!
        let expected = [LiquidateHolding(h1, presentValue: pv, fraction: 0.5)]
        XCTAssertEqual(expected, actual)
        XCTAssertEqual(0.0, remainingToSell)
    }

    func testTwoHoldingsWithRemainder() throws {
        let sm = [bnd: MSecurity(securityID: "BND", assetID: "Bond", sharePrice: 1),
                  MSecurity.Key(securityID: "AGG"): MSecurity(securityID: "AGG", assetID: "Bond", sharePrice: 1)]
        let h1 = MHolding(accountID: "1", securityID: "BND", lotID: "", shareCount: 1)
        let h2 = MHolding(accountID: "1", securityID: "AGG", lotID: "", shareCount: 2)
        let holdings = [h1, h2]
        var remainingToSell = 4.0
        let actual = LiquidateHolding.getLiquidations(sm, holdings, &remainingToSell)
        let pv1 = h1.getPresentValue(securityMap)!
        let pv2 = h2.getPresentValue(securityMap)!
        let expected = [LiquidateHolding(h1, presentValue: pv1, fraction: 1.0),
                        LiquidateHolding(h2, presentValue: pv2, fraction: 1.0)]
        XCTAssertEqual(expected, actual)
        XCTAssertEqual(1.0, remainingToSell)
    }

    func testTwoHoldingsComplete() throws {
        let sm = MSecurity.makeAllocMap([
            MSecurity(securityID: "BND", assetID: "Bond", sharePrice: 1),
            MSecurity(securityID: "AGG", assetID: "Bond", sharePrice: 1)])
        let h1 = MHolding(accountID: "1", securityID: "BND", lotID: "", shareCount: 1)
        let h2 = MHolding(accountID: "1", securityID: "AGG", lotID: "", shareCount: 2)
        let holdings = [h1, h2]
        var remainingToSell = 3.0
        let actual = LiquidateHolding.getLiquidations(sm, holdings, &remainingToSell)
        let pv1 = h1.getPresentValue(securityMap)!
        let pv2 = h2.getPresentValue(securityMap)!
        let expected = [LiquidateHolding(h1, presentValue: pv1, fraction: 1.0),
                        LiquidateHolding(h2, presentValue: pv2, fraction: 1.0)]
        XCTAssertEqual(expected, actual)
        XCTAssertEqual(0.0, remainingToSell)
    }

    func testTwoHoldingsPartial() throws {
        let sm = MSecurity.makeAllocMap([
            MSecurity(securityID: "BND", assetID: "Bond", sharePrice: 1),
            MSecurity(securityID: "AGG", assetID: "Bond", sharePrice: 1)])
        let h1 = MHolding(accountID: "1", securityID: "BND", lotID: "", shareCount: 1)
        let h2 = MHolding(accountID: "1", securityID: "AGG", lotID: "", shareCount: 2)
        let holdings = [h1, h2]
        var remainingToSell = 2.0
        let actual = LiquidateHolding.getLiquidations(sm, holdings, &remainingToSell)
        let pv1 = h1.getPresentValue(securityMap)!
        let pv2 = h2.getPresentValue(securityMap)!
        let expected = [LiquidateHolding(h1, presentValue: pv1, fraction: 1.0),
                        LiquidateHolding(h2, presentValue: pv2, fraction: 0.5)]
        XCTAssertEqual(expected, actual)
        XCTAssertEqual(0.0, remainingToSell)
    }

    func testOneHoldingSellingOrphan() throws {
        let minimumAmount = 0.10 // include remainder if <= minimumAmount
        let sm = MSecurity.makeAllocMap([
            MSecurity(securityID: "BND", assetID: "Bond", sharePrice: 1)])
        let h1 = MHolding(accountID: "1", securityID: "BND", lotID: "", shareCount: 1.10)
        var remainingToSell = 1.0
        let actual = LiquidateHolding.getLiquidations(sm, [h1], &remainingToSell, minimumAmount)
        let pv1 = h1.getPresentValue(securityMap)!
        let expected = [LiquidateHolding(h1, presentValue: pv1, fraction: 1.0)]
        XCTAssertEqual(expected, actual)
        XCTAssertEqual(0.0, remainingToSell)
    }

    func testOneHoldingNotSellingEntireHolding() throws {
        let minimumAmount = 0.10 // we'll exceed this
        let sm = MSecurity.makeAllocMap([
            MSecurity(securityID: "BND", assetID: "Bond", sharePrice: 1)])
        let h1 = MHolding(accountID: "1", securityID: "BND", lotID: "", shareCount: 1.11)
        var remainingToSell = 1.0
        let actual = LiquidateHolding.getLiquidations(sm, [h1], &remainingToSell, minimumAmount)
        XCTAssertEqual(0.0, remainingToSell)
        XCTAssertEqual(actual[0].fraction, 0.901, accuracy: 0.001)
    }

    func testTwoHoldingsLiquidateWithSmallerGainLoss() throws {
        let securityMap = MSecurity.makeAllocMap([
            MSecurity(securityID: "BND", assetID: "Bond", sharePrice: 1),
            MSecurity(securityID: "AGG", assetID: "Bond", sharePrice: 1)])
        let h1 = MHolding(accountID: "1", securityID: "BND", lotID: "", shareCount: 1, shareBasis: 1.0) // flat
        let h2 = MHolding(accountID: "1", securityID: "AGG", lotID: "", shareCount: 2, shareBasis: 1.1) // smaller gainLoss
        let holdingsUnsorted = [h1, h2]
        var remainingToSell = 2.5

        // the sort is done in getAssetHoldingsMap, not in getLiquidations
        let ahMap = MHolding.getAssetHoldingsMap(holdingsUnsorted, securityMap)
        let holdingsSorted = ahMap[bond]!

        let actual = LiquidateHolding.getLiquidations(securityMap, holdingsSorted, &remainingToSell)
        let pv1 = h1.getPresentValue(securityMap)!
        let pv2 = h2.getPresentValue(securityMap)!
        let expected = [LiquidateHolding(h2, presentValue: pv1, fraction: 1.0),
                        LiquidateHolding(h1, presentValue: pv2, fraction: 0.5)]
        XCTAssertEqual(expected, actual)
        XCTAssertEqual(0.0, remainingToSell)
    }
}
