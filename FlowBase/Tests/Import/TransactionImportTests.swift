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
import FINporter

@testable import FlowBase

class TransactionImportTests: XCTestCase {
    
    var df: ISO8601DateFormatter!
    var timestamp1: Date!
    var model: BaseModel!
    //var ax: WorthContext!

    override func setUpWithError() throws {
        df = ISO8601DateFormatter()
        timestamp1 = df.date(from: "2020-01-31T12:00:00Z")!
        model = BaseModel()
        //ax = WorthContext(model)
    }

    func testForeignKeyToSecuritiesCreated() throws {
        let account = MAccount(accountID: "1", title: "One")
        var model = BaseModel(accounts: [account])
        XCTAssertEqual(0, model.securities.count)
        let row: AllocRowed.DecodedRow = ["txnAction": MTransaction.Action.buysell, "txnTransactedAt": timestamp1, "txnAccountID": "1", "txnSecurityID": "SPY", "txnLotID": "", "txnShareCount": 1.0, "txnSharePrice": 1.0]
        _ = try model.importRow(row, into: \.transactions)
        XCTAssertEqual(1, model.securities.count)
        XCTAssertEqual(MSecurity(securityID: "SPY", assetID: nil, sharePrice: nil, updatedAt: nil), model.securities.first!)
    }

    func testForeignKeyToAccountCreates() throws {
        let security = MSecurity(securityID: "SPY", assetID: "equities")
        // let account1 = MAccount(accountID: "1", title: "One")
        var model = BaseModel(accounts: [])
        XCTAssertEqual(0, model.accounts.count)
        let row: AllocRowed.DecodedRow = ["txnAction": MTransaction.Action.buysell, "txnTransactedAt": timestamp1, "txnAccountID": "1", "txnSecurityID": security.securityID, "txnLotID": "", "txnShareCount": 1.0, "txnSharePrice": 1.0]
        _ = try model.importRow(row, into: \.transactions)
        XCTAssertEqual(1, model.accounts.count)
        XCTAssertEqual(MAccount(accountID: "1", title: nil, isTaxable: false), model.accounts.first!)
    }
    
    func testExactDuplicate() throws {
        let security = MSecurity(securityID: "SPY", assetID: "equities")
        let account = MAccount(accountID: "1", title: "One")
        model.securities = [security]
        model.accounts = [account]
        let row: AllocRowed.DecodedRow = ["txnAction": MTransaction.Action.buysell, "txnTransactedAt": timestamp1,
                                  "txnAccountID": account.accountID,
                                  "txnSecurityID": security.securityID,
                                  "txnLotID": "",
                                  "txnShareCount": 1.0,
                                  "txnSharePrice": 1.0]
        XCTAssertEqual(0, model.transactions.count)
        _ = try model.importRow(row, into: \.transactions)
        _ = try model.importRow(row, into: \.transactions)
        XCTAssertEqual(1, model.transactions.count)
    }
    
    func testDifferById() throws {
        let security = MSecurity(securityID: "SPY", assetID: "equities")
        let account = MAccount(accountID: "1", title: "One")
        model.securities = [security]
        model.accounts = [account]
        var row: AllocRowed.DecodedRow = ["txnAction": MTransaction.Action.buysell, "txnTransactedAt": timestamp1,
                                  "txnAccountID": account.accountID,
                                  "txnSecurityID": security.securityID,
                                  "txnLotID": "",
                                  "txnShareCount": 1.0,
                                  "txnSharePrice": 1.0,
                                  "transactionID": "A"]
        XCTAssertEqual(0, model.transactions.count)
        _ = try model.importRow(row, into: \.transactions)
        row["transactionID"] = "B"
        _ = try model.importRow(row, into: \.transactions)
        XCTAssertEqual(1, model.transactions.count)
    }
    
    func testSecurityTransfer() throws {
        // tolerate no shareprice on transaction
        // only number of shares transferred, but no valuation
        // this can be a problem, because it's not clear how to set up cash flow
        // applies to both chuck and fido
        let account = MAccount(accountID: "1", title: "One")
        var model = BaseModel(accounts: [account])
        XCTAssertEqual(0, model.securities.count)
        let row: AllocRowed.DecodedRow = ["txnAction": MTransaction.Action.transfer, "txnTransactedAt": timestamp1, "txnAccountID": "1", "txnSecurityID": "SPY", "txnShareCount": 1.0]
        _ = try model.importRow(row, into: \.transactions)
        XCTAssertEqual(1, model.transactions.count)
    }
}
