//
//  MAllocationTests.swift
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

class MAllocationTests: XCTestCase {
    func testBasic() throws {
        let strategy = MStrategy(strategyID: "1")
        let asset = MAsset(assetID: "LC")
        let expected = MAllocation(strategyID: strategy.strategyID, assetID: asset.assetID, targetPct: 0.32)
        let encoded: String = try StorageManager.encodeToJSON(expected)
        let actual: MAllocation = try StorageManager.decode(fromJSON: encoded)
        XCTAssertEqual(expected, actual)
    }
}
