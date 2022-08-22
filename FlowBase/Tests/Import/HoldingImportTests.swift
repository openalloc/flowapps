//
//  HoldingImportTests.swift
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

class HoldingImportTests: XCTestCase {
    func testPositiveSharecount() throws {
        let security = MSecurity(securityID: "a", assetID: "aaa")
        let account = MAccount(accountID: "1", title: "One")
        var model = BaseModel(accounts: [account], securities: [security])
        let holding = MHolding(accountID: "1", securityID: security.securityID, lotID: "", shareCount: 1, shareBasis: 1)
        _ = try model.importRecord(holding, into: \.holdings)
        let accountHoldings = model.makeAccountHoldingsMap()[account.primaryKey] ?? []
        XCTAssertEqual([MHolding(accountID: "1", securityID: security.securityID, lotID: "", shareCount: 1, shareBasis: 1)], accountHoldings)
    }
    
    func testNegativeSharecount() throws {
        let security = MSecurity(securityID: "a", assetID: "aaa")
        let account = MAccount(accountID: "1", title: "One")
        var model = BaseModel(accounts: [account], securities: [security])
        let holding = MHolding(accountID: "1", securityID: security.securityID, lotID: "", shareCount: -1, shareBasis: 1)
        _ = try model.importRecord(holding, into: \.holdings)
        let accountHoldings = model.makeAccountHoldingsMap()[account.primaryKey] ?? []
        XCTAssertEqual([MHolding(accountID: "1", securityID: security.securityID, lotID: "", shareCount: -1, shareBasis: 1)], accountHoldings)
    }

    func testDoesReplaceExisting() throws {
        // assumes that all lots are rolled-up under a single securityID in an account's holding
        let security = MSecurity(securityID: "A", assetID: "AAA")
        let account = MAccount(accountID: "1", title: "One")
        var model = BaseModel(accounts: [account], securities: [security])
        let holding1 = MHolding(accountID: "1", securityID: security.securityID, lotID: "", shareCount: 0.1, shareBasis: 1)
        let holding2 = MHolding(accountID: "1", securityID: security.securityID, lotID: "", shareCount: 0.2, shareBasis: 1)
        _ = try model.importRecord(holding1, into: \.holdings)
        let accountHoldings1 = model.makeAccountHoldingsMap()[account.primaryKey] ?? []
        XCTAssertEqual([holding1], accountHoldings1)
        _ = try model.importRecord(holding2, into: \.holdings)
        let accountHoldings2 = model.makeAccountHoldingsMap()[account.primaryKey] ?? []
        XCTAssertEqual([holding1, holding2], accountHoldings2)
    }

    func testForeignKeyToSecuritiesCreated() throws {
        let account = MAccount(accountID: "1", title: "One")
        var model = BaseModel(accounts: [account])
        XCTAssertEqual(0, model.securities.count)
        let row: AllocRowed.DecodedRow = ["holdingAccountID": "1", "holdingSecurityID": "SPY", "holdingLotID": "", "shareCount": 1.0, "shareBasis": 1.0]
        _ = try model.importRow(row, into: \.holdings)
        XCTAssertEqual(1, model.securities.count)
        XCTAssertEqual(MSecurity(securityID: "SPY", assetID: nil, sharePrice: nil, updatedAt: nil), model.securities.first!)
    }

    func testForeignKeyToAccountCreates() throws {
        let security = MSecurity(securityID: "SPY", assetID: "equities")
        // let account1 = MAccount(accountID: "1", title: "One")
        var model = BaseModel(accounts: [])
        XCTAssertEqual(0, model.accounts.count)
        let row: AllocRowed.DecodedRow = ["holdingAccountID": "1", "holdingSecurityID": security.securityID, "holdingLotID": "", "shareCount": 1.0, "shareBasis": 1.0]
        _ = try model.importRow(row, into: \.holdings)
        XCTAssertEqual(1, model.accounts.count)
        XCTAssertEqual(MAccount(accountID: "1", title: nil, isTaxable: false), model.accounts.first!)
    }
}
