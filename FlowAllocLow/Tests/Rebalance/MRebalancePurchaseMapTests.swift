//
//  MRebalancePurchaseMapTests.swift
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

class MRebalancePurchaseMapTests: XCTestCase {
    
    let account1 = MAccount.Key(accountID: "1")
    let account2 = MAccount.Key(accountID: "2")
    let bond = MAsset.Key(assetID: "Bond")
    let equities = MAsset.Key(assetID: "Equities")

    
    let accountMap: AccountMap = MAccount.makeAllocMap([
        MAccount(accountID: "1"),
        MAccount(accountID: "2")
    ])
    let assetMap: AssetMap = MAsset.makeAllocMap([
        MAsset(assetID: "Bond"),
        MAsset(assetID: "Equities")
    ])
    
    func testNoAccounts() throws {
        let map: AccountPurchasesMap = [:]
        let purchases = MRebalancePurchase.getPurchases(map, accountMap, assetMap)
        XCTAssertTrue(purchases.count == 0)
    }
    
    func testSingleAccountNoPurchases() throws {
        let map: AccountPurchasesMap = [MAccount.Key(accountID: "1"): []]
        let purchases = MRebalancePurchase.getPurchases(map, accountMap, assetMap)
        XCTAssertTrue(purchases.count == 0)
    }

    func testSingleAccountOnePurchase() throws {
        let purchase = Purchase(assetKey: bond, amount: 10)
        let map: AccountPurchasesMap = [account1: [purchase]]
        let actual = MRebalancePurchase.getPurchases(map, accountMap, assetMap)
        let expected = [
            MRebalancePurchase(accountID: "1", assetID: "Bond", amount: 10)
        ]
        XCTAssertEqual(expected, actual)
    }

    func testSingleAccountTwoPurchases() throws {
        let purchase1 = Purchase(assetKey: bond, amount: 10)
        let purchase2 = Purchase(assetKey: equities, amount: 13)
        let map: AccountPurchasesMap = [account1: [purchase1, purchase2]]
        let actual = MRebalancePurchase.getPurchases(map, accountMap, assetMap)
        let expected = [
            MRebalancePurchase(accountID: "1", assetID: "Bond", amount: 10),
            MRebalancePurchase(accountID: "1", assetID: "Equities", amount: 13)
        ]
        XCTAssertEqual(expected, actual)
    }
    
    func testDualAccountTwoPurchases() throws {
        let purchase1 = Purchase(assetKey: bond, amount: 10)
        let purchase2 = Purchase(assetKey: equities, amount: 13)
        let purchase3 = Purchase(assetKey: bond, amount: 20)
        let purchase4 = Purchase(assetKey: equities, amount: 23)
        let map: AccountPurchasesMap = [account1: [purchase1, purchase2], account2: [purchase3, purchase4]]
        let actual = MRebalancePurchase.getPurchases(map, accountMap, assetMap)
        let expected = [
            MRebalancePurchase(accountID: "1", assetID: "Bond", amount: 10),
            MRebalancePurchase(accountID: "1", assetID: "Equities", amount: 13),
            MRebalancePurchase(accountID: "2", assetID: "Bond", amount: 20),
            MRebalancePurchase(accountID: "2", assetID: "Equities", amount: 23)
        ]
        XCTAssertEqual(Set(expected), Set(actual))
    }
}
