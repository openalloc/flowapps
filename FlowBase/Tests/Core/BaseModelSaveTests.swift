//
//  BaseModelSaveTests.swift
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
import FINporter

@testable import FlowBase

class BaseModelSaveTests: XCTestCase {
    
    func testAddNew() throws {
        let account = MAccount(accountID: "1", title: "Blah")
        var model = BaseModel(accounts: [])
        let result = BaseModel.saveHelper(&model.accounts, account, originalID: nil)
        XCTAssertTrue(result)
    }
    
    func testAddNewWithConflictFails() throws {
        let account1a = MAccount(accountID: "1", title: "Blah")
        let account1b = MAccount(accountID: "1", title: "Bleh")
        var model = BaseModel(accounts: [account1b])
        let result = BaseModel.saveHelper(&model.accounts, account1a, originalID: nil)
        XCTAssertFalse(result)
    }

    func testReplaceExisting() throws {
        let account1a = MAccount(accountID: "1", title: "Blah")
        let account1b = MAccount(accountID: "1", title: "Bleh")
        var model = BaseModel(accounts: [account1b])
        let result = BaseModel.saveHelper(&model.accounts, account1a, originalID: account1a.id)
        XCTAssertTrue(result)
    }

    func testReplaceExistingMissingFails() throws {
        let account1a = MAccount(accountID: "1", title: "Blah")
        var model = BaseModel(accounts: [])
        let result = BaseModel.saveHelper(&model.accounts, account1a, originalID: account1a.id)
        XCTAssertFalse(result)
    }
}
