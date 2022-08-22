//
//  HoldingValidationTests.swift
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

class HoldingValidationTests: XCTestCase {
    let security = MSecurity(securityID: "SPY", assetID: "equities")

    func testKey() throws {
        let actual = MHolding(accountID: " A B C ", securityID: " D E F ", lotID: "", shareCount: 1, shareBasis: 1).primaryKey
        let expected = MHolding.Key(accountID: "A B C", securityID: "D E F", lotID: "", shareCount: 1, shareBasis: 1) // "a b c,d e f,"
        XCTAssertEqual(expected, actual)
    }

    func testAnyShareCountPermitted() throws {
        for shareCount in [-1000, -1, -0.001, 0, 0.001, 1, 1000] {
            //let expected = "'\(shareCount.format3())' is not a valid share count for holding."
            let holding = MHolding(accountID: "1", securityID: security.securityID, lotID: "", shareCount: shareCount, shareBasis: 1)
            XCTAssertNoThrow(try holding.validate())
        }
    }

    func testInvalidShareBasisFails() throws {
        for shareBasis in [-1000, -1, -0.001] {
            let expected = "'\(shareBasis.format2())' is not a valid share basis for holding."
            let holding = MHolding(accountID: "1", securityID: security.securityID, lotID: "", shareCount: 1, shareBasis: shareBasis)
            XCTAssertThrowsError(try holding.validate()) { error in
                XCTAssertEqual(error as! FlowBaseError, FlowBaseError.validationFailure(expected))
            }
        }
    }
}
