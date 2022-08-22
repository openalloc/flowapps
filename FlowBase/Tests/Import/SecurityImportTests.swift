//
//  SecurityImportTests.swift
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

class SecurityImportTests: XCTestCase {
    func testBlankAssetClassSucceeds() throws {
        var model = BaseModel()
        let row: AllocRowed.DecodedRow = ["securityID": "a", "securityAssetID": "  \n "]
        XCTAssertNoThrow(try model.importRow(row, into: \.securities))
    }

    func testInvalidTickerFails() throws {
        var model = BaseModel()
        let expected = "Invalid primary key for security: [SecurityID: '']."
        let row: AllocRowed.DecodedRow = ["securityID": "  \n ", "securityAssetID": "a"]
        XCTAssertThrowsError(try model.importRow(row, into: \.securities)) { error in
            XCTAssertEqual(error as! FlowBaseError, FlowBaseError.validationFailure(expected))
        }
    }

    func testValidSecuritySucceeds() throws {
        let asset = MAsset(assetID: "b", title: "b")
        var model = BaseModel(assets: [asset])
        let row: AllocRowed.DecodedRow = ["securityID": "a", "securityAssetID": "b"]
        _ = try model.importRow(row, into: \.securities)
        XCTAssertEqual([MSecurity(securityID: "a", assetID: "b")], model.securities)
    }

    func testForeignKeyToAssetTableCreates() throws {
        var model = BaseModel()
        XCTAssertEqual(0, model.assets.count)
        let row: AllocRowed.DecodedRow = ["securityID": "def", "securityAssetID": "abc"]
        _ = try model.importRow(row, into: \.securities)
        XCTAssertEqual(1, model.assets.count)
        XCTAssertEqual(MAsset(assetID: "abc", title: nil), model.assets.first!)
    }
}
