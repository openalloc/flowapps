//
//  ModelTests.swift
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

final class ModelTests: XCTestCase {
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
        MAllocation(strategyID: "2", assetID: "LC", targetPct: 0.7),
        MAllocation(strategyID: "2", assetID: "Bond", targetPct: 0.3),
    ]

    let strategies = [
        MStrategy(strategyID: "1", title: "60/40"),
        MStrategy(strategyID: "2", title: "70/30"),
    ]

    func testEquatableIgnoresUpdatedAt() throws {
        let timestamp1 = Date()
        let timestamp2 = timestamp1 + 10
        let id = UUID()

        let model1 = BaseModel(id: id, updatedAt: timestamp1, accounts: accounts, allocations: allocations, strategies: strategies, assets: assets, securities: securities, holdings: holdings)
        var model2 = BaseModel(id: id, updatedAt: timestamp2, accounts: accounts, allocations: allocations, strategies: strategies, assets: assets, securities: securities, holdings: holdings)
        XCTAssertEqual(model1, model2)
        model2.updatedAt = timestamp2
        XCTAssertEqual(model1, model2)
    }

    func testEquatableOnAccounts() throws {
        let timestamp1 = Date()
        let model1 = BaseModel(updatedAt: timestamp1, accounts: accounts, allocations: allocations, strategies: strategies, assets: assets, securities: securities, holdings: holdings)
        let model2 = BaseModel(updatedAt: timestamp1, accounts: [], allocations: allocations, strategies: strategies, assets: assets, securities: securities, holdings: holdings)
        XCTAssertNotEqual(model1, model2)
    }

    func testEquatableOnAllocations() throws {
        let timestamp1 = Date()
        let model1 = BaseModel(updatedAt: timestamp1, accounts: accounts, allocations: allocations, strategies: strategies, assets: assets, securities: securities, holdings: holdings)
        let model2 = BaseModel(updatedAt: timestamp1, accounts: accounts, allocations: [], strategies: strategies, assets: assets, securities: securities, holdings: holdings)
        XCTAssertNotEqual(model1, model2)
    }

    func testEquatableOnStrategies() throws {
        let timestamp1 = Date()
        let model1 = BaseModel(updatedAt: timestamp1, accounts: accounts, allocations: allocations, strategies: strategies, assets: assets, securities: securities, holdings: holdings)
        let model2 = BaseModel(updatedAt: timestamp1, accounts: accounts, allocations: allocations, strategies: [], assets: assets, securities: securities, holdings: holdings)
        XCTAssertNotEqual(model1, model2)
    }

    func testEquatableOnAssets() throws {
        let timestamp1 = Date()
        let model1 = BaseModel(updatedAt: timestamp1, accounts: accounts, allocations: allocations, strategies: strategies, assets: assets, securities: securities, holdings: holdings)
        let model2 = BaseModel(updatedAt: timestamp1, accounts: accounts, allocations: allocations, strategies: strategies, assets: [], securities: securities, holdings: holdings)
        XCTAssertNotEqual(model1, model2)
    }

    func testEquatableOnSecurities() throws {
        let timestamp1 = Date()
        let model1 = BaseModel(updatedAt: timestamp1, accounts: accounts, allocations: allocations, strategies: strategies, assets: assets, securities: securities, holdings: holdings)
        let model2 = BaseModel(updatedAt: timestamp1, accounts: accounts, allocations: allocations, strategies: strategies, assets: assets, securities: [], holdings: holdings)
        XCTAssertNotEqual(model1, model2)
    }

    func testEquatableOnHoldings() throws {
        let timestamp1 = Date()
        let model1 = BaseModel(updatedAt: timestamp1, accounts: accounts, allocations: allocations, strategies: strategies, assets: assets, securities: securities, holdings: holdings)
        let model2 = BaseModel(updatedAt: timestamp1, accounts: accounts, allocations: allocations, strategies: strategies, assets: assets, securities: securities, holdings: [])
        XCTAssertNotEqual(model1, model2)
    }

    func testSecurityMap() throws {
        let model = BaseModel(assets: assets, securities: securities)

        let securityKeys = securities.map(\.primaryKey)
        let expected: SecurityMap = Dictionary(uniqueKeysWithValues: zip(securityKeys, securities))
        let actual = model.makeSecurityMap()
        XCTAssertEqual(expected, actual)
    }

    func testGetAccountHoldingsMap() throws {
        let model = BaseModel(updatedAt: Date(), accounts: accounts, holdings: holdings)

        let expected = [
            MAccount.Key(accountID: "1"): [
                MHolding(accountID: "1", securityID: "SPY", lotID: "", shareCount: 12, shareBasis: 90), //  sharePrice: 100,
                MHolding(accountID: "1", securityID: "AGG", lotID: "", shareCount: 10, shareBasis: 80), //  sharePrice: 100,
            ],
            MAccount.Key(accountID: "2"): [
                MHolding(accountID: "2", securityID: "CORP", lotID: "", shareCount: 13, shareBasis: 70), //  sharePrice: 100,
            ],
            MAccount.Key(accountID: "3"): [
                MHolding(accountID: "3", securityID: "AMZN", lotID: "", shareCount: 1, shareBasis: 1500), //  sharePrice: 2000
            ],
        ]

        let actual = model.makeAccountHoldingsMap()
        XCTAssertEqual(expected, actual)
    }

    func testAccountMap() throws {
        let model = BaseModel(accounts: accounts)

        let accountKeys = model.accounts.map(\.primaryKey)
        let expected: AccountMap = Dictionary(uniqueKeysWithValues: zip(accountKeys, model.accounts))
        let actual = model.makeAccountMap()
        XCTAssertEqual(expected, actual)
    }
}
