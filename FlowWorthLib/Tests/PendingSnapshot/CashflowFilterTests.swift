//
//  CashflowFilterTests.swift
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

class CashflowFilterTests: XCTestCase {
    var tz: TimeZone!
    var df: ISO8601DateFormatter!
    var timestamp1c: Date!
    var timestamp1d: Date!
    var timestamp2a: Date!
    
    override func setUpWithError() throws {
        tz = TimeZone.init(identifier: "EST")!
        df = ISO8601DateFormatter()
        timestamp1c = df.date(from: "2020-06-02T05:00:00Z")! // end of previous day
        timestamp1d = df.date(from: "2020-06-02T05:00:01Z")! // beginning of day
        timestamp2a = df.date(from: "2020-06-02T12:00:00Z")! // anchor
    }
    
    func testEmpty() throws {
        let actual = MTransaction.cashflowFilter(transactions: [])
        let expected: [MTransaction] = []
        XCTAssertEqual(expected, actual)
    }
    
//    func testOneTransactionOutOfRange() throws {
//        let txn1 = MTransaction(action: .buysell, transactedAt: timestamp1c, accountID: "1", securityID: "BND", lotID: "", shareCount: 3, sharePrice: 11)
//        let txn2 = MTransaction(action: .buysell, transactedAt: timestamp2a, accountID: "1", securityID: "BND", lotID: "", shareCount: 3, sharePrice: 11)
//        let actual = MTransaction.cashflowFilter(transactions: [txn1],
//                                                 userExcludedTxnKeys: [txn2.primaryKey])
//        let expected: [MTransaction] = []
//        XCTAssertEqual(expected, actual)
//    }
    
    func testValuationTransactionExcluded() throws {
        let txn1 = MTransaction(action: .buysell, transactedAt: timestamp1c, accountID: "1", securityID: "BND", lotID: "", shareCount: 3, sharePrice: 11)
        let actual = MTransaction.cashflowFilter(transactions: [txn1],
                                                 userExcludedTxnKeys: [txn1.primaryKey])
        let expected: [MTransaction] = []
        XCTAssertEqual(expected, actual)
    }
    
    func testOneTransactionJustInRange() throws {
        let txn1 = MTransaction(action: .buysell, transactedAt: timestamp1d, accountID: "1", securityID: "BND", lotID: "", shareCount: 3, sharePrice: 11)
        let txn2 = MTransaction(action: .buysell, transactedAt: timestamp2a, accountID: "1", securityID: "BND", lotID: "", shareCount: 3, sharePrice: 11)
        let actual = MTransaction.cashflowFilter(transactions: [txn1],
                                                 userExcludedTxnKeys: [txn2.primaryKey])
        let expected: [MTransaction] = [txn1]
        XCTAssertEqual(expected, actual)
    }
    
    func testTwoTransactionThatAreDupesA() throws {
        let txn1 = MTransaction(action: .buysell, transactedAt: timestamp1d, accountID: "1", securityID: "BND", lotID: "a", shareCount: 3, sharePrice: 11)
        let txn2 = MTransaction(action: .buysell, transactedAt: timestamp1d, accountID: "1", securityID: "BND", lotID: "a", shareCount: 3, sharePrice: 11)
        let actual = MTransaction.cashflowFilter(transactions: [txn1, txn2])
        XCTAssertEqual(1, actual.count)
        XCTAssertEqual(txn1.accountID, actual[0].accountID)
        XCTAssertEqual(txn1.securityID, actual[0].securityID)
        XCTAssertEqual(txn1.lotID, actual[0].lotID)
        XCTAssertEqual(txn1.shareCount, actual[0].shareCount)
        XCTAssertEqual(txn1.sharePrice, actual[0].sharePrice)
        XCTAssertEqual(txn1.transactedAt, actual[0].transactedAt)
    }
    
    func testDisallowPreviouslyConsumed() throws {
        let txn1 = MTransaction(action: .buysell, transactedAt: timestamp1d, accountID: "1", securityID: "BND", lotID: "a", shareCount: 3, sharePrice: 11)
        let actual = MTransaction.cashflowFilter(transactions: [txn1],
                                                 userExcludedTxnKeys: [txn1.primaryKey])
        let expected: [MTransaction] = []
        XCTAssertEqual(expected, actual)
    }
    
