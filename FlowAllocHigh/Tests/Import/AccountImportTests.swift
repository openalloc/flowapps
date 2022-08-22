//
//  AccountImportTests.swift
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

class AccountImportTests: XCTestCase {
    func testInvalidIDFails() throws {
        var model = BaseModel()
        let expected = "Invalid primary key for account: [AccountID: '']."
        let account = MAccount(accountID: " \n  ", title: "a")
        XCTAssertThrowsError(try model.importRecord(account, into: \.accounts)) { error in
            XCTAssertEqual(error as! FlowBaseError, FlowBaseError.validationFailure(expected))
        }
    }

    func testValidFlowAccountSucceeds() throws {
        var model = BaseModel()
        let account = MAccount(accountID: "1", title: "a")
        _ = try model.importRecord(account, into: \.accounts)
        let expected = [MAccount(accountID: "1", title: "a")]
        XCTAssertEqual(expected, model.accounts)
    }

    func testReplaceExisting() throws {
        var model = BaseModel()
        let accountA = MAccount(accountID: "1", title: "A")
        let accountB = MAccount(accountID: "1", title: "B")
        let expectedA = MAccount(accountID: "1", title: "A")
        let expectedB = MAccount(accountID: "1", title: "B")
        _ = try model.importRecord(accountA, into: \.accounts)
        XCTAssertEqual([expectedA], model.accounts)
        _ = try model.importRecord(accountB, into: \.accounts)
        XCTAssertEqual([expectedB], model.accounts)
    }
}
