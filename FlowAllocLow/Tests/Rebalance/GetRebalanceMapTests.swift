//
//  GetRebalanceMapTests.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
//

import XCTest

import FlowBase
import AllocData

@testable import FlowAllocLow

class GetRebalanceMapTests: XCTestCase {
    let modelJSON = """
    {
      "assets": [
        { "title": "Bonds", "assetID": "Bond" },
        { "title": "SC Blend", "assetID": "SCBlend" },
        { "title": "SC Value", "assetID": "SCValue" },
        { "title": "Micro Cap", "assetID": "MicroCap" },
        { "title": "Total Market", "assetID": "TM" }
      ],
      "accounts": [
        {
          "accountID": "1",
          "title": "My First",
          "isTaxable": false,
          "canTrade": true
        }
      ],
      "securities": [
        { "securityAssetID": "Bond", "securityID": "BND", "sharePrice": 1 },
        { "securityAssetID": "SCBlend", "securityID": "VB", "sharePrice": 1 },
        { "securityAssetID": "SCValue", "securityID": "VBR", "sharePrice": 1 },
        { "securityAssetID": "MicroCap", "securityID": "MC", "sharePrice": 1 },
        { "securityAssetID": "TM", "securityID": "VTI", "sharePrice": 1 }
      ],
      "caps": [],
      "holdings": [],
      "updatedAt": 639202449,
      "id": "97A51E12-BEA0-4A70-BC8C-B93F39213025",
      "allocations": [],
      "trackers": [],
      "strategies": [],
      "caps": [],
      "transactions": [],
      "valuationSnapshots": [],
      "valuationAccounts": [],
      "valuationCashflows": [],
      "valuationPositions": [],
    }
    """

    var model: BaseModel!
    var accountPresentValueMap: AccountPresentValueMap!
    var accountHoldingsSummaryMap: AccountAssetHoldingsSummaryMap!

    override func setUpWithError() throws {
        model = try StorageManager.decode(fromJSON: modelJSON)
    }

    func refreshMaps() {
        accountPresentValueMap = MAccount.getAccountPresentValueMap(model.accounts.map(\.primaryKey),
                                                                    model.makeAccountHoldingsMap(),
                                                                    model.makeSecurityMap())
        accountHoldingsSummaryMap = HoldingsSummary.getAccountAssetSummaryMap(model.accounts.map(\.primaryKey),
                                                                              model.makeAccountHoldingsMap(),
                                                                              model.makeSecurityMap())
    }

    let bond = MAsset.Key(assetID: "Bond")
    let account1 = MAccount.Key(accountID: "1")
    let scblend = MAsset.Key(assetID: "SCBlend")
    let scvalue = MAsset.Key(assetID: "SCValue")
    let tm = MAsset.Key(assetID: "TM")
    let microcap = MAsset.Key(assetID: "MicroCap")

    func testRelatedHolding() throws {
        // fulfill SC Blend target by substituting the related SC Value, avoiding the trade

        let vbrHolding1 = MHolding(accountID: "1", securityID: "VBR", lotID: "", shareCount: 100.00, shareBasis: 1)
        model.holdings = [vbrHolding1]

        let allocMap: AssetValueMap = [
            scblend: 0.5,
            bond: 0.5,
        ]

        refreshMaps()
        let holdingsSummaryMap = accountHoldingsSummaryMap[account1]!
        let pv = accountPresentValueMap[account1] ?? 0

        // no substitution (control)
        let mapA = getRebalanceMap(allocMap, holdingsSummaryMap, pv)
        XCTAssertEqual(3, mapA.count)
        XCTAssertEqual(-100, mapA[scvalue])
        XCTAssertEqual(50, mapA[bond])
        XCTAssertEqual(50, mapA[scblend])
    }

    func testRelatedHoldingGrandparent() throws {
        // DO NOT fulfill totalMarket target by substituting the related SC Value, as it's two steps removed

        let vbrHolding1 = MHolding(accountID: "1", securityID: "VBR", lotID: "", shareCount: 100.00, shareBasis: 1)
        model.holdings = [vbrHolding1]

        let allocMap: AssetValueMap = [
            tm: 0.5,
            bond: 0.5,
        ]

        refreshMaps()
        let holdingsSummaryMap = accountHoldingsSummaryMap[account1]!
        let pv = accountPresentValueMap[account1] ?? 0

        // no substitution (control)
        let mapA = getRebalanceMap(allocMap, holdingsSummaryMap, pv)
        XCTAssertEqual(3, mapA.count)
        XCTAssertEqual(-100, mapA[scvalue])
        XCTAssertEqual(50, mapA[bond])
        XCTAssertEqual(50, mapA[tm])
    }

