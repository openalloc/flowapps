//
//  CapValidationTests.swift
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

class CapValidationTests: XCTestCase {
    func testKey() throws {
        let actual = MCap(accountID: " A B C ", assetID: " D E F ", limitPct: 1.0).primaryKey
        let expected = MCap.Key(accountID: "A B C", assetID: "D E F")
        XCTAssertEqual(expected, actual)
    }
    
    func testMissingAssetClassFails() throws {
        for isNew in [true, false] {
            let account = MAccount(accountID: "1")
            let model = BaseModel(accounts: [account])
            let expected = "'' is not a valid asset key."
            let cap = MCap(accountID: "1", assetID: "  \n ", limitPct: 1.0)
            XCTAssertThrowsError(try cap.validate(against: model, isNew: isNew)) { error in
                XCTAssertEqual(error as! FlowBaseError, FlowBaseError.validationFailure(expected))
            }
        }
    }
    
    func testInvalidTargetPercentFails() throws {
        for limitPct in [-1, -0.001, 1.001, 2] {
            let expected = "'\(limitPct.format3())' is not a valid limit percent for account cap."
            let cap = MCap(accountID: "1", assetID: "a", limitPct: limitPct)
            XCTAssertThrowsError(try cap.validate()) { error in
                XCTAssertEqual(error as! FlowBaseError, FlowBaseError.validationFailure(expected))
            }
        }
    }
    
    func testSliceLimitPctMustBeInRange() throws {
        let ac = "Equities"
        let accountID = "1"
        
        for limitPct in [-0.1, -0.01, -0.001, -0.0001, 1.1, 1.01, 1.001, 1.00011] {
            let expected = "'\(limitPct.format3())' is not a valid limit percent for account cap."
            let cap = MCap(accountID: accountID, assetID: ac, limitPct: limitPct)
            XCTAssertThrowsError(try cap.validate(), "limitPct=\(limitPct)") { error in
                XCTAssertEqual(error as! FlowBaseError, FlowBaseError.validationFailure(expected))
            }
        }
        
        for limitPct in [0, 0.1, 0.9, 1.0] {
            let cap = MCap(accountID: accountID, assetID: ac, limitPct: limitPct)
            XCTAssertNoThrow(try cap.validate(), "limitPct=\(limitPct)")
        }
    }
}
