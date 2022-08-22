//
//  GetLimitPctMapTests.swift
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

@testable import FlowAllocLow

class GetLimitPctMapTests: XCTestCase {
    
    let account1 = MAccount.Key(accountID: "1")
    let account2 = MAccount.Key(accountID: "2")
    let bond = MAsset.Key(assetID: "Bond")
    let lc = MAsset.Key(assetID: "LC")
    let gold = MAsset.Key(assetID: "Gold")
    
    func testNoCaps() throws {
        let actual = getLimitPctMap([])
        let expected = LimitPctMap()
        XCTAssertEqual(expected, actual)
    }

    func testOneSlice() throws {
        let slice = MCap(accountID: "1", assetID: "LC", limitPct: 0.14)
        let capMap = [account1: [slice]]
        let actual = getLimitPctMap(capMap[account1] ?? [])
        let expected = [MAsset.Key(assetID: "LC"): 0.14]
        XCTAssertEqual(expected, actual)
    }

    // not ideal, but import logic should be preventing this
    func testUseLastIfDuplicatesWithinAccount() throws {
        let slice1 = MCap(accountID: "1", assetID: "LC", limitPct: 0.14)
        let slice2 = MCap(accountID: "1", assetID: "LC", limitPct: 0.10)
        let capMap = [account1: [slice1, slice2]]
        let actual = getLimitPctMap(capMap[account1] ?? [])
        let expected = [MAsset.Key(assetID: "LC"): 0.10]
        XCTAssertEqual(expected, actual)
    }

    func testThreeSlicesOverTwoAccounts() throws {
        let slice1 = MCap(accountID: "1", assetID: "LC", limitPct: 0.14)
        let slice2 = MCap(accountID: "1", assetID: "Bond", limitPct: 0.10)
        let slice3 = MCap(accountID: "2", assetID: "Gold", limitPct: 0.15)
        let capMap = [account1: [slice1, slice2], account2: [slice3]]
        let actual1 = getLimitPctMap(capMap[account1] ?? [])
        let expected1 = [lc: 0.14, bond: 0.10]
        XCTAssertEqual(expected1, actual1)
        let actual2 = getLimitPctMap(capMap[account2] ?? [])
        let expected2 = [gold: 0.15]
        XCTAssertEqual(expected2, actual2)
    }
}
