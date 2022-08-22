//
//  CashflowTests.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

@testable import FlowWorthLib
import XCTest

import AllocData

import FlowBase

class GenerateCashflowTests: XCTestCase {
    var df: ISO8601DateFormatter!
    var timestamp0: Date!
    var timestamp1: Date!
    var timestamp2: Date!
    var timestamp3: Date!
    var period1: DateInterval!
    var agg: MSecurity!
    var spy: MSecurity!
    var core: MSecurity!
    var securityMap: SecurityMap!

    override func setUpWithError() throws {
        df = ISO8601DateFormatter()
        timestamp0 = df.date(from: "2020-06-01T11:00:00Z")! // one hour before
        timestamp1 = df.date(from: "2020-06-01T12:00:00Z")!
        timestamp2 = df.date(from: "2020-06-01T13:00:00Z")! // one hour later
        timestamp3 = df.date(from: "2020-06-03T12:00:00Z")!
        period1 = DateInterval(start: timestamp0, end: timestamp3)
        agg = MSecurity(securityID: "AGG", assetID: "Bond", sharePrice: 7)
        spy = MSecurity(securityID: "SPY", assetID: "LC", sharePrice: 100)
        core = MSecurity(securityID: "CORE", assetID: "Cash", sharePrice: 1)
        securityMap = [MSecurity.Key(securityID: "AGG"): agg, MSecurity.Key(securityID: "SPY"): spy, MSecurity.Key(securityID: "CORE"): core]
    }
    
    func testEmpty() throws {
        let actual = MValuationCashflow.generateCashflow(from: [], period: period1, securityMap: securityMap)
        let expected: [MValuationCashflow] = []
        XCTAssertEqual(expected, actual)
    }
    
    func testStartClamped() throws {
        let period = DateInterval(start: timestamp2, end: timestamp3)
        let txn = MTransaction(action: .miscflow, transactedAt: timestamp1, accountID: "1", securityID: "", lotID: "", shareCount: 3, sharePrice: 1)
        let actual = MValuationCashflow.generateCashflow(from: [txn], period: period, securityMap: securityMap)
        let expected: [MValuationCashflow] = [
            MValuationCashflow(transactedAt: timestamp2, accountID: "1", assetID: "Cash", amount: 3.0)
        ]
        XCTAssertEqual(expected, actual)
    }
    
    func testEndClamped() throws {
        let period = DateInterval(start: timestamp1, end: timestamp2)
        let txn = MTransaction(action: .miscflow, transactedAt: timestamp3, accountID: "1", securityID: "", lotID: "", shareCount: 3, sharePrice: 1)
        let actual = MValuationCashflow.generateCashflow(from: [txn], period: period, securityMap: securityMap)
        let expected: [MValuationCashflow] = [
            MValuationCashflow(transactedAt: timestamp2, accountID: "1", assetID: "Cash", amount: 3.0)
        ]
        XCTAssertEqual(expected, actual)
    }

    func testPurchaseSecurity() throws {
        let txn = MTransaction(action: .buysell, transactedAt: timestamp1, accountID: "1", securityID: "SPY", lotID: "", shareCount: 3, sharePrice: 105)
        let actual = MValuationCashflow.generateCashflow(from: [txn], period: period1, securityMap: securityMap)
        let expected: [MValuationCashflow] = [
            MValuationCashflow(transactedAt: timestamp1, accountID: "1", assetID: "LC", amount: 315.0),
            MValuationCashflow(transactedAt: timestamp1, accountID: "1", assetID: "Cash", amount: -315.0)
        ]
        XCTAssertEqual(expected, actual)
    }
    
    func testPurchaseCash() throws {
        let txn = MTransaction(action: .buysell, transactedAt: timestamp1, accountID: "1", securityID: "CORE", lotID: "", shareCount: 3, sharePrice: 105)
        let actual = MValuationCashflow.generateCashflow(from: [txn], period: period1, securityMap: securityMap)
        let expected: [MValuationCashflow] = [
        ]
        XCTAssertEqual(expected, actual)
    }

    func testSellSecurity() throws {
        let txn = MTransaction(action: .buysell, transactedAt: timestamp1, accountID: "1", securityID: "SPY", lotID: "", shareCount: -3, sharePrice: 105)
        let actual = MValuationCashflow.generateCashflow(from: [txn], period: period1, securityMap: securityMap)
        let expected: [MValuationCashflow] = [
            MValuationCashflow(transactedAt: timestamp1, accountID: "1", assetID: "LC", amount: -315.0),
            MValuationCashflow(transactedAt: timestamp1, accountID: "1", assetID: "Cash", amount: 315.0)
        ]
        XCTAssertEqual(expected, actual)
    }
    
    func testSellCash() throws {
        let txn = MTransaction(action: .buysell, transactedAt: timestamp1, accountID: "1", securityID: "CORE", lotID: "", shareCount: -3, sharePrice: 105)
        let actual = MValuationCashflow.generateCashflow(from: [txn], period: period1, securityMap: securityMap)
        let expected: [MValuationCashflow] = [
        ]
        XCTAssertEqual(expected, actual)
    }

