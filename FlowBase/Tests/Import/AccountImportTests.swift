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
import FINporter

@testable import FlowBase

class AccountImportTests: XCTestCase {
    func testInvalidIDFails() throws {
        var model = BaseModel()
        let expected = "Invalid primary key for account: [AccountID: '']."
        let row: AllocRowed.DecodedRow = ["accountID": " \n  "]
        XCTAssertThrowsError(try model.importRow(row, into: \.accounts)) { error in
            XCTAssertEqual(error as! FlowBaseError, FlowBaseError.validationFailure(expected))
        }
    }

    func testInvalidTitleFails() throws {
        var model = BaseModel()
        let row: AllocRowed.DecodedRow = ["accountID": "1", "title": " \n  "]
        XCTAssertNoThrow(try model.importRow(row, into: \.accounts))
    }

    func testNonUniqueTitleFails() throws {
        var model = BaseModel()
        let row1: AllocRowed.DecodedRow = ["accountID": "1", "title": "a"]
        _ = try model.importRow(row1, into: \.accounts)

        let expected = "Conflicting titles 'a'."
        let row2: AllocRowed.DecodedRow = ["accountID": "2", "title": "a"]
        XCTAssertThrowsError(try model.importRow(row2, into: \.accounts)) { error in
            XCTAssertEqual(error as! FlowBaseError, FlowBaseError.validationFailure(expected))
        }
    }

    func testValidAccountSucceeds() throws {
        var model = BaseModel()
        let account = MAccount(accountID: "1", title: "a")
        _ = try model.importRecord(account, into: \.accounts)
        let expected = MAccount(accountID: "1", title: "a")
        XCTAssertEqual([expected], model.accounts)
    }

    func testReplaceExisting() throws {
        var model = BaseModel()
        let accountA = MAccount(accountID: "1", title: "A")
        let accountB = MAccount(accountID: "1", title: "B")
        _ = try model.importRecord(accountA, into: \.accounts)
        _ = try model.importRecord(accountB, into: \.accounts)
        let expected = MAccount(accountID: "1", title: "B")
        XCTAssertEqual([expected], model.accounts)
        XCTAssertEqual(1, model.accounts.count)
    }

    func testDelimitedImport() throws {
        let accountA = MAccount(accountID: "1", title: "A")
        var model = BaseModel(accounts: [accountA])

        let impB = MAccount(accountID: "2", title: "B")
        let impC = MAccount(accountID: "3", title: "C")
        let toImport = [impB, impC]

        let encoder = DelimitedEncoder()
        _ = try encoder.encode(headers: AllocAttribute.getHeaders(MAccount.attributes))
        let data: Data = try encoder.encode(rows: toImport)

        //var rejectedRows = [AllocRowed.DecodedRow]()
        let url = URL(fileURLWithPath: "hello.csv")
        _ = try model.detectDecodeImport(data: data, url: url) //, purchasesOnly: false)  //, rejectedRows: &rejectedRows

        let accountB = MAccount(accountID: "2", title: "B")
        let accountC = MAccount(accountID: "3", title: "C")
        let expected = [accountA, accountB, accountC]
        XCTAssertEqual(expected, model.accounts)
    }
    
    func testForeignKeyToStrategyTableCreated() throws {
        //let asset = MAsset(assetID: "A", title: "A")
        // let strategy = MStrategy(strategyID: "1", title: "60/40")
        var model = BaseModel(strategies: [])
        XCTAssertEqual(0, model.strategies.count)
        let row: AllocRowed.DecodedRow = ["accountID": "1", "accountStrategyID": "X", "title": "X"]
        _ = try model.importRow(row, into: \.accounts)
        XCTAssertEqual(1, model.strategies.count)
        XCTAssertEqual(MStrategy(strategyID: "X", title: nil), model.strategies.first!)
    }
}
