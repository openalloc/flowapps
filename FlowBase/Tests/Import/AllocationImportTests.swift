//
//  AllocationImportTests.swift
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

class AllocationImportTests: XCTestCase {
    func testInvalidAssetClassFails() throws {
        var model = BaseModel()
        let expected = "Invalid primary key for allocation: [StrategyID: '1', AssetID: '']."
        let allocation = MAllocation(strategyID: "1", assetID: "  \n ", targetPct: 1.0)
        XCTAssertThrowsError(try model.importRecord(allocation, into: \.allocations)) { error in
            XCTAssertEqual(error as! FlowBaseError, FlowBaseError.validationFailure(expected))
        }
    }

    func testInvalidTargetPercentFails() throws {
        var model = BaseModel()
        let expected = "'1.001' is not a valid target percent for allocation."
        let allocation = MAllocation(strategyID: "1", assetID: "LC", targetPct: 1.001)
        XCTAssertThrowsError(try model.importRecord(allocation, into: \.allocations)) { error in
            XCTAssertEqual(error as! FlowBaseError, FlowBaseError.validationFailure(expected))
        }
    }

    func testValidAllocationSucceeds() throws {
        let asset = MAsset(assetID: "a", title: "a")
        let strategy = MStrategy(strategyID: "1", title: "60/40")
        var model = BaseModel(strategies: [strategy], assets: [asset])
        let allocation = MAllocation(strategyID: "1", assetID: "a", targetPct: 1.0)
        _ = try model.importRecord(allocation, into: \.allocations)
        XCTAssertEqual(1, model.allocations.count)
        XCTAssertEqual(allocation.strategyID, model.makeStrategyMap()[model.allocations[0].strategyKey]?.strategyID)
        XCTAssertEqual(allocation.assetID, model.makeAssetMap()[model.allocations[0].assetKey]?.assetID)
        XCTAssertEqual(allocation.targetPct, model.allocations[0].targetPct)
    }

    func testReplaceExisting() throws {
        let asset = MAsset(assetID: "A", title: "A")
        let strategy = MStrategy(strategyID: "1", title: "60/40")
        var model = BaseModel(strategies: [strategy], assets: [asset])
        let allocation1 = MAllocation(strategyID: "1", assetID: "A", targetPct: 0.1)
        let allocation2 = MAllocation(strategyID: "1", assetID: "A", targetPct: 0.2)
        _ = try model.importRecord(allocation1, into: \.allocations)
        XCTAssertEqual(1, model.allocations.count)
        XCTAssertEqual(allocation1.strategyID, model.makeStrategyMap()[model.allocations[0].strategyKey]?.strategyID)
        XCTAssertEqual(allocation1.assetID, model.makeAssetMap()[model.allocations[0].assetKey]?.assetID)
        XCTAssertEqual(allocation1.targetPct, model.allocations[0].targetPct)
        _ = try model.importRecord(allocation2, into: \.allocations)
        XCTAssertEqual(1, model.allocations.count)
        XCTAssertEqual(allocation2.strategyID, model.makeStrategyMap()[model.allocations[0].strategyKey]?.strategyID)
        XCTAssertEqual(allocation2.assetID, model.makeAssetMap()[model.allocations[0].assetKey]?.assetID)
        XCTAssertEqual(allocation2.targetPct, model.allocations[0].targetPct)
    }

    func testForeignKeyToAssetTableCreated() throws {
        var model = BaseModel()
        XCTAssertEqual(0, model.assets.count)
        let row: AllocRowed.DecodedRow = ["allocationStrategyID": "1", "allocationAssetID": "abc", "targetPct": 1.0]
        _ = try model.importRow(row, into: \.allocations)
        XCTAssertEqual(1, model.assets.count)
        XCTAssertEqual(MAsset(assetID: "abc", title: nil), model.assets.first!)
    }

    func testForeignKeyToStrategyTableCreated() throws {
        let asset = MAsset(assetID: "A", title: "A")
        // let strategy = MStrategy(strategyID: "1", title: "60/40")
        var model = BaseModel(strategies: [], assets: [asset])
        XCTAssertEqual(0, model.strategies.count)
        let row: AllocRowed.DecodedRow = ["allocationStrategyID": "X", "allocationAssetID": "A", "targetPct": 1.0]
        _ = try model.importRow(row, into: \.allocations)
        XCTAssertEqual(1, model.strategies.count)
        XCTAssertEqual(MStrategy(strategyID: "X", title: nil), model.strategies.first!)
    }
}
