//
//  ReconcileCashflowTests.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

@testable import FlowWorthLib
import XCTest

import AllocData

import FlowBase

class ReconcileCashflowTests: XCTestCase {
    var df: ISO8601DateFormatter!
    var timestamp1: Date!
    var timestamp2: Date!
    
    override func setUpWithError() throws {
        df = ISO8601DateFormatter()
        timestamp1 = df.date(from: "2020-06-01T12:00:00Z")!
        timestamp2 = df.date(from: "2020-06-01T13:00:00Z")! // one hour later
    }
    
    func testGenerateFakeCashflowForMissingBonds() throws {
        let reconcileMap: AccountAssetValueMap = [AccountAssetKey(accountID: "1", assetID: "Bond"): 80]
        let accountMap: AccountMap = [MAccount.Key(accountID: "1"): MAccount(accountID: "1")]
        let assetMap: AssetMap = [MAsset.Key(assetID: "Bond"): MAsset(assetID: "Bond")]
        let actual =  MValuationCashflow.makeCashflow(from: reconcileMap,
                                                      timestamp: timestamp1,
                                                      accountMap: accountMap,
                                                      assetMap: assetMap)
        let expected: [MValuationCashflow] = [MValuationCashflow(transactedAt: timestamp1, accountID: "1", assetID: "Bond", amount: 80)]
        XCTAssertEqual(expected, actual)
    }
    
    func testIgnoreMissingCash() throws {
        let reconcileMap: AccountAssetValueMap = [AccountAssetKey(accountID: "1", assetID: "Cash"): 80]
        let accountMap: AccountMap = [MAccount.Key(accountID: "1"): MAccount(accountID: "1")]
        let assetMap: AssetMap = [MAsset.Key(assetID: "Cash"): MAsset(assetID: "Cash")]
        let actual =  MValuationCashflow.makeCashflow(from: reconcileMap,
                                                      timestamp: timestamp1,
                                                      accountMap: accountMap,
                                                      assetMap: assetMap)
        let expected: [MValuationCashflow] = []
        XCTAssertEqual(expected, actual)
    }
}
