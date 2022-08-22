//
//  AccountValidationTests.swift
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

class AccountValidationTests: XCTestCase {
    func testKey() throws {
        let actual = MAccount(accountID: "  AB C ", title: "b").primaryKey
        let expected = MAccount.Key(accountID: "ab c")
        XCTAssertEqual(expected, actual)
    }
    
    func testMissingIDFails() throws {
        let expected = "Invalid primary key for account: [AccountID: '']."
        XCTAssertThrowsError(try MAccount(accountID: "  \n ", title: "b").validate()) { error in
            XCTAssertEqual(error as! FlowBaseError, FlowBaseError.validationFailure(expected))
        }
    }
    
    func testMissingTitleSucceeds() throws {
        XCTAssertNoThrow(try MAccount(accountID: "a", title: "  \n ").validate())
    }
    
    func testConflictingTitlesInModel() throws {
        for isNew in [true, false] {
            var model = BaseModel()
            
            model.accounts = [MAccount(accountID: "1", title: "a")]
            
            let account = MAccount(accountID: "2", title: "A")
            XCTAssertNoThrow(try account.validate())
            
            let expected = "Conflicting titles 'A'."
            XCTAssertThrowsError(try account.validate(against: model, isNew: isNew)) { error in
                XCTAssertEqual(error as! FlowBaseError, FlowBaseError.validationFailure(expected))
            }
        }
    }
}
