//
//  HoldingsSummaryTests.swift
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

class HoldingsSummaryTests: XCTestCase {
    func testUnrealizedGain() throws {
        let expected = 10.0
        let actual = HoldingsSummary(presentValue: 30, costBasis: 20).unrealizedGain
        XCTAssertEqual(expected, actual)
    }

    func testUnrealizedGainZeroForLoss() throws {
        let expected = 0.0
        let actual = HoldingsSummary(presentValue: 10, costBasis: 20).unrealizedGain
        XCTAssertEqual(expected, actual)
    }
}
