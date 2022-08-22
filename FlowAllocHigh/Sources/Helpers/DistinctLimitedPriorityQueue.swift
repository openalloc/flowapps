//
//  DistinctLimitedPriorityQueue.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

import SwiftPriorityQueue

// Employs internal Set to avoid duplicates in Priority Queue
public struct DistinctLimitedPriorityQueue<T: Hashable & Comparable & Equatable> {
    public let name: String
    public let maxHeap: Int
    public var pq: PriorityQueue<T>
    private var set: Set<T>

    public init(name: String, order: @escaping (T, T) -> Bool, maxHeap: Int) {
        self.name = name
        self.maxHeap = maxHeap
        pq = .init(order: order)
        set = .init()
    }

    // push, ignoring duplicates (via the set)
    mutating public func push(_ element: T) {
        if set.contains(element) {
            //print("\(name) IGNORE=\(element.hashValue) set=\(set.count)")
            return
        }

        let originalCount = pq.count

        if let discard = pq.push(element, maxHeap: maxHeap) {
            //print("\(name) DISCARD: REMOVE=\(discard.hashValue) INSERT=\(element.hashValue) set=\(set.count) pq=\(pq.count)")
            set.remove(discard)
            set.insert(element)
        } else if pq.count > originalCount {
            // Detect if item was actually pushed to queue, and if so, track it in set.
            // Catches case of where the queue is filling from empty and there's nothing to discard.
            //print("\(name) INSERT=\(element.hashValue) set=\(set.count) pq=\(pq.count)")
            set.insert(element)
        }

        // validate operation
        assert(set.count == pq.count)
    }

    mutating public func clear(newOrder: ((T, T) -> Bool)? = nil) {
        pq.clear(newOrder: newOrder)
        set.removeAll()
    }
}
