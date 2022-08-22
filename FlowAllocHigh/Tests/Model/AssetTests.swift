//
//  HighAssetTests.swift
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

class HighAssetTests: XCTestCase {
    func testSingleNoParent() throws {
        let original = MAsset(assetID: "Bond", title: "Aggregate Bonds", parentAssetID: nil)
        let encoded: String = try StorageManager.encodeToJSON(original)
        let actual: MAsset = try StorageManager.decode(fromJSON: encoded)
        XCTAssertEqual(original, actual)
    }

    func testSingleWithParent() throws {
        let original = MAsset(assetID: "CorpBond", title: "Corp Bonds", parentAssetID: "Bond")
        let encoded: String = try StorageManager.encodeToJSON(original)
        let actual: MAsset = try StorageManager.decode(fromJSON: encoded)
        XCTAssertEqual(original, actual)
    }
}
