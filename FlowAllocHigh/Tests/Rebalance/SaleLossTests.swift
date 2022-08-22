//
//  SaleLossTests.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

import XCTest

import SimpleTree

import FlowAllocLow
import FlowBase
import AllocData

@testable import FlowAllocHigh

class SaleRealizingLossTests: XCTestCase {
    
    let bnd = MSecurity.Key(securityID: "BND")
    let spy = MSecurity.Key(securityID: "SPY")
    
    func testGetGainLossMap() throws {
        let spyHolding1 = MHolding(accountID: "1", securityID: "SPY", lotID: "", shareCount: 1, shareBasis: 2)
        let spyHolding2 = MHolding(accountID: "1", securityID: "SPY", lotID: "", shareCount: 1, shareBasis: 2)
        let spyHolding3 = MHolding(accountID: "2", securityID: "SPY", lotID: "", shareCount: 1, shareBasis: 2)
        let spyHolding4 = MHolding(accountID: "2", securityID: "SPY", lotID: "", shareCount: 1, shareBasis: 2)
        let bndHolding1 = MHolding(accountID: "1", securityID: "BND", lotID: "", shareCount: 1, shareBasis: 2)
        let bndHolding2 = MHolding(accountID: "1", securityID: "BND", lotID: "", shareCount: 1, shareBasis: 2)

        let sales: [Sale] = [
            Sale(assetKey: MAsset.Key(assetID: "LC"),
                 targetAmount: -10,
                 liquidateHoldings: [
                     LiquidateHolding(spyHolding1, presentValue: 10, fraction: 0.25),
                     LiquidateHolding(spyHolding2, presentValue: 10, fraction: 0.5),
                 ]),
            Sale(assetKey: MAsset.Key(assetID: "LC"),
                 targetAmount: -10,
                 liquidateHoldings: [
                     LiquidateHolding(spyHolding3, presentValue: 10, fraction: 0.5),
                     LiquidateHolding(spyHolding4, presentValue: 10, fraction: 0.5),
                 ]),
            Sale(assetKey: MAsset.Key(assetID: "Bond"),
                 targetAmount: -10,
                 liquidateHoldings: [
                     LiquidateHolding(bndHolding1, presentValue: 10, fraction: 0.5),
                     LiquidateHolding(bndHolding2, presentValue: 10, fraction: 0.25),
                 ]),
        ]

        let expected: TickerAmountMap = [spy: 14.0, bnd: 6.0]
        let actual = Sale.getNetGainLossMap(sales)
        XCTAssertEqual(expected, actual)
    }
}