    // sharePrice no longer part of key
//    func testAllowDifferBySharePrice() throws {
//        let txn1 = MTransaction(action: .buysell, transactedAt: timestamp1d, accountID: "1", securityID: "BND", lotID: "a", shareCount: 3, sharePrice: 11.00)
//        let txn2 = MTransaction(action: .buysell, transactedAt: timestamp1d, accountID: "1", securityID: "BND", lotID: "a", shareCount: 3, sharePrice: 11.01)
//        let actual = MTransaction.cashflowFilter(transactions: [txn1, txn2])
//        XCTAssertEqual(2, actual.count)
//        XCTAssertEqual([txn1, txn2], actual)
//    }
    
    func testAllowDifferByShareCount() throws {
        let txn1 = MTransaction(action: .buysell, transactedAt: timestamp1d, accountID: "1", securityID: "BND", lotID: "a", shareCount: 3.00, sharePrice: 11.00)
        let txn2 = MTransaction(action: .buysell, transactedAt: timestamp1d, accountID: "1", securityID: "BND", lotID: "a", shareCount: 3.01, sharePrice: 11.00)
        let actual = MTransaction.cashflowFilter(transactions: [txn1, txn2])
        XCTAssertEqual(2, actual.count)
        XCTAssertEqual([txn1, txn2], actual)
    }
    
    func testAllowDifferByLot() throws {
        let txn1 = MTransaction(action: .buysell, transactedAt: timestamp1d, accountID: "1", securityID: "BND", lotID: "a", shareCount: 3.00, sharePrice: 11.00)
        let txn2 = MTransaction(action: .buysell, transactedAt: timestamp1d, accountID: "1", securityID: "BND", lotID: "b", shareCount: 3.00, sharePrice: 11.00)
        let actual = MTransaction.cashflowFilter(transactions: [txn1, txn2])
        XCTAssertEqual(2, actual.count)
        XCTAssertEqual([txn1, txn2], actual)
    }
    
    func testAllowDifferBySecurity() throws {
        let txn1 = MTransaction(action: .buysell, transactedAt: timestamp1d, accountID: "1", securityID: "BND", lotID: "a", shareCount: 3.00, sharePrice: 11.00)
        let txn2 = MTransaction(action: .buysell, transactedAt: timestamp1d, accountID: "1", securityID: "AGG", lotID: "a", shareCount: 3.00, sharePrice: 11.00)
        let actual = MTransaction.cashflowFilter(transactions: [txn1, txn2])
        XCTAssertEqual(2, actual.count)
        XCTAssertEqual([txn1, txn2], actual)
    }
    
    func testAllowDifferByAccount() throws {
        let txn1 = MTransaction(action: .buysell, transactedAt: timestamp1d, accountID: "1", securityID: "BND", lotID: "a", shareCount: 3.00, sharePrice: 11.00)
        let txn2 = MTransaction(action: .buysell, transactedAt: timestamp1d, accountID: "2", securityID: "BND", lotID: "a", shareCount: 3.00, sharePrice: 11.00)
        let actual = MTransaction.cashflowFilter(transactions: [txn1, txn2])
        XCTAssertEqual(2, actual.count)
        XCTAssertEqual([txn1, txn2], actual)
    }
    
    func testTwoTransactionThatDifferOnlyByLot() throws {
        let txn1 = MTransaction(action: .buysell, transactedAt: timestamp1d, accountID: "1", securityID: "BND", lotID: "a", shareCount: 3, sharePrice: 11)
        let txn2 = MTransaction(action: .buysell, transactedAt: timestamp1d, accountID: "1", securityID: "BND", lotID: "b", shareCount: 3, sharePrice: 11)
        let actual = MTransaction.cashflowFilter(transactions: [txn1, txn2],
                                                 userExcludedTxnKeys: [txn2.primaryKey])
        let expected = [txn1]
        XCTAssertEqual(expected, actual)
    }
}
