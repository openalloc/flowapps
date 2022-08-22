//
//  HoldingsSummaryRollupTests.swift
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

class HoldingsSummaryRollupTests: XCTestCase {
    let acLCBlend  = MAsset.Key(assetID: "LC Blend")
    let acLCGrowth = MAsset.Key(assetID: "LC Growth")
    let acSmallCap = MAsset.Key(assetID: "Small Cap")
    let acSCGrowth = MAsset.Key(assetID: "SC Growth")
    let acSCValue  = MAsset.Key(assetID: "SC Value")
    let acMicrocap = MAsset.Key(assetID: "Microcap")

    let account1 = MAccount.Key(accountID: "1")
    let account2 = MAccount.Key(accountID: "2")

    var rollupMap: RollupMap!

    override func setUp() {
        rollupMap = [
            acLCBlend: [acLCGrowth],
            acSmallCap: [acMicrocap, acSCGrowth, acSCValue],
        ]
    }

    func testRollup() throws {
        var summaryMap: AssetHoldingsSummaryMap = [
            acLCBlend: HoldingsSummary(presentValue: 1, costBasis: 3, count: 5),
            acLCGrowth: HoldingsSummary(presentValue: 7, costBasis: 11, count: 13),
            acSmallCap: HoldingsSummary(presentValue: 17, costBasis: 19, count: 23),
            acSCGrowth: HoldingsSummary(presentValue: 29, costBasis: 31, count: 37),
            acSCValue: HoldingsSummary(presentValue: 41, costBasis: 43, count: 47),
            acMicrocap: HoldingsSummary(presentValue: 51, costBasis: 53, count: 57),
        ]

        let expected: AssetHoldingsSummaryMap = [
            acSmallCap: HoldingsSummary(presentValue: 17 + 29 + 41 + 51, costBasis: 19 + 31 + 43 + 53, count: 23 + 37 + 47 + 57),
            acLCBlend: HoldingsSummary(presentValue: 1 + 7, costBasis: 3 + 11, count: 5 + 13),
        ]
        HoldingsSummary.rollup(&summaryMap, rollupMap)
        XCTAssertEqual(expected, summaryMap)
    }

    func testAccountRollup() throws {
        var accountSummaryMap: AccountAssetHoldingsSummaryMap = [
            account1: [
                acLCBlend: HoldingsSummary(presentValue: 1, costBasis: 3, count: 5),
                acLCGrowth: HoldingsSummary(presentValue: 7, costBasis: 11, count: 13),
                acSmallCap: HoldingsSummary(presentValue: 17, costBasis: 19, count: 23),
            ],
            account2: [
                acSmallCap: HoldingsSummary(presentValue: 29, costBasis: 31, count: 37),
                acSCValue: HoldingsSummary(presentValue: 41, costBasis: 43, count: 47),
                acMicrocap: HoldingsSummary(presentValue: 51, costBasis: 53, count: 57),
            ],
        ]

        let expected: AccountAssetHoldingsSummaryMap = [
            account1: [acSmallCap: HoldingsSummary(presentValue: 17, costBasis: 19, count: 23),
                  acLCBlend: HoldingsSummary(presentValue: 1 + 7, costBasis: 3 + 11, count: 5 + 13)],
            account2: [acSmallCap: HoldingsSummary(presentValue: 29 + 41 + 51, costBasis: 31 + 43 + 53, count: 37 + 47 + 57)],
        ]
        HoldingsSummary.rollup(&accountSummaryMap, rollupMap)
        XCTAssertEqual(expected, accountSummaryMap)
    }
}
