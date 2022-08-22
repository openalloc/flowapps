//
//  MStrategyTests.swift
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

class MStrategyTests: XCTestCase {
    func testBasic() throws {
        let expected = MStrategy(strategyID: "1", title: "LC")
        let encoded: String = try StorageManager.encodeToJSON(expected)
        let actual: MStrategy = try StorageManager.decode(fromJSON: encoded)
        XCTAssertEqual(expected, actual)
    }
}
