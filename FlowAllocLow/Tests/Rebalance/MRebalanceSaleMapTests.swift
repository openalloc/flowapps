//
//  MRebalanceSaleMapTests.swift
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

class MRebalanceSaleMapTests: XCTestCase {
    
    let account1 = MAccount.Key(accountID: "1")
    let account2 = MAccount.Key(accountID: "2")
    let bond = MAsset.Key(assetID: "Bond")
    let equities = MAsset.Key(assetID: "Equities")

    func testNoAccounts() throws {
        let map: AccountSalesMap = [:]
        let purchases = MRebalanceSale.getSales(map)
        XCTAssertTrue(purchases.count == 0)
    }
    
    func testSingleAccountNoSales() throws {
        let map: AccountSalesMap = [account1: []]
        let purchases = MRebalanceSale.getSales(map)
        XCTAssertTrue(purchases.count == 0)
    }

    func testSingleAccountOneSaleNoLH() throws {
        let sale = Sale(assetKey: bond, targetAmount: 10)
        let map: AccountSalesMap = [account1: [sale]]
        let actual = MRebalanceSale.getSales(map)
        let expected: [MRebalanceSale] = []
        XCTAssertEqual(expected, actual)
    }

    func testSingleAccountOneSaleWithOneLH() throws {
        let holding = MHolding(accountID: "1", securityID: "BND", lotID: "", shareCount: 1)
        let lh = LiquidateHolding(holding, presentValue: 20, fraction: 1.0)
        let sale = Sale(assetKey: bond, targetAmount: 0, liquidateHoldings: [lh])
        let map: AccountSalesMap = [account1: [sale]]
        let actual = MRebalanceSale.getSales(map)
        let expected: [MRebalanceSale] = [
            MRebalanceSale(accountID: "1", securityID: "BND", lotID: "", amount: 20.00, shareCount: 1, liquidateAll: true)
        ]
        XCTAssertEqual(expected, actual)
    }

    func testSingleAccountOneSaleWithOneLHPartial() throws {
        let fraction = 0.2
        let holding = MHolding(accountID: "1", securityID: "BND", lotID: "", shareCount: 3)
        let lh = LiquidateHolding(holding, presentValue: 20, fraction: fraction) // partial!
        let sale = Sale(assetKey: bond, targetAmount: 0, liquidateHoldings: [lh])
        let map: AccountSalesMap = [account1: [sale]]
        let actual = MRebalanceSale.getSales(map)
        let expected: [MRebalanceSale] = [
            MRebalanceSale(accountID: "1", securityID: "BND", lotID: "", amount: 20 * fraction, shareCount: 3.0 * fraction, liquidateAll: false)
        ]
        XCTAssertEqual(expected, actual)
    }

    func testSingleAccountOneSaleWithTwoLHs() throws {
        let holding1 = MHolding(accountID: "1", securityID: "BND", lotID: "", shareCount: 1)
        let holding2 = MHolding(accountID: "1", securityID: "AGG", lotID: "", shareCount: 2)
        let lh1 = LiquidateHolding(holding1, presentValue: 10, fraction: 1.0)
        let lh2 = LiquidateHolding(holding2, presentValue: 20, fraction: 1.0)
        let sale = Sale(assetKey: bond, targetAmount: 0, liquidateHoldings: [lh1, lh2])
        let map: AccountSalesMap = [account1: [sale]]
        let actual = MRebalanceSale.getSales(map)
        let expected: [MRebalanceSale] = [
            MRebalanceSale(accountID: "1", securityID: "BND", lotID: "", amount: 10.00, shareCount: 1, liquidateAll: true),
            MRebalanceSale(accountID: "1", securityID: "AGG", lotID: "", amount: 20.00, shareCount: 2, liquidateAll: true)
        ]
        XCTAssertEqual(expected, actual)
    }
    
    func testSingleAccountTwoSaleWithOneLH() throws {
        let holding1 = MHolding(accountID: "1", securityID: "BND", lotID: "", shareCount: 1)
        let holding2 = MHolding(accountID: "1", securityID: "SPY", lotID: "", shareCount: 2)
        let lh1 = LiquidateHolding(holding1, presentValue: 10, fraction: 1.0)
        let lh2 = LiquidateHolding(holding2, presentValue: 20, fraction: 1.0)
        let sale1 = Sale(assetKey: bond, targetAmount: 0, liquidateHoldings: [lh1])
        let sale2 = Sale(assetKey: equities, targetAmount: 0, liquidateHoldings: [lh2])
        let map: AccountSalesMap = [account1: [sale1, sale2]]
        let actual = MRebalanceSale.getSales(map)
        let expected: [MRebalanceSale] = [
            MRebalanceSale(accountID: "1", securityID: "BND", lotID: "", amount: 10.00, shareCount: 1, liquidateAll: true),
            MRebalanceSale(accountID: "1", securityID: "SPY", lotID: "", amount: 20.00, shareCount: 2, liquidateAll: true)
        ]
        XCTAssertEqual(expected, actual)
    }


    func testDualAccountDualSaleWithTwoLHs() throws {
        let holding1 = MHolding(accountID: "1", securityID: "BND", lotID: "", shareCount: 1)
        let holding2 = MHolding(accountID: "1", securityID: "AGG", lotID: "", shareCount: 2)
        let holding3 = MHolding(accountID: "2", securityID: "BND", lotID: "", shareCount: 5)
        let holding4 = MHolding(accountID: "2", securityID: "AGG", lotID: "", shareCount: 7)
        let lh1 = LiquidateHolding(holding1, presentValue: 10, fraction: 1.0)
        let lh2 = LiquidateHolding(holding2, presentValue: 20, fraction: 1.0)
        let lh3 = LiquidateHolding(holding3, presentValue: 50, fraction: 1.0)
        let lh4 = LiquidateHolding(holding4, presentValue: 70, fraction: 1.0)
        let sale1 = Sale(assetKey: bond, targetAmount: 0, liquidateHoldings: [lh1, lh2])
        let sale2 = Sale(assetKey: bond, targetAmount: 0, liquidateHoldings: [lh3, lh4])
        let map: AccountSalesMap = [account1: [sale1], account2: [sale2]]
        let actual = MRebalanceSale.getSales(map)
        let expected: [MRebalanceSale] = [
            MRebalanceSale(accountID: "1", securityID: "BND", lotID: "", amount: 10.00, shareCount: 1, liquidateAll: true),
            MRebalanceSale(accountID: "1", securityID: "AGG", lotID: "", amount: 20.00, shareCount: 2, liquidateAll: true),
            MRebalanceSale(accountID: "2", securityID: "BND", lotID: "", amount: 50.00, shareCount: 5, liquidateAll: true),
            MRebalanceSale(accountID: "2", securityID: "AGG", lotID: "", amount: 70.00, shareCount: 7, liquidateAll: true),
        ]
        XCTAssertEqual(Set(expected), Set(actual))
    }

}
