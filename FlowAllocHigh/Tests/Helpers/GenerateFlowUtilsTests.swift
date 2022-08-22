//
//  AllocateTaskTests.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import XCTest

import FlowAllocLow
import FlowBase
import AllocData

@testable import FlowAllocHigh

class AllocateTaskTests: XCTestCase {
    func testGenerateFlowItemsSimple() throws {
        XCTAssertEqual([], generateFlowItems(itemCount: -1))
        XCTAssertEqual([], generateFlowItems(itemCount: 0))
        XCTAssertEqual([], generateFlowItems(itemCount: 1))
        XCTAssertEqual([0.0, 1.0], generateFlowItems(itemCount: 2))
        XCTAssertEqual([0.0, 0.5, 1.0], generateFlowItems(itemCount: 3))
        XCTAssertEqual([0.0, 0.333, 0.667, 1.0], generateFlowItems(itemCount: 4))
        XCTAssertEqual([0.0, 0.25, 0.5, 0.75, 1.0], generateFlowItems(itemCount: 5))
    }

    func testGenerateFlowItemsStride() throws {
        // invalid centroid
        [-1, -0.001, 1.001, 2].forEach {
            XCTAssertEqual([], generateFlowItems(centroid: $0, stride: 0.1, count: 1))
        }

        // valid centroid
        XCTAssertEqual([0.1], generateFlowItems(centroid: 0, stride: 0.1, count: 1))
        XCTAssertEqual([0.4, 0.6], generateFlowItems(centroid: 0.5, stride: 0.1, count: 1))
        XCTAssertEqual([0.9], generateFlowItems(centroid: 1.0, stride: 0.1, count: 1))

        // invalid stride
        [-1, -0.001, 0].forEach {
            XCTAssertEqual([], generateFlowItems(centroid: 0, stride: $0, count: 1))
        }

        // invalid count
        [-2, -1, 0].forEach {
            XCTAssertEqual([], generateFlowItems(centroid: 0, stride: 0.1, count: $0))
        }

        // all valid
        XCTAssertEqual([0, 0.25, 0.75, 1], generateFlowItems(centroid: 0.5, stride: 0.25, count: 2))
        XCTAssertEqual([0, 0.25, 0.75, 1], generateFlowItems(centroid: 0.5, stride: 0.25, count: 3)) // first and last dropped
    }
}