    func testRelatedHoldingPartial() throws {
        // avoid trades entirely by subsituting releated

        let bndHolding = MHolding(accountID: "1", securityID: "BND", lotID: "", shareCount: 30.00, shareBasis: 1)
        let vbHolding = MHolding(accountID: "1", securityID: "VB", lotID: "", shareCount: 20.00, shareBasis: 1)
        let vbrHolding = MHolding(accountID: "1", securityID: "VBR", lotID: "", shareCount: 10.00, shareBasis: 1)
        model.holdings = [bndHolding, vbHolding, vbrHolding]

        let allocMap: AssetValueMap = [
            scblend: 0.5,
            bond: 0.5,
        ]

        refreshMaps()
        let holdingsSummaryMap = accountHoldingsSummaryMap[account1]!
        let pv = accountPresentValueMap[account1] ?? 0

        // no substitution (control)
        let mapA = getRebalanceMap(allocMap, holdingsSummaryMap, pv)
        XCTAssertEqual(2, mapA.count)
        XCTAssertEqual(-10, mapA[scvalue])
        XCTAssertEqual(10, mapA[scblend])
    }

    func testDumpRelated() throws {
        // dump related, as it's not needed (keeping the primary)

        let bndHolding = MHolding(accountID: "1", securityID: "BND", lotID: "", shareCount: 40.00, shareBasis: 1)
        let vbHolding = MHolding(accountID: "1", securityID: "VB", lotID: "", shareCount: 50.00, shareBasis: 1)
        let vbrHolding = MHolding(accountID: "1", securityID: "VBR", lotID: "", shareCount: 10.00, shareBasis: 1)
        model.holdings = [bndHolding, vbHolding, vbrHolding]

        let allocMap: AssetValueMap = [
            scblend: 0.5,
            bond: 0.5,
        ]

        refreshMaps()
        let holdingsSummaryMap = accountHoldingsSummaryMap[account1]!
        let pv = accountPresentValueMap[account1] ?? 0

        // no substitution (control)
        let mapA = getRebalanceMap(allocMap, holdingsSummaryMap, pv)

        XCTAssertEqual(2, mapA.count)
        XCTAssertEqual(10, mapA[bond])
        XCTAssertEqual(-10, mapA[scvalue])
    }

    func testRelatedOnePurchaseTwoSales() throws {
        // avoid trades with two related holdings

        let bndHolding = MHolding(accountID: "1", securityID: "BND", lotID: "", shareCount: 40.00, shareBasis: 1)
        let vbHolding = MHolding(accountID: "1", securityID: "VB", lotID: "", shareCount: 20.00, shareBasis: 1)
        let vbrHolding = MHolding(accountID: "1", securityID: "VBR", lotID: "", shareCount: 10.00, shareBasis: 1)
        let mcHolding = MHolding(accountID: "1", securityID: "MC", lotID: "", shareCount: 10.00, shareBasis: 1)
        model.holdings = [bndHolding, vbHolding, vbrHolding, mcHolding]

        let allocMap: AssetValueMap = [
            scblend: 0.5,
            bond: 0.5,
        ]

        refreshMaps()
        let holdingsSummaryMap = accountHoldingsSummaryMap[account1]!
        let pv = accountPresentValueMap[account1] ?? 0

        // no substitution (control)
        let mapA = getRebalanceMap(allocMap, holdingsSummaryMap, pv)

        XCTAssertEqual(3, mapA.count)
        XCTAssertEqual(-10, mapA[scvalue])
        XCTAssertEqual(-10, mapA[microcap])
        XCTAssertEqual(20, mapA[scblend])
    }

    func testRelatedTwoPurchasesOneSale() throws {
        // avoid trades with two related holdings

        let bndHolding = MHolding(accountID: "1", securityID: "BND", lotID: "", shareCount: 40.00, shareBasis: 1)
        let vbHolding = MHolding(accountID: "1", securityID: "VB", lotID: "", shareCount: 20.00, shareBasis: 1)
        let vbrHolding = MHolding(accountID: "1", securityID: "VBR", lotID: "", shareCount: 10.00, shareBasis: 1)
        let mcHolding = MHolding(accountID: "1", securityID: "MC", lotID: "", shareCount: 10.00, shareBasis: 1)
        model.holdings = [bndHolding, vbHolding, vbrHolding, mcHolding]

        let allocMap: AssetValueMap = [
            scvalue: 0.25,
            microcap: 0.25,
            bond: 0.5,
        ]

        refreshMaps()
        let holdingsSummaryMap = accountHoldingsSummaryMap[account1]!
        let pv = accountPresentValueMap[account1] ?? 0

        // no substitution (control)
        let mapA = getRebalanceMap(allocMap, holdingsSummaryMap, pv)

        XCTAssertEqual(3, mapA.count)
        XCTAssertEqual(10, mapA[scvalue])
        XCTAssertEqual(10, mapA[microcap])
        XCTAssertEqual(-20, mapA[scblend])
    }

