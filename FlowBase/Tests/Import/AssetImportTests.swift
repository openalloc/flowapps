//
//  AssetImportTests.swift
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

class AssetImportTests: XCTestCase {
    func testInvalidAssetFails() throws {
        var model = BaseModel()
        let expected = "Invalid primary key for asset: [AssetID: '']."
        let asset = MAsset(assetID: "  \n ", title: "a")
        XCTAssertThrowsError(try model.importRecord(asset, into: \.assets)) { error in
            XCTAssertEqual(error as! FlowBaseError, FlowBaseError.validationFailure(expected))
        }
    }

    func testInvalidTitleFails() throws {
        var model = BaseModel()
        let expected = "'' is not a valid title for asset."
        let asset = MAsset(assetID: "LC", title: "  \n ")
        XCTAssertThrowsError(try model.importRecord(asset, into: \.assets)) { error in
            XCTAssertEqual(error as! FlowBaseError, FlowBaseError.validationFailure(expected))
        }
    }

    func testValidAssetSucceeds() throws {
        var model = BaseModel()
        let asset = MAsset(assetID: "b", title: "a")
        _ = try model.importRecord(asset, into: \.assets)
        XCTAssertEqual([MAsset(assetID: "b", title: "a")], model.assets)
    }
}
