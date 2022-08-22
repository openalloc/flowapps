//
//  HighResult+Comparable.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

import FlowAllocLow
import FlowBase

// NOTE needed by PriorityQueue
extension HighResult: Comparable {
    public static func < (lhs: HighResult, rhs: HighResult) -> Bool {
        lhs.transactionCount < rhs.transactionCount
    }

    public static func getOrder(_ orders: [ResultSort]) -> HighResultOrderFn {
        getOrder(ArraySlice(orders))
    }

    private static func getOrder(_ orders: ArraySlice<ResultSort>) -> HighResultOrderFn {
        { !HighResult.bySortOrder($0, $1, orders) }
    }

    // NOTE the priority queue have an inverted sort, so we reverse here to compensate
    private static func bySortOrder(_ lhs: HighResult, _ rhs: HighResult, _ sortOrders: ArraySlice<ResultSort>) -> Bool {
        guard let sortOrder = sortOrders.first else { return false }
        switch sortOrder.attribute {
        case .netTaxGains:
            if sortOrder.direction == .ascending {
                if lhs.taxableGainsDollars > rhs.taxableGainsDollars { return true }
            } else {
                if lhs.taxableGainsDollars < rhs.taxableGainsDollars { return true }
            }
            if lhs.taxableGainsDollars == rhs.taxableGainsDollars { return bySortOrder(lhs, rhs, sortOrders.dropFirst()) }
        case .absTaxGains:
            if sortOrder.direction == .ascending {
                if lhs.absTaxableGainsDollars > rhs.absTaxableGainsDollars { return true }
            } else {
                if lhs.absTaxableGainsDollars < rhs.absTaxableGainsDollars { return true }
            }
            if lhs.absTaxableGainsDollars == rhs.absTaxableGainsDollars { return bySortOrder(lhs, rhs, sortOrders.dropFirst()) }
        case .saleVolume:
            if sortOrder.direction == .ascending {
                if lhs.volumeDollars > rhs.volumeDollars { return true }
            } else {
                if lhs.volumeDollars < rhs.volumeDollars { return true }
            }
            if lhs.volumeDollars == rhs.volumeDollars { return bySortOrder(lhs, rhs, sortOrders.dropFirst()) }
        case .transactionCount:
            if sortOrder.direction == .ascending {
                if lhs.transactionCount > rhs.transactionCount { return true }
            } else {
                if lhs.transactionCount < rhs.transactionCount { return true }
            }
            if lhs.transactionCount == rhs.transactionCount { return bySortOrder(lhs, rhs, sortOrders.dropFirst()) }
        case .flowMode:
            if sortOrder.direction == .ascending {
                if lhs.flowModeInt > rhs.flowModeInt { return true }
            } else {
                if lhs.flowModeInt < rhs.flowModeInt { return true }
            }
            if lhs.flowModeInt == rhs.flowModeInt { return bySortOrder(lhs, rhs, sortOrders.dropFirst()) }
        case .wash:
            if sortOrder.direction == .ascending {
                if lhs.washAmountDollars > rhs.washAmountDollars { return true }
            } else {
                if lhs.washAmountDollars < rhs.washAmountDollars { return true }
            }
            if lhs.washAmountDollars == rhs.washAmountDollars { return bySortOrder(lhs, rhs, sortOrders.dropFirst()) }
        }
        return false
    }
}
