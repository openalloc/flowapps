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

class GetSalesTests: XCTestCase {
    let cashAssetKey = MAsset.Key(assetID: "Cash")
    let cashAssetKeySet = Set([MAsset.Key(assetID: "Cash")])

    let account1 = MAccount.Key(accountID: "1")
    let account2 = MAccount.Key(accountID: "2")
    let bond = MAsset.Key(assetID: "Bond")
    let equities = MAsset.Key(assetID: "Equities")
    let bnd = MSecurity.Key(securityID: "BND")

    var securityMap: SecurityMap!

    override func setUp() {
        securityMap = MSecurity.makeAllocMap([MSecurity(securityID: "BND", sharePrice: 1),
                                              MSecurity(securityID: "AGG", sharePrice: 1)])
    }

    func testNoSale() throws {
        let rMap: RebalanceMap = [:]
        let sMap: SecurityMap = [bnd: MSecurity(securityID: "BND", assetID: "Bond")]
        let ahMap: AssetHoldingsMap = [bond: [MHolding(accountID: "1", securityID: "BND", lotID: "", shareCount: 1)]]
        let sales = Sale.getSales(rMap, ahMap, sMap)
        XCTAssertEqual(sales.count, 0)
    }

    func testOneSale() throws {
        for amount in [10, 0.01] {
            let h = MHolding(accountID: "1", securityID: "BND", lotID: "", shareCount: 1)
            let rm: RebalanceMap = [MAsset.Key(assetID: "Bond"): -amount]
            let sm = [bnd: MSecurity(securityID: "BND", assetID: "Bond", sharePrice: amount)]
            let ah = [MAsset.Key(assetID: "Bond"): [h]]
            let sales = Sale.getSales(rm, ah, sm)
            XCTAssertEqual(sales.count, 1)
            let pv = h.getPresentValue(securityMap)!
            let lh = LiquidateHolding(h, presentValue: pv)
            let expected = Sale(assetKey: bond, targetAmount: amount, liquidateHoldings: [lh])
            XCTAssertEqual(expected, sales[0])
        }
    }

    func testOneSaleIgnorePurchase() throws {
        let h1 = MHolding(accountID: "1", securityID: "BND", lotID: "", shareCount: 1)
        let h2 = MHolding(accountID: "1", securityID: "VOO", lotID: "", shareCount: 1)
        let rm: RebalanceMap = [bond: -10, equities: 10]
        let sm = MSecurity.makeAllocMap([
            MSecurity(securityID: "BND", assetID: "Bond", sharePrice: 1),
            MSecurity(securityID: "VOO", assetID: "equities", sharePrice: 1)])
        let ah = [bond: [h1], equities: [h2]]
        let sales = Sale.getSales(rm, ah, sm)
        XCTAssertEqual(sales.count, 1)
        let pv = h1.getPresentValue(securityMap)!
        let lh = LiquidateHolding(h1, presentValue: pv)
        let expected = Sale(assetKey: MAsset.Key(assetID: "Bond"), targetAmount: 10, liquidateHoldings: [lh])
        XCTAssertEqual(expected, sales[0])
    }

    func testOneSaleIgnoreLessThanPenny() throws {
        let amount = 0.00999
        let h = MHolding(accountID: "1", securityID: "BND", lotID: "", shareCount: 1)
        let rm: RebalanceMap = [MAsset.Key(assetID: "Bond"): -amount]
        let sm = [bnd: MSecurity(securityID: "BND", assetID: "Bond", sharePrice: amount)]
        let ah = [MAsset.Key(assetID: "Bond"): [h]]
        let sales = Sale.getSales(rm, ah, sm)
        XCTAssertEqual(sales.count, 0)
    }

    func testOneSaleIgnoreCash() throws {
        let amount = 1.00
        let h = MHolding(accountID: "1", securityID: "SPAXX", lotID: "", shareCount: 1)
        let rm: RebalanceMap = [cashAssetKey: -amount]
        let sm = MSecurity.makeAllocMap([
            MSecurity(securityID: "SPAXX", assetID: "Cash", sharePrice: amount)])
        let ah = [cashAssetKey: [h]]
        let sales = Sale.getSales(rm, ah, sm)
        XCTAssertEqual(sales.count, 0)
    }