    // WARNING: sensitive to sort of asset classes in adjustForRelated
    func testRetainAssetClassWithLargeGain() throws {
        // avoid trades with two related holdings

        let bndHolding = MHolding(accountID: "1", securityID: "BND", lotID: "", shareCount: 40.00, shareBasis: 1)
        let vbHolding = MHolding(accountID: "1", securityID: "VB", lotID: "", shareCount: 30.00, shareBasis: 1)
        let vbrHolding = MHolding(accountID: "1", securityID: "VBR", lotID: "", shareCount: 10.00, shareBasis: 0.1) // large gain; should try to eliminate Microcaps BEFORE SmallCapValue
        let mcHolding = MHolding(accountID: "1", securityID: "MC", lotID: "", shareCount: 10.00, shareBasis: 1.0)
        model.holdings = [bndHolding, vbHolding, vbrHolding, mcHolding]

        let allocMap: AssetValueMap = [
            scblend: 0.5,
            bond: 0.5,
        ]

        refreshMaps()
        let holdingsSummaryMap = accountHoldingsSummaryMap[account1]!
        let pv = accountPresentValueMap[account1] ?? 0

        // no substitution (control)
        let mapA = getRebalanceMap(allocMap, holdingsSummaryMap, pv)

        XCTAssertEqual(4, mapA.count)
        XCTAssertEqual(5, mapA[bond])
        XCTAssertEqual(-10, mapA[scvalue])
        XCTAssertEqual(-10, mapA[microcap])
        XCTAssertEqual(15, mapA[scblend])
    }

    func testExclusionNoProtection() throws {
        let bndHolding = MHolding(accountID: "1", securityID: "BND", lotID: "", shareCount: 40.00, shareBasis: 1)
        let vbHolding = MHolding(accountID: "1", securityID: "VB", lotID: "", shareCount: 20.00, shareBasis: 1)
        let vbrHolding = MHolding(accountID: "1", securityID: "VBR", lotID: "", shareCount: 10.00, shareBasis: 1)
        let mcHolding = MHolding(accountID: "1", securityID: "MC", lotID: "", shareCount: 10.00, shareBasis: 1)
        model.holdings = [bndHolding, vbHolding, vbrHolding, mcHolding]

        let allocMap: AssetValueMap = [
            scvalue: 0.25,
            microcap: 0.25,
            bond: 0.5,
        ]

        refreshMaps()
        let holdingsSummaryMap = accountHoldingsSummaryMap[account1]!
        let pv = accountPresentValueMap[account1] ?? 0

        // no substitution (control)
        let mapA = getRebalanceMap(allocMap, holdingsSummaryMap, pv)

        XCTAssertEqual(3, mapA.count)
        XCTAssertEqual(10, mapA[scvalue]) // will be absorbed into blend
        XCTAssertEqual(10, mapA[microcap]) // will be absorbed into blend
        XCTAssertEqual(-20, mapA[scblend])
    }

    func testExclusionWithProtection() throws {
        // NO substitution if both liquidating and acquiring asset classes in allocation

        let bndHolding = MHolding(accountID: "1", securityID: "BND", lotID: "", shareCount: 40.00, shareBasis: 1)
        let vbHolding = MHolding(accountID: "1", securityID: "VB", lotID: "", shareCount: 20.00, shareBasis: 1)
        let vbrHolding = MHolding(accountID: "1", securityID: "VBR", lotID: "", shareCount: 10.00, shareBasis: 1)
        let mcHolding = MHolding(accountID: "1", securityID: "MC", lotID: "", shareCount: 10.00, shareBasis: 1)
        model.holdings = [bndHolding, vbHolding, vbrHolding, mcHolding]

        let allocMap: AssetValueMap = [
            scblend: 0.25,
            microcap: 0.25,
            bond: 0.5,
        ]

        refreshMaps()
        let holdingsSummaryMap = accountHoldingsSummaryMap[account1]!
        let pv = accountPresentValueMap[account1] ?? 0

        // no substitution (control)
        let mapA = getRebalanceMap(allocMap, holdingsSummaryMap, pv)

        XCTAssertEqual(2, mapA.count)
        XCTAssertEqual(-10, mapA[scvalue])
        XCTAssertEqual(10, mapA[microcap])
    }

    func testExcludeRelatedParentAssetClass() throws {
        // "SCValue" should be absorbed into "SCBlend"
        // totalMarket should NOT be absorbed into "SCBlend" (because it's a parent of it)

        let bndHolding = MHolding(accountID: "1", securityID: "BND", lotID: "", shareCount: 40.00, shareBasis: 1)
        let vtiHolding = MHolding(accountID: "1", securityID: "VTI", lotID: "", shareCount: 10.00, shareBasis: 1)
        let vbHolding = MHolding(accountID: "1", securityID: "VB", lotID: "", shareCount: 20.00, shareBasis: 1)
        let vbrHolding = MHolding(accountID: "1", securityID: "VBR", lotID: "", shareCount: 10.00, shareBasis: 1)
        model.holdings = [bndHolding, vtiHolding, vbHolding, vbrHolding]

        let allocMap: AssetValueMap = [
            scvalue: 0.25,
            tm: 0.25,
            bond: 0.5,
        ]

        refreshMaps()
        let holdingsSummaryMap = accountHoldingsSummaryMap[account1]!
        let pv = accountPresentValueMap[account1] ?? 0

        // no substitution (control)
        let mapA = getRebalanceMap(allocMap, holdingsSummaryMap, pv)

        XCTAssertEqual(3, mapA.count)
        XCTAssertEqual(10, mapA[scvalue])
        XCTAssertEqual(10, mapA[tm])
        XCTAssertEqual(-20, mapA[scblend])
    }
}
