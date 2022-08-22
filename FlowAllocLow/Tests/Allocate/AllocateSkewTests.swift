//
//  AllocateSkewTests.swift
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

class AllocateSkewTests: XCTestCase {
    func testSkew() {
        let pairs: [(Double, Double)] = [
            (0.0, 0.0),
            (0.1, 0.19),
            (0.2, 0.36),
            (0.3, 0.51),
            (0.4, 0.64),
            (0.5, 0.75),
            (0.6, 0.84),
            (0.7, 0.91),
            (0.8, 0.96),
            (0.9, 0.99),
            (1.0, 1.0),
        ]

        for pair in pairs {
            XCTAssertEqual(pair.1, getSkewedAllocFlowMode(rawAllocFlowMode: pair.0), accuracy: 0.01)
        }
    }
}
