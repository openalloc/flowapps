//
//  BaseParamsTests.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import XCTest

import FlowBase
import AllocData

@testable import FlowAllocLow

class BaseParamsTests: XCTestCase {
    
    let account1 = MAccount.Key(accountID: "1")
    let bond = MAsset.Key(assetID: "Bond")

    func testValidateFailsDueToMissingAccounts() throws {
        XCTAssertThrowsError(try BaseParams().validate()) { error in
            XCTAssertEqual(error as! AllocLowError2, AllocLowError2.invalidParams("missing accounts"))
        }
    }

    func testValidateMissingAllocation() throws {
        XCTAssertThrowsError(try BaseParams(accountKeys: [account1]).validate()) { error in
            XCTAssertEqual(error as! AllocLowError2, AllocLowError2.invalidParams("missing allocation"))
        }
    }

    func testValidateSucceeds() throws {
        XCTAssertNoThrow(try BaseParams(accountKeys: [account1], assetKeys: [bond]).validate())
    }
}
