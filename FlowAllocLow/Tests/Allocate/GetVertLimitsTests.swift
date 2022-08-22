//
//  GetVertLimitsTests.swift
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

class GetVertLimitsTests: XCTestCase {
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
        {
          "accountID": "1",
          "title": "Taxable",
          "isTaxable": false,
          "accountStrategyID": "1"
        },
        { "accountID": "2",
          "title": "Roth",
          "isTaxable": false,
          "accountStrategyID": "1"
        }
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
          "holdingSecurityID": "Cash",
          "shareBasis": 1
        },
        {
          "holdingAccountID": "2",
          "shareCount": 100,
          "sharePrice": 1,
          "holdingSecurityID": "Cash",
          "shareBasis": 1
        }
      ],
      "strategies": [
        {
          "strategyID": "1",
          "title": "60/40"
        },
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

    let lc = MAsset.Key(assetID: "LC")
    let bond = MAsset.Key(assetID: "Bond")
    let strategy1 = MStrategy.Key(strategyID: "1")
    let account1 = MAccount.Key(accountID: "1")
    let account2 = MAccount.Key(accountID: "2")

    override func setUpWithError() throws {
        model = try StorageManager.decode(fromJSON: modelJSON)
    }

    func testBondLimit() throws {
        for (limitPct, expected) in [
            0.0: [account1: [lc: 0.50, bond: 0.00], account2: [lc: 0.3, bond: 0.2]],
            0.1: [account1: [lc: 0.45, bond: 0.05], account2: [lc: 0.3, bond: 0.2]],
            0.2: [account1: [lc: 0.40, bond: 0.10], account2: [lc: 0.3, bond: 0.2]],
            0.3: [account1: [lc: 0.35, bond: 0.15], account2: [lc: 0.3, bond: 0.2]],
            0.4: [account1: [lc: 0.30, bond: 0.20], account2: [lc: 0.3, bond: 0.2]],
            0.5: [account1: [lc: 0.30, bond: 0.20], account2: [lc: 0.3, bond: 0.2]],
        ] {
            let cap1 = MCap(accountID: "1", assetID: "Bond", limitPct: limitPct)
            model.caps = [cap1]
            // model.settings.strategyID = "1"
            let ax = LowContext(model, strategyKey: strategy1)
            let actual = ax.accountUserVertLimitMap
            XCTAssertEqual(expected, actual, "for limitPct=\(limitPct)")
        }
    }

    func testGetUserVertLimits() throws {
        let allocs = [
            AssetValue(lc, 0.6),
            AssetValue(bond, 0.4),
        ]
        let allocMap = AssetValue.getAssetValueMap(from: allocs)
        let limitPctMap = [bond: 0.0]
        let expected = [lc: 0.5, bond: 0.0]
        let actual = try getUserVertLimits(allocMap: allocMap,
                                           limitPctMap: limitPctMap,
                                           accountCapacity: 0.5)
        XCTAssertEqual(expected, actual)
    }
}
