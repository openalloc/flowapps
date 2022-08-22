//
//  BasePurchaseTests.swift
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

class GetPurchasesTests: XCTestCase {
    let cashAssetKey = MAsset.Key(assetID: "Cash")
    let cashAssetKeySet = Set([MAsset.Key(assetID: "Cash")])

    let bond = MAsset.Key(assetID: "Bond")
    let equities = MAsset.Key(assetID: "Equities")
    let gold = MAsset.Key(assetID: "Gold")
    let re = MAsset.Key(assetID: "RE")
    
    func testNoPurchase() throws {
        let map: RebalanceMap = [:]
        let purchases = Purchase.getPurchases(rebalanceMap: map)
        XCTAssertEqual(purchases.count, 0)
    }

    func testOnePurchase() throws {
        let map: RebalanceMap = [bond: 10]
        let purchases = Purchase.getPurchases(rebalanceMap: map)
        XCTAssertEqual(purchases.count, 1)
        let expected = Purchase(assetKey: bond, amount: 10)
        XCTAssertEqual(expected, purchases[0])
    }

    func testOnePurchaseIgnoreSale() throws {
        let map: RebalanceMap = [bond: 10, equities: -10]
        let purchases = Purchase.getPurchases(rebalanceMap: map)
        XCTAssertEqual(purchases.count, 1)
        let expected = Purchase(assetKey: bond, amount: 10)
        XCTAssertEqual(expected, purchases[0])
    }

    func testOnePurchasePenny() throws {
        let map: RebalanceMap = [bond: 0.01]
        let purchases = Purchase.getPurchases(rebalanceMap: map)
        XCTAssertEqual(purchases.count, 1)
        let expected = Purchase(assetKey: bond, amount: 0.01)
        XCTAssertEqual(expected, purchases[0])
    }

    func testOnePurchaseIgnoreLessThanPenny() throws {
        let map: RebalanceMap = [bond: 0.00999]
        let purchases = Purchase.getPurchases(rebalanceMap: map)
        XCTAssertEqual(purchases.count, 0)
    }

    func testIgnoreCash() throws {
        let map: RebalanceMap = [cashAssetKey: 10]
        let purchases = Purchase.getPurchases(rebalanceMap: map)
        XCTAssertEqual(purchases.count, 0)
    }

    func testSortedByAmountDesc() throws {
        let map: RebalanceMap = [equities: 5, bond: 10, gold: 7, re: 6]
        let purchases = Purchase.getPurchases(rebalanceMap: map)
        XCTAssertEqual(purchases.count, 4)
        let expected = [
            Purchase(assetKey: bond, amount: 10),
            Purchase(assetKey: gold, amount: 7),
            Purchase(assetKey: re, amount: 6),
            Purchase(assetKey: equities, amount: 5),
        ]
        XCTAssertEqual(expected, purchases)
    }
}
