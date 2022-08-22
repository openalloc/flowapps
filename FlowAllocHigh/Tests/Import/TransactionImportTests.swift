//
//  TransactionImportTests.swift
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

import FlowAllocLow
import FlowBase
import AllocData

@testable import FlowAllocHigh

class TransactionImportTests: XCTestCase {
    var df: ISO8601DateFormatter!
    var timestamp1: Date!
    var timestamp2: Date!
    var timestamp3: Date!

    override func setUpWithError() throws {
        df = ISO8601DateFormatter()
        timestamp1 = df.date(from: "2020-10-01T00:00:00Z")!
        timestamp2 = df.date(from: "2020-11-01T00:00:00Z")!
        timestamp3 = df.date(from: "2020-12-01T00:00:00Z")!
    }
    
    func testValidHistorySucceeds() throws {
        let accountA = MAccount(accountID: "1", title: "A")
        let asset = MAsset(assetID: "a", title: "a")
        var model = BaseModel(accounts: [accountA], assets: [asset])
        let item = MTransaction(action: .buysell, transactedAt: timestamp1, accountID: "1", securityID: "VOO", shareCount: 1, sharePrice: 2)
        let expected = MTransaction(action: .buysell, transactedAt: timestamp1, accountID: "1", securityID: "VOO", shareCount: 1, sharePrice: 2)
        _ = try model.importRecord(item, into: \.transactions)
        XCTAssertEqual([expected], model.transactions)
    }

    func testNoReplaceExisting() throws {
        let accountA = MAccount(accountID: "1", title: "A")
        let asset = MAsset(assetID: "A", title: "A")
        var model = BaseModel(accounts: [accountA], assets: [asset])
        let item1 = MTransaction(action: .buysell, transactedAt: timestamp1, accountID: "1", securityID: "VOO", shareCount: 1, sharePrice: 2)
        let item2 = MTransaction(action: .buysell, transactedAt: timestamp2, accountID: "1", securityID: "VOO", shareCount: 3, sharePrice: 4)
        let expected1 = MTransaction(action: .buysell, transactedAt: timestamp1, accountID: "1", securityID: "VOO", shareCount: 1, sharePrice: 2)
        let expected2 = MTransaction(action: .buysell, transactedAt: timestamp2, accountID: "1", securityID: "VOO", shareCount: 3, sharePrice: 4)
        _ = try model.importRecord(item1, into: \.transactions)
        XCTAssertEqual([expected1], model.transactions)
        _ = try model.importRecord(item2, into: \.transactions)
        XCTAssertEqual([expected1, expected2], model.transactions)
    }

    func testForeignKeyToAccountTableDoesNotFail() throws {
        let asset = MAsset(assetID: "abc", title: "ABC")
        var model = BaseModel(assets: [asset])
        let item = MTransaction(action: .buysell, transactedAt: timestamp1, accountID: "1", securityID: "VOO", shareCount: 1, sharePrice: 2)
        XCTAssertNoThrow(_ = try model.importRecord(item, into: \.transactions))
    }

    func testForeignKeyToSecurityTableDoesNotFail() throws {
        let accountA = MAccount(accountID: "1", title: "A")
        var model = BaseModel(accounts: [accountA])
        let item = MTransaction(action: .buysell, transactedAt: timestamp1, accountID: "1", securityID: "VOO", shareCount: 1, sharePrice: 2)
        XCTAssertNoThrow(_ = try model.importRecord(item, into: \.transactions))
    }
}