    func testOneSaleIgnoreIfBelowMinimum() throws {
        let minimumAmount = 1.01
        let amount = 1.00
        let h = MHolding(accountID: "1", securityID: "BND", lotID: "", shareCount: 1)
        let rm: RebalanceMap = [MAsset.Key(assetID: "Bond"): -amount]
        let sm = [bnd: MSecurity(securityID: "BND", assetID: "Bond", sharePrice: 1)]
        let ah = [MAsset.Key(assetID: "Bond"): [h]]
        let sales = Sale.getSales(rm, ah, sm, minimumSaleAmount: minimumAmount)
        XCTAssertEqual(sales.count, 0)
    }

    func testOneSaleAtMinimum() throws {
        let minimumAmount = 1.00
        let amount = 1.00
        let h = MHolding(accountID: "1", securityID: "BND", lotID: "", shareCount: 1)
        let rm: RebalanceMap = [MAsset.Key(assetID: "Bond"): -amount]
        let sm = [bnd: MSecurity(securityID: "BND", assetID: "Bond", sharePrice: 1)]
        let ah = [MAsset.Key(assetID: "Bond"): [h]]
        let sales = Sale.getSales(rm, ah, sm, minimumSaleAmount: minimumAmount)
        XCTAssertEqual(sales.count, 1)
        let pv = h.getPresentValue(securityMap)!
        let lh = LiquidateHolding(h, presentValue: pv)
        let expected = Sale(assetKey: MAsset.Key(assetID: "Bond"), targetAmount: amount, liquidateHoldings: [lh])
        XCTAssertEqual(expected, sales[0])
    }

    func testNoSaleIfNoHoldings() throws {
        let amount = 1.00
        let rm: RebalanceMap = [MAsset.Key(assetID: "Bond"): -amount]
        let sm = [bnd: MSecurity(securityID: "BND", assetID: "Bond", sharePrice: 1)]
        let ah: AssetHoldingsMap = [MAsset.Key(assetID: "Bond"): []]
        let sales = Sale.getSales(rm, ah, sm)
        XCTAssertEqual(sales.count, 0)
    }

    func testWholeSaleIfPartialHoldings() throws {
        let h = MHolding(accountID: "1", securityID: "BND", lotID: "", shareCount: 0.25)
        let rm: RebalanceMap = [MAsset.Key(assetID: "Bond"): -1.00]
        let sm = [bnd: MSecurity(securityID: "BND", assetID: "Bond", sharePrice: 1)]
        let ah: AssetHoldingsMap = [MAsset.Key(assetID: "Bond"): [h]]
        let sales = Sale.getSales(rm, ah, sm)
        XCTAssertEqual(sales.count, 1)
        let pv = h.getPresentValue(securityMap)!
        let lh = LiquidateHolding(h, presentValue: pv)
        let expected = Sale(assetKey: MAsset.Key(assetID: "Bond"), targetAmount: 1.00, liquidateHoldings: [lh])
        XCTAssertEqual(expected, sales[0])
    }

    func testFractionalSaleIfPartialHoldings() throws {
        let h = MHolding(accountID: "1", securityID: "BND", lotID: "", shareCount: 2.00)
        let rm: RebalanceMap = [MAsset.Key(assetID: "Bond"): -1.00]
        let sm = [bnd: MSecurity(securityID: "BND", assetID: "Bond", sharePrice: 1)]
        let ah: AssetHoldingsMap = [MAsset.Key(assetID: "Bond"): [h]]
        let sales = Sale.getSales(rm, ah, sm)
        XCTAssertEqual(sales.count, 1)
        let pv = h.getPresentValue(securityMap)!
        let lh = LiquidateHolding(h, presentValue: pv, fraction: 0.5) // only selling half of position
        let expected = Sale(assetKey: MAsset.Key(assetID: "Bond"), targetAmount: 1.00, liquidateHoldings: [lh])
        XCTAssertEqual(expected, sales[0])
    }
}
