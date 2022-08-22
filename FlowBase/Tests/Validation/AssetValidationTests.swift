//
//  AssetValidationTests.swift
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

class AssetValidationTests: XCTestCase {
    func testKey() throws {
        let actual = MAsset(assetID: " A B C ", title: "a").primaryKey
        let expected = MAsset.Key(assetID: "a b c")
        XCTAssertEqual(expected, actual)
    }

    func testMissingAssetClassFails() throws {
        let expected = "Invalid primary key for asset: [AssetID: '']."
        let asset = MAsset(assetID: "  \n ", title: "a")
        XCTAssertThrowsError(try asset.validate()) { error in
            XCTAssertEqual(error as! FlowBaseError, FlowBaseError.validationFailure(expected))
        }
    }

    func testMissingTitleFails() throws {
        let expected = "'' is not a valid title for asset."
        let asset = MAsset(assetID: "a", title: "  \n ")
        XCTAssertThrowsError(try asset.validate()) { error in
            XCTAssertEqual(error as! FlowBaseError, FlowBaseError.validationFailure(expected))
        }
    }
}
