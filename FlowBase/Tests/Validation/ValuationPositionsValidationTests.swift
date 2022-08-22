//
//  ValuationPositionsValidationTests.swift
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

class ValuationPositionsValidationTests: XCTestCase {
    
    func testAllowAnyMarketValue() throws {
        for value in [-100, -1, -0.0001, 0, 0.00009, 0.0001, 1, 100] {
            XCTAssertNoThrow(try MValuationPosition(snapshotID: "X", accountID: "1", assetID: "Bond", totalBasis: 1, marketValue: value).validate(epsilon: 0.0001))
        }
    }
    
    func testAllowAnyTotalBasis() throws {
        for value in [-100, -1, -0.0001, 0, 0.00009, 0.0001, 1, 100] {
            XCTAssertNoThrow(try MValuationPosition(snapshotID: "X", accountID: "1", assetID: "Bond", totalBasis: value, marketValue: 1).validate(epsilon: 0.0001))
        }
    }
}
