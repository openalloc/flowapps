//
//  CapImportTests.swift
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

import FlowBase

@testable import FlowBase

class CapImportTests: XCTestCase {
    func testInvalidAssetFails() throws {
        let accountA = MAccount(accountID: "1", title: "A")
        var model = BaseModel(accounts: [accountA])
        let expected = "Invalid primary key for cap: [AccountID: '1', AssetID: '']."
        let slice = MCap(accountID: "1", assetID: "  \n ", limitPct: 1.0)
        XCTAssertThrowsError(try model.importRecord(slice, into: \.caps)) { error in
            XCTAssertEqual(error as! FlowBaseError, FlowBaseError.validationFailure(expected))
        }
    }

    func testInvalidLimitPercentFails() throws {
        let accountA = MAccount(accountID: "1", title: "A")
        var model = BaseModel(accounts: [accountA])
        let expected = "'1.001' is not a valid limit percent for account cap."
        let slice = MCap(accountID: "1", assetID: "LC", limitPct: 1.001)
        XCTAssertThrowsError(try model.importRecord(slice, into: \.caps)) { error in
            XCTAssertEqual(error as! FlowBaseError, FlowBaseError.validationFailure(expected))
        }
    }

    func testValidCapSucceeds() throws {
        let accountA = MAccount(accountID: "1", title: "A")
        let asset = MAsset(assetID: "a", title: "a")
        var model = BaseModel(accounts: [accountA], assets: [asset])
        let slice = MCap(accountID: "1", assetID: "a", limitPct: 1.0)
        _ = try model.importRecord(slice, into: \.caps)
        XCTAssertEqual([MCap(accountID: "1", assetID: "a", limitPct: 1.0)], model.caps)
    }

    func testReplaceExisting() throws {
        let accountA = MAccount(accountID: "1", title: "A")
        let asset = MAsset(assetID: "A", title: "A")
        var model = BaseModel(accounts: [accountA], assets: [asset])
        let slice1 = MCap(accountID: "1", assetID: "A", limitPct: 0.1)
        let slice2 = MCap(accountID: "1", assetID: "A", limitPct: 0.2)
        _ = try model.importRecord(slice1, into: \.caps)
        XCTAssertEqual([MCap(accountID: "1", assetID: "A", limitPct: 0.1)], model.caps)
        _ = try model.importRecord(slice2, into: \.caps)
        XCTAssertEqual([MCap(accountID: "1", assetID: "A", limitPct: 0.2)], model.caps)
    }

    func testForeignKeyToAccountTableCreates() throws {
        let asset = MAsset(assetID: "abc", title: "ABC")
        var model = BaseModel(assets: [asset])
        XCTAssertEqual(0, model.accounts.count)
        let row: AllocRowed.DecodedRow = ["capAccountID": "1", "capAssetID": "abc", "limitPct": 1.0]
        _ = try model.importRow(row, into: \.caps)
        XCTAssertEqual(1, model.accounts.count)
        XCTAssertEqual(MAccount(accountID: "1", title: nil, isTaxable: false), model.accounts.first!)
    }

    func testForeignKeyToAssetTableCreates() throws {
        let accountA = MAccount(accountID: "1", title: "A")
        var model = BaseModel(accounts: [accountA])
        XCTAssertEqual(0, model.assets.count)
        let row: AllocRowed.DecodedRow = ["capAccountID": "1", "capAssetID": "abc", "limitPct": 1.0]
        _ = try model.importRow(row, into: \.caps)
        XCTAssertEqual(1, model.assets.count)
        XCTAssertEqual(MAsset(assetID: "abc", title: nil), model.assets.first!)
    }
}
