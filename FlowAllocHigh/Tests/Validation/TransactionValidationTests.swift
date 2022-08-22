//
//  TransactionValidationTests.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import XCTest

import FlowAllocLow
import FlowBase
import AllocData

@testable import FlowAllocHigh

class TransactionValidationTests: XCTestCase {
    var df: ISO8601DateFormatter!
    var timestamp1: Date!
    var timestamp2: Date!
    var timestamp3: Date!
    var timestampX: Date!

    override func setUpWithError() throws {
        df = ISO8601DateFormatter()
        timestamp1 = df.date(from: "2020-10-01T00:00:00Z")!
        timestamp2 = df.date(from: "2020-11-01T00:00:00Z")!
        timestamp3 = df.date(from: "2020-12-01T00:00:00Z")!
        timestampX = df.date(from: "2020-02-30T00:00:00Z")! // fake!
    }
    
    // no validation yet for history items
    func testInvalidDateDoesNotFail() throws {
        let txn = MTransaction(action: .buysell, transactedAt: timestampX, accountID: "1", securityID: "XOM", shareCount: 1, sharePrice: 1)
        XCTAssertNoThrow(try txn.validate())
    }
}
