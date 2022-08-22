//
//  MHoldingTests.swift
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

class MHoldingTests2: XCTestCase {
    
    func testAssetClasses() throws {
        let equities = "Equities"
        let bonds = "Bonds"
        let spy = MSecurity(securityID: "SPY", assetID: equities)
        let voo = MSecurity(securityID: "VOO", assetID: equities)
        let bnd = MSecurity(securityID: "BND", assetID: bonds)
        let securityMap: SecurityMap = MSecurity.makeAllocMap([spy, voo, bnd])
        let holding1 = MHolding(accountID: "1", securityID: "SPY", lotID: "", shareCount: 1, shareBasis: 1)
        let holding2 = MHolding(accountID: "1", securityID: "VOO", lotID: "", shareCount: 1, shareBasis: 1)
        let holding3 = MHolding(accountID: "1", securityID: "BND", lotID: "", shareCount: 1, shareBasis: 1)
        let expected = [MAsset.normalizeID(bonds), MAsset.normalizeID(equities)]
        let actual = MHolding.getAssetKeys([holding1, holding2, holding3], securityMap: securityMap).map(\.assetNormID)
        XCTAssertEqual(expected, actual)
    }

    
    func testAnyShareCountAllowed() throws {
        for shareCount in [-100, -0.01, 0, 0.01, 100] {
            let holding = MHolding(accountID: "1", securityID: "SPY", lotID: "", shareCount: shareCount, shareBasis: 1) // , sharePrice: 1
            XCTAssertNoThrow(try holding.validate())
        }
    }

    func testPresentValue() throws {
        let securityMap = [MSecurity.Key(securityID: "SPY"): MSecurity(securityID: "SPY", assetID: "X", sharePrice: 7)]
        let holding = MHolding(accountID: "1", securityID: "SPY", lotID: "", shareCount: 13, shareBasis: 200) // , sharePrice: 7
        let expected = 13.0 * 7.0
        let actual = holding.getPresentValue(securityMap)
        XCTAssertEqual(expected, actual)
    }

    func testCostBasis() throws {
        let holding = MHolding(accountID: "1", securityID: "SPY", lotID: "", shareCount: 7, shareBasis: 200) // , sharePrice: 1
        let expected = 7.0 * 200
        let actual = holding.costBasis
        XCTAssertEqual(expected, actual)
    }

    func testGainLoss() throws {
        let securityMap = [MSecurity.Key(securityID: "SPY"): MSecurity(securityID: "SPY", assetID: "X", sharePrice: 13)]
        let holding = MHolding(accountID: "1", securityID: "SPY", lotID: "", shareCount: 7, shareBasis: 200) // , sharePrice: 13
        let expected = 7.0 * (13 - 200)
        let actual = holding.getGainLoss(securityMap)
        XCTAssertEqual(expected, actual)
    }
}
