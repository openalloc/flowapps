//
//  StatsTests.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

@testable import FlowStats
import XCTest

class StatsTests: XCTestCase {
    func testRange() {
        let values = [-0.5, -0.3, -0.2, -0.4, 0, 0.3, 0.2, 0.8]
        let stats = Stats(values: values)
        let actual = stats.range
        let expected = -0.5...0.8
        XCTAssertEqual(expected, actual)
    }
}
