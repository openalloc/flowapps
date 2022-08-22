//
//  LiquidateHoldingTests.swift
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

class LiquidateHoldingTests: XCTestCase {
    var securityMap: SecurityMap!

    override func setUp() {
        securityMap = MSecurity.makeAllocMap( [
            MSecurity(securityID: "BND", sharePrice: 1),
            MSecurity(securityID: "AGG", sharePrice: 1)])
    }

    func testFullWithGain() throws {
        let h = MHolding(accountID: "1", securityID: "BND", lotID: "", shareCount: 2, shareBasis: 0.50)
        let pv = h.getPresentValue(securityMap)!
        let lh = LiquidateHolding(h, presentValue: pv, fraction: 1) // sell all of position
        XCTAssertEqual(2.0, lh.presentValue)
        XCTAssertEqual(1.0, lh.fraction)
        XCTAssertEqual(1.0, lh.fractionalGainLoss) // 2 * (1 - 0.50)
        XCTAssertEqual(2.0, lh.fractionalShareCount)
        XCTAssertEqual(2.0, lh.fractionalValue)
    }

    func testFullWithLoss() throws {
        let h = MHolding(accountID: "1", securityID: "BND", lotID: "", shareCount: 2, shareBasis: 1.50)
        let pv = h.getPresentValue(securityMap)!
        let lh = LiquidateHolding(h, presentValue: pv, fraction: 1) // sell all of position
        XCTAssertEqual(2.0, lh.presentValue)
        XCTAssertEqual(1.0, lh.fraction)
        XCTAssertEqual(-1.0, lh.fractionalGainLoss) // 2 * (1 - 1.50)
        XCTAssertEqual(2.0, lh.fractionalShareCount)
        XCTAssertEqual(2.0, lh.fractionalValue)
    }

    func testHalfWithGain() throws {
        let h = MHolding(accountID: "1", securityID: "BND", lotID: "", shareCount: 2, shareBasis: 0.50)
        let pv = h.getPresentValue(securityMap)!
        let lh = LiquidateHolding(h, presentValue: pv, fraction: 0.5) // sell half of position
        XCTAssertEqual(2.0, lh.presentValue)
        XCTAssertEqual(0.5, lh.fraction)
        XCTAssertEqual(0.5, lh.fractionalGainLoss) // (2 * (1 - 0.50)) * 0.5
        XCTAssertEqual(1.0, lh.fractionalShareCount)
        XCTAssertEqual(1.0, lh.fractionalValue)
    }

    func testHalfWithLoss() throws {
        let h = MHolding(accountID: "1", securityID: "BND", lotID: "", shareCount: 2, shareBasis: 1.50)
        let pv = h.getPresentValue(securityMap)!
        let lh = LiquidateHolding(h, presentValue: pv, fraction: 0.5) // sell half of position
        XCTAssertEqual(2.0, lh.presentValue)
        XCTAssertEqual(0.5, lh.fraction)
        XCTAssertEqual(-0.5, lh.fractionalGainLoss) // (2 * (1 - 1.50)) * 0.5
        XCTAssertEqual(1.0, lh.fractionalShareCount)
        XCTAssertEqual(1.0, lh.fractionalValue)
    }
}
