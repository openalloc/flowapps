//
//  AssetImportTest.swift
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

import FlowAllocLow
import FlowBase
import AllocData

@testable import FlowAllocHigh

class AssetImportTest: XCTestCase {
    func testReplaceExistingNoParents() throws {
        var model = BaseModel()
        let asset1 = MAsset(assetID: "A", title: "1")
        let asset2 = MAsset(assetID: "A", title: "2")
        let expected1 = MAsset(assetID: "A", title: "1")
        let expected2 = MAsset(assetID: "A", title: "2")
        _ = try model.importRecord(asset1, into: \.assets)
        XCTAssertEqual([expected1], model.assets)
        _ = try model.importRecord(asset2, into: \.assets)
        XCTAssertEqual([expected2], model.assets)
    }

    func testFailReplaceDueToCircularReference() throws {
        let expected = "Circular reference not allowed."
        var model = BaseModel()
        let grandparent = MAsset(assetID: "a", title: "A")
        let grandExpected = MAsset(assetID: "a", title: "A")
        _ = try model.importRecord(grandparent, into: \.assets)
        let parent = MAsset(assetID: "b", title: "B", parentAssetID: grandparent.assetID)
        let parentExpected = MAsset(assetID: "b", title: "B", parentAssetID: grandExpected.assetID)
        _ = try model.importRecord(parent, into: \.assets)
        let me = MAsset(assetID: "c", title: "C", parentAssetID: parent.assetID)
        let meExpected = MAsset(assetID: "c", title: "C", parentAssetID: parentExpected.assetID)
        _ = try model.importRecord(me, into: \.assets)
        XCTAssertEqual([grandExpected, parentExpected, meExpected], model.assets)
        let grandparent2 = MAsset(assetID: "a", title: "A2", parentAssetID: me.assetID)
        XCTAssertThrowsError(try model.importRecord(grandparent2, into: \.assets)) { error in
            XCTAssertEqual(error as! FlowBaseError, FlowBaseError.validationFailure(expected))
        }
    }

    func testCannotReferToItself() throws {
        var model = BaseModel()
        let expected = "Circular reference not allowed."
        let parent = MAsset(assetID: "a", title: "b")
        _ = try model.importRecord(parent, into: \.assets)
        let asset = MAsset(assetID: "a", title: "c", parentAssetID: parent.assetID)
        XCTAssertThrowsError(try model.importRecord(asset, into: \.assets)) { error in
            XCTAssertEqual(error as! FlowBaseError, FlowBaseError.validationFailure(expected))
        }
    }

    func testTwoLevelCircularFailsFromSelf() throws {
        var model = BaseModel()
        let expected = "Circular reference not allowed."
        let grandparent = MAsset(assetID: "a", title: "A")
        XCTAssertNoThrow(try model.importRecord(grandparent, into: \.assets))
        let parent = MAsset(assetID: "b", title: "B", parentAssetID: grandparent.assetID)
        XCTAssertNoThrow(try model.importRecord(parent, into: \.assets))
        let asset = MAsset(assetID: "a", title: "AA", parentAssetID: parent.assetID)
        XCTAssertThrowsError(try model.importRecord(asset, into: \.assets)) { error in
            XCTAssertEqual(error as! FlowBaseError, FlowBaseError.validationFailure(expected))
        }
    }

    func testTwoLevelCircularFailsFromAncestor() throws {
        var model = BaseModel()
        let expected = "Circular reference not allowed."
        let greatgrandparent = MAsset(assetID: "a", title: "A")
        XCTAssertNoThrow(try model.importRecord(greatgrandparent, into: \.assets))
        let grandparent = MAsset(assetID: "b", title: "B", parentAssetID: greatgrandparent.assetID)
        XCTAssertNoThrow(try model.importRecord(grandparent, into: \.assets))
        let parent = MAsset(assetID: "a", title: "AA", parentAssetID: grandparent.assetID)
        XCTAssertThrowsError(try model.importRecord(parent, into: \.assets)) { error in
            XCTAssertEqual(error as! FlowBaseError, FlowBaseError.validationFailure(expected))
        }
    }

    func testMissingParentAssetClassSucceeds() throws {
        var model = BaseModel()
        let asset = MAsset(assetID: "c", title: "C", parentAssetID: "TITANIC")
        XCTAssertEqual(0, model.assets.count)
        XCTAssertNoThrow(try model.importRecord(asset, into: \.assets))
        XCTAssertEqual(2, model.assets.count)
    }
}
