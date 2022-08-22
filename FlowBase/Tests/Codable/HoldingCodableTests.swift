//
//  HoldingCodableTests.swift
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

import AllocData

@testable import FlowBase

class HoldingCodableTests: XCTestCase {
    func testBasic() throws {
        let account = MAccount(accountID: "1")
        let security = MSecurity(securityID: "SPY")
        let expected = MHolding(accountID: account.accountID, securityID: security.securityID, lotID: "", shareCount: 5)
        let encoded: String = try StorageManager.encodeToJSON(expected)
        let actual: MHolding = try StorageManager.decode(fromJSON: encoded)
        XCTAssertEqual(expected, actual)
    }
}
