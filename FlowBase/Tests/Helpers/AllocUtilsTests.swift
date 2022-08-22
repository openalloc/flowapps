//
//  AllocUtilsTests.swift
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

@testable import FlowBase

class AllocUtilsTests: XCTestCase {
    func testGetOrderedByWithExtra() throws {
        let allocMap = [MAsset.Key(assetID: "a"): 0.25,
                        MAsset.Key(assetID: "b"): 0.45,
                        MAsset.Key(assetID: "c"): 0.20,
                        MAsset.Key(assetID: "d"): 0.10,
                        MAsset.Key(assetID: "e"): 0.05]
        let assetKeys = [MAsset.Key(assetID: "d"),
                         MAsset.Key(assetID: "a"),
                         MAsset.Key(assetID: "b")]
        let expected = [
            AssetValue(MAsset.Key(assetID: "d"), 0.10),
            AssetValue(MAsset.Key(assetID: "a"), 0.25),
            AssetValue(MAsset.Key(assetID: "b"), 0.45),
            AssetValue(MAsset.Key(assetID: "c"), 0.20),
            AssetValue(MAsset.Key(assetID: "e"), 0.05),
        ]
        let actual = AssetValue.getAssetValues(from: allocMap, orderBy: assetKeys)
        XCTAssertEqual(expected, actual)
    }

    func testGetAllocationMap() throws {
        let expected = [MAsset.Key(assetID: "A"): 0.5]
        let actual = AssetValue.getAssetValueMap(from: [AssetValue(MAsset.Key(assetID: "A"), 0.5)])
        XCTAssertEqual(expected, actual)
    }

    func testSumOfSlices() throws {
        let expected = 0.75
        let actual = AssetValue.sumOf([AssetValue(MAsset.Key(assetID: "A"), 0.5), AssetValue(MAsset.Key(assetID: "B"), 0.25)])
        XCTAssertEqual(expected, actual)
    }

    func testSumOfMap() throws {
        let expected = 0.75
        let map = [MAsset.Key(assetID: "A"): 0.5, MAsset.Key(assetID: "B"): 0.25]
        let actual = AssetValue.sumOf(map)
        XCTAssertEqual(expected, actual)
    }

    func testValidateFailsWithBlankAssetClass() throws {
        let map: AssetValueMap = [MAsset.Key(assetID: "A"): 0.5, MAsset.Key(assetID: ""): 0.5]
        XCTAssertThrowsError(try AssetValue.validateAllocMap(map)) { error in
            XCTAssertEqual(error as! FlowBaseError, FlowBaseError.validationFailure("Asset classes must not be blank."))
        }
    }

    func testValidateFailsWithDuplicateAssetClasses() throws {
        let slices: [AssetValue] = [AssetValue(MAsset.Key(assetID: "A"), 0.5), AssetValue(MAsset.Key(assetID: "A"), 0.25)]
        XCTAssertThrowsError(try AssetValue.validateAllocs(slices)) { error in
            XCTAssertEqual(error as! FlowBaseError, FlowBaseError.validationFailure("Asset classes must be unique."))
        }
    }

    func testValidateFailsWithNegativeTargetPct() throws {
        let map: AssetValueMap = [MAsset.Key(assetID: "A"): 0.5, MAsset.Key(assetID: "B"): -0.25]
        XCTAssertThrowsError(try AssetValue.validateAllocMap(map)) { error in
            XCTAssertEqual(error as! FlowBaseError, FlowBaseError.validationFailure("Each slice must be >= 0."))
        }
    }

    func testValidateFailsSumNot1() throws {
        let map: AssetValueMap = [MAsset.Key(assetID: "A"): 0.001, MAsset.Key(assetID: "B"): 0.998]
        XCTAssertThrowsError(try AssetValue.validateAllocMap(map)) { error in
            XCTAssertEqual(error as! FlowBaseError, FlowBaseError.validationFailure("Sum of slices must be 1."))
        }
    }

    func testValidateSucceeds() throws {
        let map: AssetValueMap = [MAsset.Key(assetID: "A"): 0.002, MAsset.Key(assetID: "B"): 0.998]
        XCTAssertNoThrow(try AssetValue.validateAllocMap(map))
    }

    func testNormalize() throws {
        let map: AssetValueMap = [MAsset.Key(assetID: "A"): 1, MAsset.Key(assetID: "B"): 3, MAsset.Key(assetID: "C"): -3]
        let expected = [MAsset.Key(assetID: "A"): 0.25, MAsset.Key(assetID: "B"): 0.75, MAsset.Key(assetID: "C"): 0]
        let actual = try AssetValue.normalize(map)
        XCTAssertEqual(expected, actual)
    }

    func testNormalizeFailsWithNoPositiveSlices() throws {
        let map: AssetValueMap = [MAsset.Key(assetID: "A"): 0, MAsset.Key(assetID: "B"): 0, MAsset.Key(assetID: "C"): -3]
        XCTAssertThrowsError(try AssetValue.normalize(map)) { error in
            XCTAssertEqual(error as! FlowBaseError, FlowBaseError.validationFailure("Sum of slices must be >0."))
        }
    }

    func testNormalizeFailsWithNoSlices() throws {
        let map: AssetValueMap = [:]
        XCTAssertThrowsError(try AssetValue.normalize(map)) { error in
            XCTAssertEqual(error as! FlowBaseError, FlowBaseError.validationFailure("Sum of slices must be >0."))
        }
    }

    func testNormalizeWithOneSlice() throws {
        let map: AssetValueMap = [MAsset.Key(assetID: "A"): 1_000_000]
        let expected = [MAsset.Key(assetID: "A"): 1.0]
        let actual = try AssetValue.normalize(map)
        XCTAssertEqual(expected, actual)
    }
}
