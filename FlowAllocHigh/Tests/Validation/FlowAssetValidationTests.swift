//
//  FlowAssetValidationTests.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import XCTest

import FlowAllocLow
import FlowBase
import AllocData

@testable import FlowAllocHigh

class FlowAssetValidationTests: XCTestCase {
    func testBlankParentAssetClassSucceeds() throws {
        let asset = MAsset(assetID: "c", title: "C", parentAssetID: "")
        XCTAssertNoThrow(try asset.validate())
    }
}
