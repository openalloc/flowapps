//
//  ModelCodableTests.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import XCTest

import AllocData

@testable import FlowBase

class ModelCodableTests: XCTestCase {
    func testBasic() throws {
        let timestamp = Date()

        let account = MAccount(accountID: "1", title: "One", isTaxable: true)
        let allocation = MAllocation(strategyID: "1", assetID: "LC", targetPct: 0.32)
        let asset = MAsset(assetID: "LC", title: "Large Cap")
        let holding = MHolding(accountID: "1", securityID: "SPY", lotID: "", shareCount: 3, shareBasis: 5) // , sharePrice: 4
        let security = MSecurity(securityID: "VOO", assetID: "LC")

        let expected = BaseModel(updatedAt: timestamp, accounts: [account], allocations: [allocation], assets: [asset], securities: [security], holdings: [holding])

        let encoded: String = try StorageManager.encodeToJSON(expected)
        let actual: BaseModel = try StorageManager.decode(fromJSON: encoded)
        XCTAssertEqual(expected, actual)
        XCTAssertEqual(timestamp, actual.updatedAt)
    }

    func testLarger() throws {
        let timestamp = Date()

        let assets = [MAsset(assetID: "LC", title: "Large Cap"),
                      MAsset(assetID: "Bond", title: "Aggregate Bonds"),
                      MAsset(assetID: "CorpBond", title: "Corporate Bonds")]

        let securities = [MSecurity(securityID: "SPY", assetID: "LC"),
                          MSecurity(securityID: "AGG", assetID: "Bond"),
                          MSecurity(securityID: "CORP", assetID: "CorpBond")]

        let accounts = [
            MAccount(accountID: "1", title: "IRA", isTaxable: false),
            MAccount(accountID: "2", title: "Taxable", isTaxable: true),
            MAccount(accountID: "3", title: "Concentrated", isTaxable: true),
        ]

        let holdings = [
            MHolding(accountID: "1", securityID: "SPY", lotID: "", shareCount: 12, shareBasis: 90), //  sharePrice: 100,
            MHolding(accountID: "1", securityID: "AGG", lotID: "", shareCount: 10, shareBasis: 80), //  sharePrice: 100,
            MHolding(accountID: "2", securityID: "CORP", lotID: "", shareCount: 13, shareBasis: 70), // , sharePrice: 100
            MHolding(accountID: "3", securityID: "AMZN", lotID: "", shareCount: 1, shareBasis: 1500), //  sharePrice: 2000
        ]

        let allocations = [
            MAllocation(strategyID: "1", assetID: "LC", targetPct: 0.6),
            MAllocation(strategyID: "1", assetID: "Bond", targetPct: 0.4),
        ]

        let expected = BaseModel(updatedAt: timestamp, accounts: accounts, allocations: allocations, assets: assets, securities: securities, holdings: holdings)

        let encoded: String = try StorageManager.encodeToJSON(expected)
        let actual: BaseModel = try StorageManager.decode(fromJSON: encoded)
        XCTAssertEqual(expected, actual)
        XCTAssertEqual(timestamp, actual.updatedAt)
    }
}
