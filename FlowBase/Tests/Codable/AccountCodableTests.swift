//
//  AccountCodableTests.swift
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

class AccountCodableTests: XCTestCase {
    func testBasic() throws {
        let expected = MAccount(accountID: "1", title: "One", isTaxable: true)
        let encoded: String = try StorageManager.encodeToJSON(expected)
        let actual: MAccount = try StorageManager.decode(fromJSON: encoded)
        XCTAssertEqual(expected, actual)
    }
}
