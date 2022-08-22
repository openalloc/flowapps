//
//  DistinctLimitedPQTests.swift
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

class DistinctLimitedPQTests: XCTestCase {
    func testHeap1LessThan() {
        var queue = DistinctLimitedPriorityQueue<Int>(name: "A", order: { $0 < $1 }, maxHeap: 1)
        queue.push(4)
        queue.push(5)
        queue.push(5)
        XCTAssertEqual(1, queue.pq.count)
        XCTAssertEqual(4, queue.pq.pop())
    }

    func testHeap1GreaterThan() {
        var queue = DistinctLimitedPriorityQueue<Int>(name: "A", order: { $0 > $1 }, maxHeap: 1)
        queue.push(4)
        queue.push(5)
        queue.push(5)
        XCTAssertEqual(1, queue.pq.count)
        XCTAssertEqual(5, queue.pq.pop())
    }

    func testHeap2LessThan() {
        var queue = DistinctLimitedPriorityQueue<Int>(name: "A", order: { $0 < $1 }, maxHeap: 2)
        queue.push(4)
        queue.push(5)
        queue.push(5)
        XCTAssertEqual(2, queue.pq.count)
        XCTAssertEqual(5, queue.pq.pop())
        XCTAssertEqual(4, queue.pq.pop())
        XCTAssertNil(queue.pq.pop())
    }

    func testHeap2GreaterThan() {
        var queue = DistinctLimitedPriorityQueue<Int>(name: "A", order: { $0 > $1 }, maxHeap: 2)
        queue.push(4)
        queue.push(5)
        queue.push(5)
        XCTAssertEqual(2, queue.pq.count)
        XCTAssertEqual(4, queue.pq.pop())
        XCTAssertEqual(5, queue.pq.pop())
        XCTAssertNil(queue.pq.pop())
    }
}
