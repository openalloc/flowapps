//
//  Cashflow+Comparable.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

import AllocData

import FlowBase

// NOTE this is similar to MTransaction's Comparable
extension MValuationCashflow: Comparable {
    public static func < (lhs: MValuationCashflow, rhs: MValuationCashflow) -> Bool {
        if lhs.transactedAt < rhs.transactedAt { return true }
        if lhs.transactedAt > rhs.transactedAt { return false }

        if lhs.accountKey < rhs.accountKey { return true }
        if lhs.accountKey > rhs.accountKey { return false }

        if lhs.assetKey < rhs.assetKey { return true }
        if lhs.assetKey > rhs.assetKey { return false }
        
        if lhs.amount < rhs.amount { return true }
        if lhs.amount > rhs.amount { return false }

        return false
    }
}
