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

import AllocData

import FlowBase

@testable import FlowBase

class TransactionValidationTests: XCTestCase {
    let timestamp = Date()
    
    func testValidate() {
        for badSharePrice in [-100, -0.01, 0] {
            let t1 = MTransaction(action: .buysell, transactedAt: timestamp, accountID: "1", securityID: "BND", lotID: "3", shareCount: 1, sharePrice: badSharePrice)
            XCTAssertThrowsError(try t1.validate()) { error in
                XCTAssertEqual(error as! FlowBaseError, FlowBaseError.validationFailure("'\(badSharePrice.format2())' is not a valid share price for transaction."))
            }
        }
    }
}
