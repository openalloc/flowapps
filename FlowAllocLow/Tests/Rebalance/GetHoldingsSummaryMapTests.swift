//
//  GetHoldingsSummaryMapTests.swift
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
import FlowXCT

@testable import FlowAllocLow

class GetHoldingsSummaryMapTests: XCTestCase {
    let asset1 = MAsset(assetID: "LC", title: "Large Cap")
    let asset2 = MAsset(assetID: "Bond", title: "Bond", colorCode: 1)
    let asset3 = MAsset(assetID: "CorpBond", title: "Corporate Bond", colorCode: 2)
    var assets: [MAsset]!

    let security1 = MSecurity(securityID: "SPY", assetID: "LC", sharePrice: 100)
    let security2 = MSecurity(securityID: "AGG", assetID: "Bond", sharePrice: 100)
    let security3 = MSecurity(securityID: "CORP", assetID: "CorpBond", sharePrice: 100)
    // deliberately no AMZN security
    var securities: [MSecurity]!

    let account1 = MAccount(accountID: "1", title: "IRA", isTaxable: false)
    let account2 = MAccount(accountID: "2", title: "Taxable", isTaxable: true)
    let account3 = MAccount(accountID: "3", title: "Concentrated", isTaxable: true)
    var accounts: [MAccount]!

    let holding1a = MHolding(accountID: "1", securityID: "SPY", lotID: "", shareCount: 12, shareBasis: 110)
    let holding1b = MHolding(accountID: "1", securityID: "AGG", lotID: "", shareCount: 10, shareBasis: 80)
    let holding1c = MHolding(accountID: "1", securityID: "SPY", lotID: "1", shareCount: 5, shareBasis: 70)
    let holding2 = MHolding(accountID: "2", securityID: "CORP", lotID: "", shareCount: 13, shareBasis: 70)
    let holding3a = MHolding(accountID: "3", securityID: "AMZN", lotID: "", shareCount: 1, shareBasis: 1500) // sharePrice: 2000
    let holding3b = MHolding(accountID: "3", securityID: "AGG", lotID: "66", shareCount: 8, shareBasis: 70)

    let bond = MAsset.Key(assetID: "Bond")
    let lc = MAsset.Key(assetID: "LC")
    let corpbond = MAsset.Key(assetID: "CorpBond")
    
    let agg = MSecurity.Key(securityID: "AGG")
    let spy = MSecurity.Key(securityID: "SPY")
    let corp = MSecurity.Key(securityID: "CORP")
    
    var holdings: [MHolding]!
    var model: BaseModel!
    var accountHoldingsMap: AccountHoldingsMap!

    override func setUp() {
        assets = [asset1, asset2, asset3]
        securities = [security1, security2, security3]
        accounts = [account1, account2, account3]
        holdings = [holding1a, holding1b, holding1c, holding2, holding3a, holding3b]
        model = BaseModel(accounts: accounts, assets: assets, securities: securities, holdings: holdings)
    }

    func testHoldingsSummary() throws {
        let expected: AssetHoldingsSummaryMap = [lc: HoldingsSummary(presentValue: (12 + 5) * 100, costBasis: 12 * 110 + 5 * 70, count: 2, tickerShareMap: [spy: 17]),
                                                 bond: HoldingsSummary(presentValue: 10 * 100, costBasis: 10 * 80, count: 1, tickerShareMap: [agg: 10])]
        let actual = HoldingsSummary.getAssetSummaryMap(account1.primaryKey, model.makeAccountHoldingsMap(), model.makeSecurityMap())
        XCTAssertEqual(expected, actual)
    }

    func testAccountHoldingsSummaryMap() throws {
        let accountKey1 = account1.primaryKey
        let accountKey2 = account2.primaryKey
        let accountKey3 = account3.primaryKey
        

        let expected: AccountAssetHoldingsSummaryMap = [accountKey1: [lc: HoldingsSummary(presentValue: (12 + 5) * 100, costBasis: 12 * 110 + 5 * 70, count: 2, tickerShareMap: [spy: 17]),
                                                              bond: HoldingsSummary(presentValue: 10 * 100, costBasis: 10 * 80, count: 1, tickerShareMap: [agg: 10])],
                                                        accountKey2: [corpbond: HoldingsSummary(presentValue: 1300, costBasis: 910, count: 1, tickerShareMap: [corp: 13])],
                                                        accountKey3: [bond: HoldingsSummary(presentValue: 8 * 100, costBasis: 8 * 70, count: 1, tickerShareMap: [agg: 8])]]
        let actual = HoldingsSummary.getAccountAssetSummaryMap(accounts.map(\.primaryKey), model.makeAccountHoldingsMap(), model.makeSecurityMap())
        XCTAssertEqual(expected, actual)
    }
}