    func testInterestIncome() throws {
        let txn = MTransaction(action: .income, transactedAt: timestamp1, accountID: "1", securityID: "", lotID: "", shareCount: 1.55, sharePrice: 1)
        let actual = MValuationCashflow.generateCashflow(from: [txn], period: period1, securityMap: securityMap)
        let expected: [MValuationCashflow] = [
            MValuationCashflow(transactedAt: timestamp1, accountID: "1", assetID: "Cash", amount: -1.55),
            MValuationCashflow(transactedAt: timestamp1, accountID: "1", assetID: "Cash", amount: 1.55)
        ]
        XCTAssertEqual(expected, actual)
    }
    
    func testDividendIncomeFromSecurity() throws {
        let txn = MTransaction(action: .income, transactedAt: timestamp1, accountID: "1", securityID: "SPY", lotID: "", shareCount: 1.55, sharePrice: 1)
        let actual = MValuationCashflow.generateCashflow(from: [txn], period: period1, securityMap: securityMap)
        let expected: [MValuationCashflow] = [
            MValuationCashflow(transactedAt: timestamp1, accountID: "1", assetID: "LC", amount: -1.55),
            MValuationCashflow(transactedAt: timestamp1, accountID: "1", assetID: "Cash", amount: 1.55)
        ]
        XCTAssertEqual(expected, actual)
    }
    
    func testDividendIncomeFromCash() throws {
        let txn = MTransaction(action: .income, transactedAt: timestamp1, accountID: "1", securityID: "CORE", lotID: "", shareCount: 1.55, sharePrice: 1)
        let actual = MValuationCashflow.generateCashflow(from: [txn], period: period1, securityMap: securityMap)
        let expected: [MValuationCashflow] = [
            MValuationCashflow(transactedAt: timestamp1, accountID: "1", assetID: "Cash", amount: -1.55),
            MValuationCashflow(transactedAt: timestamp1, accountID: "1", assetID: "Cash", amount: 1.55)
        ]
        XCTAssertEqual(expected, actual)
    }

    func testTransferCashIn() throws {
        let txn = MTransaction(action: .transfer,
                               transactedAt: timestamp1,
                               accountID: "1",
                               securityID: "",
                               lotID: "",
                               shareCount: 1.55,
                               sharePrice: 1)
        let actual = MValuationCashflow.generateCashflow(from: [txn], period: period1, securityMap: securityMap)
        let expected: [MValuationCashflow] = [
            MValuationCashflow(transactedAt: timestamp1, accountID: "1", assetID: "Cash", amount: 1.55)
        ]
        XCTAssertEqual(expected, actual)
    }
    
    func testTransferCashOut() throws {
        let txn = MTransaction(action: .transfer, transactedAt: timestamp1, accountID: "1", securityID: "", lotID: "", shareCount: -155, sharePrice: 1)
        let actual = MValuationCashflow.generateCashflow(from: [txn], period: period1, securityMap: securityMap)
        let expected: [MValuationCashflow] = [
            MValuationCashflow(transactedAt: timestamp1, accountID: "1", assetID: "Cash", amount: -155)
        ]
        XCTAssertEqual(expected, actual)
    }

    func testTransferSecurityIn() throws {
        let txn = MTransaction(action: .transfer, transactedAt: timestamp1, accountID: "1", securityID: "SPY", lotID: "", shareCount: 15, sharePrice: 102)
        let actual = MValuationCashflow.generateCashflow(from: [txn], period: period1, securityMap: securityMap)
        let expected: [MValuationCashflow] = [
            MValuationCashflow(transactedAt: timestamp1, accountID: "1", assetID: "LC", amount: 1530)
        ]
        XCTAssertEqual(expected, actual)
    }
    
    func testTransferSecurityOut() throws {
        let txn = MTransaction(action: .transfer, transactedAt: timestamp1, accountID: "1", securityID: "SPY", lotID: "", shareCount: -15, sharePrice: 102)
        let actual = MValuationCashflow.generateCashflow(from: [txn], period: period1, securityMap: securityMap)
        let expected: [MValuationCashflow] = [
            MValuationCashflow(transactedAt: timestamp1, accountID: "1", assetID: "LC", amount: -1530),
            MValuationCashflow(transactedAt: timestamp1, accountID: "1", assetID: "Cash", amount: 1530),
            MValuationCashflow(transactedAt: timestamp3, accountID: "1", assetID: "Cash", amount: -1530),
        ]
        XCTAssertEqual(expected, actual)
    }
    
    func testMiscIn() throws {
        let txn = MTransaction(action: .miscflow, transactedAt: timestamp1, accountID: "1", securityID: "", lotID: "", shareCount: 12, sharePrice: 1)
        let actual = MValuationCashflow.generateCashflow(from: [txn], period: period1, securityMap: securityMap)
        let expected: [MValuationCashflow] = [
            MValuationCashflow(transactedAt: timestamp1, accountID: "1", assetID: "Cash", amount: 12)
        ]
        XCTAssertEqual(expected, actual)
    }

    func testMiscOut() throws {
        let txn = MTransaction(action: .miscflow, transactedAt: timestamp1, accountID: "1", securityID: "", lotID: "", shareCount: -12, sharePrice: 1)
        let actual = MValuationCashflow.generateCashflow(from: [txn], period: period1, securityMap: securityMap)
        let expected: [MValuationCashflow] = [
            MValuationCashflow(transactedAt: timestamp1, accountID: "1", assetID: "Cash", amount: -12)
        ]
        XCTAssertEqual(expected, actual)
    }
}
