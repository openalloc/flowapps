//
//  ModelValidationTests.swift
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

class ModelValidationTests: XCTestCase {
    func testValidatesAccounts() throws {
        let account = MAccount(accountID: " \n  ", title: "a")
        let model = BaseModel(accounts: [account], allocations: [], assets: [])
        let expected = "Invalid primary key for account: [AccountID: '']."
        XCTAssertThrowsError(try model.validate()) { error in
            XCTAssertEqual(error as! FlowBaseError, FlowBaseError.validationFailure(expected))
        }
    }

    func testValidatesAllocations() throws {
        let strategy = MStrategy(strategyID: "1")
        let allocation = MAllocation(strategyID: "1", assetID: "  \n ", targetPct: 1.0)
        let model = BaseModel(accounts: [], allocations: [allocation], strategies: [strategy], assets: [])
        let expected = "'' is not a valid asset key."
        XCTAssertThrowsError(try model.validate()) { error in
            XCTAssertEqual(error as! FlowBaseError, FlowBaseError.validationFailure(expected))
        }
    }

    func testValidatesAssets() throws {
        let asset = MAsset(assetID: "  \n ", title: "a")
        let model = BaseModel(accounts: [], allocations: [], assets: [asset])
        let expected = "Invalid primary key for asset: [AssetID: '']."
        XCTAssertThrowsError(try model.validate()) { error in
            XCTAssertEqual(error as! FlowBaseError, FlowBaseError.validationFailure(expected))
        }
    }
}
