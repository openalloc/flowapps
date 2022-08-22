//
//  HighAccountTests.swift
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

class HighAccountTests: XCTestCase {
    func testSingle() throws {
        let original = MAccount(accountID: "100", title: "My Account")
        let encoded: String = try StorageManager.encodeToJSON(original)
        let actual: MAccount = try StorageManager.decode(fromJSON: encoded)
        XCTAssertEqual(original, actual)
    }
}
