//
//  MAssetTests.swift
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

class MAssetTests: XCTestCase {
    
    let a = MAsset.Key(assetID: "a")
    let b = MAsset.Key(assetID: "b")
    let c = MAsset.Key(assetID: "c")
    let d = MAsset.Key(assetID: "d")
    let e = MAsset.Key(assetID: "e")
    let x = MAsset.Key(assetID: "x")

    func testGetAssetKeys() {
        let source = [b, a, a, e, d]
        let target = [a, c, x, b] // x should be ignored
        let expected = [a, a, b, e, d]
        let actual = getAssetKeys(source, orderBy: target)
        XCTAssertEqual(expected, actual)
    }
}
