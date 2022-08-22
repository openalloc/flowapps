//
//  AccountTableTests.swift
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

class AccountTableTests: XCTestCase {
    let modelJSON = """
    {
      "assets": [
        { "title": "Bonds", "assetID": MAsset.Key(assetID: "Bond"), "colorCode": 0 },
        { "title": "SC Blend", "assetID": "SCBlend", "colorCode": 0 },
        { "title": "SC Value", "assetID": "scvalue", "colorCode": 0 },
        { "title": "Micro Cap", "assetID": "microcap", "colorCode": 0 },
        { "title": "Total Market", "assetID": "total", "colorCode": 0 }
      ],
      "accounts": [
        {
          "accountID": "1",
          "isActive": true,
          "title": "My First",
          "isTaxable": false,
          "canTrade": true
        }
      ],
      "securities": [
        { "assetID": "Bond", "securityID": "BND", "sharePrice": 1 },
        { "assetID": "SCBlend", "securityID": "VB", "sharePrice": 1 },
        { "assetID": "SCValue", "securityID": "VBR", "sharePrice": 1 },
        { "assetID": "MicroCap", "securityID": "MC", "sharePrice": 1 },
        { "assetID": "Total", "securityID": "VTI", "sharePrice": 1 }
      ],
      "caps": [],
      "holdings": [],
      "updatedAt": 639202449.99311101,
      "allocations": [],
      "transactions": []
    }
    """

    var model: BaseModel!
    var account: MAccount!
    var accountPresentValueMap: AccountPresentValueMap!
    var accountHoldingsSummaryMap: AccountAssetHoldingsSummaryMap!

    override func setUpWithError() throws {
        model = try StorageManager.decode(fromJSON: modelJSON)
        account = model.accounts.first!
    }

    func refreshMaps() {
        accountPresentValueMap = MAccount.getAccountPresentValueMap(model.accounts.map(\.primaryKey),
                                                                    model.makeAccountHoldingsMap(),
                                                                    model.makeSecurityMap())
        accountHoldingsSummaryMap = HoldingsSummary.getAccountAssetSummaryMap(model.accounts.map(\.primaryKey),
                                                                              model.makeAccountHoldingsMap(),
                                                                              model.makeSecurityMap())
    }
}
