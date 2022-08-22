//
//  SecurityValidationTests.swift
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

class SecurityValidationTests: XCTestCase {
    func testKey() throws {
        let actual = MSecurity(securityID: " A B C ", assetID: " D E F ").primaryKey
        let expected = MSecurity.Key(securityID: "a b c")
        XCTAssertEqual(expected, actual)
    }
    
    func testMissingAssetClassSucceeds() throws {
        for isNew in [true, false] {
            let model = BaseModel()
            let security = MSecurity(securityID: "a", assetID: "  \n ")
            XCTAssertNoThrow(try security.validate())
            XCTAssertNoThrow(try security.validate(against: model, isNew: isNew))
        }
    }
    
    func testMissingTickerFails() throws {
        let expected = "Invalid primary key for security: [SecurityID: '']."
        let security = MSecurity(securityID: "  \n ", assetID: "a")
        XCTAssertThrowsError(try security.validate()) { error in
            XCTAssertEqual(error as! FlowBaseError, FlowBaseError.validationFailure(expected))
        }
    }
}
