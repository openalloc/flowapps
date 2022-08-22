//
//  StrategyImportTests.swift
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

class StrategyImportTests: XCTestCase {
    func testIgnoreBlankTitle() throws {
        var model = BaseModel()
        let strategy = MStrategy(strategyID: "1", title: "  \n ")
        XCTAssertNoThrow(try model.importRecord(strategy, into: \.strategies))
    }

    func testValidStrategySucceeds() throws {
        let asset = MAsset(assetID: "a", title: "a")
        var model = BaseModel(assets: [asset])
        let strategy = MStrategy(strategyID: "1", title: "a")
        _ = try model.importRecord(strategy, into: \.strategies)
        XCTAssertEqual([MStrategy(strategyID: "1", title: "a")], model.strategies)
    }

    func testReplaceExisting() throws {
        var model = BaseModel()

        let strategy1 = MStrategy(strategyID: "1", title: "A")
        _ = try model.importRecord(strategy1, into: \.strategies)
        XCTAssertEqual([MStrategy(strategyID: "1", title: "A")], model.strategies)

        let strategy2 = MStrategy(strategyID: "1", title: "B")
        _ = try model.importRecord(strategy2, into: \.strategies)
        XCTAssertEqual([MStrategy(strategyID: "1", title: "B")], model.strategies)
    }
}
