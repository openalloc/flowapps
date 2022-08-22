//
//  ContribMapUtilsTests.swift
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
import FlowXCT

@testable import FlowAllocHigh

class ContribMapUtilsTests: XCTestCase {
    func testGetFixedContribMap() throws {
        let combinedContribMap = [MAsset.Key(assetID: "LC"): 500.0, MAsset.Key(assetID: "Bond"): 300.0, MAsset.Key(assetID: "Gold"): 10.0]
        let fixedRawValueMap = [MAsset.Key(assetID: "LC"): 700.0, MAsset.Key(assetID: "Bond"): 100.0, MAsset.Key(assetID: "IntlBond"): 200.0]
        let actual = getFixedContribMap(combinedContribMap: combinedContribMap, fixedValueMap: fixedRawValueMap)
        let expected = [MAsset.Key(assetID: "LC"): 500.0, MAsset.Key(assetID: "Bond"): 100.0]
        XCTAssertEqual(expected, actual, accuracy: 0.0001)
    }

    func testGetFixedSurplusMap() throws {
        let fixedRawValueMap = [MAsset.Key(assetID: "LC"): 800.0, MAsset.Key(assetID: "Bond"): 100.0, MAsset.Key(assetID: "Gold"): 200.0]
        let combinedRawTotal = 1200.0
        let netAllocMap = [MAsset.Key(assetID: "LC"): 0.6, MAsset.Key(assetID: "Bond"): 0.4]
        let actual = getFixedSurplusMap(fixedRawValueMap: fixedRawValueMap,
                                        combinedRawTotal: combinedRawTotal,
                                        netAllocMap: netAllocMap)
        let expected = [MAsset.Key(assetID: "LC"): 800 - 1200 * 0.6]
        XCTAssertEqual(expected, actual, accuracy: 0.0001)
    }

    func testGetNetCombinedTotalNoLimiter() throws {
        let fixedRawValueMap = [MAsset.Key(assetID: "LC"): 300.0, MAsset.Key(assetID: "Bond"): 100.0]
        let variableContribTotal = 200.0
        let netAllocMap = [MAsset.Key(assetID: "LC"): 0.6, MAsset.Key(assetID: "Bond"): 0.4]
        let total = getNetCombinedTotal(fixedValueMap: fixedRawValueMap,
                                        variableContribTotal: variableContribTotal,
                                        netAllocMap: netAllocMap)
        XCTAssertEqual(600, total, accuracy: 0.1)

        let expected = [MAsset.Key(assetID: "LC"): (400.0 + 200.0) * 0.6, MAsset.Key(assetID: "Bond"): (400.0 + 200.0) * 0.4]
        let actual = AssetValue.distribute(value: total, allocationMap: netAllocMap)
        XCTAssertEqual(expected, actual, accuracy: 0.1)
    }

    func testGetNetCombinedTotalLimiter() throws {
        let fixedRawValueMap = [MAsset.Key(assetID: "LC"): 90.0, MAsset.Key(assetID: "Bond"): 10.0]
        let variableContribTotal = 10.0
        let netAllocMap = [MAsset.Key(assetID: "LC"): 0.6, MAsset.Key(assetID: "Bond"): 0.4]
        let total = getNetCombinedTotal(fixedValueMap: fixedRawValueMap,
                                        variableContribTotal: variableContribTotal,
                                        netAllocMap: netAllocMap)
        XCTAssertEqual(50, total, accuracy: 0.1)

        let expected = [MAsset.Key(assetID: "LC"): 30.0, MAsset.Key(assetID: "Bond"): 20.0]
        let actual = AssetValue.distribute(value: total, allocationMap: netAllocMap)
        XCTAssertEqual(expected, actual, accuracy: 0.1)
    }

    func testGetFixedContribSum() throws {
        let fixedRawValueMap = [MAsset.Key(assetID: "LC"): 90.0, MAsset.Key(assetID: "Gold"): 100.0, MAsset.Key(assetID: "IntlBond"): 30.0]
        let netAllocMap = [MAsset.Key(assetID: "LC"): 0.6, MAsset.Key(assetID: "Gold"): 0.05, MAsset.Key(assetID: "Bond"): 0.35]
        let actual = getFixedContribSum(fixedValueMap: fixedRawValueMap,
                                        combinedTotal: 1000,
                                        netAllocMap: netAllocMap)
        let expected = 90.0 + (1000 * 0.05)
        XCTAssertEqual(expected, actual, accuracy: 0.0001)
    }
}
