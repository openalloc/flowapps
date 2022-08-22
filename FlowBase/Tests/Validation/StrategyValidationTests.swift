//
//  StrategyValidationTests.swift
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

class StrategyValidationTests: XCTestCase {
    func testKey() throws {
        let actual = MStrategy(strategyID: " A B C ", title: " D E F ").primaryKey
        let expected = MStrategy.Key(strategyID: "a b c")
        XCTAssertEqual(expected, actual)
    }
    
    func testTolerateMissingTitle() throws {
        let strategy = MStrategy(strategyID: "1", title: "  \n ")
        XCTAssertNoThrow(try strategy.validate())
    }
    
    func testMissingIDFails() throws {
        let expected = "Invalid primary key for strategy: [StrategyID: '']."
        XCTAssertThrowsError(try MStrategy(strategyID: "  \n ", title: "b").validate()) { error in
            XCTAssertEqual(error as! FlowBaseError, FlowBaseError.validationFailure(expected))
        }
    }
    
    func testConflictingTitlesInModel() throws {
        for isNew in [true, false] {
            var model = BaseModel()
            
            model.strategies = [MStrategy(strategyID: "1", title: "a")]
            
            let A = MStrategy(strategyID: "2", title: "A")
            XCTAssertNoThrow(try A.validate())
            
            let expected = "Conflicting titles 'A'."
            XCTAssertThrowsError(try A.validate(against: model, isNew: isNew)) { error in
                XCTAssertEqual(error as! FlowBaseError, FlowBaseError.validationFailure(expected))
            }
        }
    }
}
