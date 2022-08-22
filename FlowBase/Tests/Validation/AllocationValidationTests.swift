//
//  AllocationValidationTests.swift
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

class AllocationValidationTests: XCTestCase {
    func testKey() throws {
        let actual = MAllocation(strategyID: " A B C ", assetID: " D E F ", targetPct: 1.0).primaryKey
        let expected = MAllocation.Key(strategyID: "A B C", assetID: "D E F")
        XCTAssertEqual(expected, actual)
    }
    
    func testInvalidAssetClassFails() throws {
        for isNew in [true, false] {
            let strategy = MStrategy(strategyID: "1")
            let model = BaseModel(strategies: [strategy])
            let expected = "'' is not a valid asset key."
            let slice = MAllocation(strategyID: "1", assetID: "  \n ", targetPct: 1.0)
            XCTAssertThrowsError(try slice.validate(against: model, isNew: isNew)) { error in
                XCTAssertEqual(error as! FlowBaseError, FlowBaseError.validationFailure(expected))
            }
        }
    }
    
    func testInvalidStrategyFails() throws {
        for isNew in [true, false] {
            let asset = MAsset(assetID: "xxx")
            let model = BaseModel(assets: [asset])
            let expected = "'1' cannot be found in strategies."
            let slice = MAllocation(strategyID: "1", assetID: "xxx", targetPct: 1.0)
            XCTAssertThrowsError(try slice.validate(against: model, isNew: isNew)) { error in
                XCTAssertEqual(error as! FlowBaseError, FlowBaseError.validationFailure(expected))
            }
        }
    }
    
    func testInvalidAssetFails() throws {
        for isNew in [true, false] {
            let strategy = MStrategy(strategyID: "1")
            let model = BaseModel(strategies: [strategy])
            let expected = "'xxx' cannot be found in assets."
            let slice = MAllocation(strategyID: "1", assetID: "xxx", targetPct: 1.0)
            XCTAssertThrowsError(try slice.validate(against: model, isNew: isNew)) { error in
                XCTAssertEqual(error as! FlowBaseError, FlowBaseError.validationFailure(expected))
            }
        }
    }
    
    func testInvalidTargetPercentFails() throws {
        for targetPct in [-1.000, -0.001, 1.001, 2.000] {
            let expected = "'\(targetPct.format3())' is not a valid target percent for allocation."
            let slice = MAllocation(strategyID: "1", assetID: "a", targetPct: targetPct)
            XCTAssertThrowsError(try slice.validate()) { error in
                XCTAssertEqual(error as! FlowBaseError, FlowBaseError.validationFailure(expected))
            }
        }
    }
}
