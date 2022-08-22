//
//  FixedAllocationTests1.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import XCTest

import SimpleTree

import FlowAllocLow
import FlowBase
import AllocData

@testable import FlowAllocHigh

class FixedAllocationTests1: XCTestCase {
    let modelJSON = """
    {
      "id": "97A51E12-BEA0-4A70-BC8C-B93F39213025",
      "updatedAt": 639202449,
      "assets": [
        { "title": "LC", "assetID": "LC", "colorCode": 0 },
        { "title": "Bond", "assetID": "Bond", "colorCode": 0 },
        { "title": "Cash", "assetID": "Cash", "colorCode": 0 }
      ],
      "accounts": [
        { "accountID": "1", "isActive": true, "title": "Taxable Fixed", "isTaxable": true, "canTrade": false },
        { "accountID": "2", "isActive": true, "title": "Roth", "isTaxable": false, "canTrade": false },
        { "accountID": "3", "isActive": true, "title": "Taxable", "isTaxable": true, "canTrade": true }
      ],
      "securities": [
        { "securityAssetID": "Cash", "securityID": "Cash", "sharePrice": 1 },
        { "securityAssetID": "LC", "securityID": "SPY", "sharePrice": 1 },
        { "securityAssetID": "Bond", "securityID": "AGG", "sharePrice": 1 }
      ],
      "holdings": [
        {
          "holdingAccountID": "1",
          "shareCount": 100,
          "sharePrice": 1,
          "holdingSecurityID": "SPY",
          "shareBasis": 1
        },
        {
          "holdingAccountID": "1",
          "shareCount": 200,
          "sharePrice": 1,
          "holdingSecurityID": "AGG",
          "shareBasis": 1
        },
        {
          "holdingAccountID": "2",
          "shareCount": 200,
          "sharePrice": 1,
          "holdingSecurityID": "SPY",
          "shareBasis": 1
        },
        {
          "holdingAccountID": "2",
          "shareCount": 100,
          "sharePrice": 1,
          "holdingSecurityID": "AGG",
          "shareBasis": 1
        }
      ],
      "strategies": [
        { "strategyID": "1", "title": "60/40" }
      ],
      "allocations": [
        { "allocationStrategyID": "1", "allocationAssetID": "LC", "targetPct": 0.60 },
        { "allocationStrategyID": "1", "allocationAssetID": "Bond", "targetPct": 0.40 }
      ],
      "trackers": [],
      "caps": [],
      "transactions": [],
      "valuationSnapshots": [],
      "valuationAccounts": [],
      "valuationCashflows": [],
      "valuationPositions": []
    }
    """
    var model: BaseModel!

    let spy = MSecurity.Key(securityID: "SPY")
    let voo = MSecurity.Key(securityID: "VOO")
    let vv = MSecurity.Key(securityID: "VV")
    
    let lc = MAsset.Key(assetID: "LC")
    let bond = MAsset.Key(assetID: "Bond")
    
    let account1 = MAccount.Key(accountID: "1")
    let account2 = MAccount.Key(accountID: "2")

    override func setUpWithError() throws {
        model = try StorageManager.decode(fromJSON: modelJSON)
    }

    func testTwoAccountsTwoAssets() throws {
        // upper limits on what can be "allocated"
        let fixedNetContribMap: AssetValueMap = [lc: 180, bond: 120]
        let fixedAccounts = model.accounts.filter { $0.isActive && !$0.canTrade }
        let accountKeys = fixedAccounts.map(\.primaryKey)
        let accountHoldingsSummary = HoldingsSummary.getAccountAssetSummaryMap(accountKeys, model.makeAccountHoldingsMap(), model.makeSecurityMap())
        let closestRelationsMap: ClosestTargetMap = [:] // TODO:

        let (accountAllocatedMap, accountOrphanedMap) =
            allocateFixed(accounts: fixedAccounts,
                          fixedNetContribMap: fixedNetContribMap,
                          accountHoldingsSummaryMap: accountHoldingsSummary,
                          topRankedTargetMap: closestRelationsMap)

        let fixedTotal = accountHoldingsSummary.flatMap { $0.value }.reduce(0) { $0 + $1.value.presentValue }
        let fixedNetContribTotal = fixedNetContribMap.values.reduce(0) { $0 + $1 }

        let expectedOrphanTotal = fixedTotal - fixedNetContribTotal
        let actualOrphanTotal = accountOrphanedMap.flatMap { $0.value }.reduce(0) { $0 + $1.value }
        XCTAssertEqual(expectedOrphanTotal, actualOrphanTotal)

        let expectedOrphans: AccountAssetAmountMap = [account1: [bond: 80.0], account2: [lc: 120.0, bond: 100.0]]
        let expectedAllocated: AccountAssetAmountMap = [account1: [lc: 100.0, bond: 120.0], account2: [bond: 0.0, lc: 80.0]] // expected 60/40
        XCTAssertEqual(expectedOrphans, accountOrphanedMap)
        XCTAssertEqual(expectedAllocated, accountAllocatedMap)
    }
}
