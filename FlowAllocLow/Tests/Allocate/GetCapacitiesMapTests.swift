//
//  GetCapacitiesMapTests.swift
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

class GetCapacitiesMapTests: XCTestCase {
    var model: BaseModel!
    var accountPresentValueMap: AccountPresentValueMap!

    override func setUp() {
        let equities = MAsset(assetID: "LC", title: "Equities")
        let bonds = MAsset(assetID: "Bond", title: "Bonds")
        let account1 = MAccount(accountID: "1", title: "My First")
        let holding1a = MHolding(accountID: "1", securityID: "SPY", lotID: "", shareCount: 8, shareBasis: 1)
        let holding1b = MHolding(accountID: "1", securityID: "AGG", lotID: "", shareCount: 2, shareBasis: 1)
        let account2 = MAccount(accountID: "2", title: "My Second")
        let holding2a = MHolding(accountID: "2", securityID: "SPY", lotID: "", shareCount: 2, shareBasis: 1)
        let holding2b = MHolding(accountID: "2", securityID: "AGG", lotID: "", shareCount: 8, shareBasis: 1)
        let security1 = MSecurity(securityID: "BND", sharePrice: 1)
        let security2 = MSecurity(securityID: "AGG", sharePrice: 1)
        let security3 = MSecurity(securityID: "SPY", sharePrice: 2)
        let security4 = MSecurity(securityID: "VOO", sharePrice: 1)
        let accounts = [account1, account2]
        model = BaseModel(accounts: accounts,
                          assets: [equities, bonds],
                          securities: [security1, security2, security3, security4],
                          holdings: [holding1a, holding1b, holding2a, holding2b])
    }

    func refreshMaps() {
        accountPresentValueMap = MAccount.getAccountPresentValueMap(model.accounts.map(\.primaryKey),
                                                                    model.makeAccountHoldingsMap(),
                                                                    model.makeSecurityMap())
    }

    func testNoValue() throws {
        let account0 = MAccount(accountID: "1", title: "My First")
        let model0 = BaseModel(accounts: [account0])
        let map0 = MAccount.getAccountPresentValueMap(model0.accounts.map(\.primaryKey),
                                                      model0.makeAccountHoldingsMap(),
                                                      model0.makeSecurityMap())
        let expected = AccountCapacitiesMap()
        let actual = getCapacitiesMap(model0.accounts.map(\.primaryKey), map0)
        XCTAssertEqual(expected, actual)
    }

    func testTwoAccountsWithFourHoldings() throws {
        refreshMaps()
        let account1 = MAccount.Key(accountID: "1")
        let account2 = MAccount.Key(accountID: "2")
        let actual = getCapacitiesMap(model.accounts.map(\.primaryKey), accountPresentValueMap)
        let expected = [account1: 0.6, account2: 0.4]
        XCTAssertEqual(expected, actual)
    }
}
