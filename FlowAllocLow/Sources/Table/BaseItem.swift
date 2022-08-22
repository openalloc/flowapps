//
//  BaseItem.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

import FlowBase


// need unique values to populate LazyVGrid, so this wrapper used
open class BaseItem: Hashable, Identifiable {
    public var id: Int { hashValue }
    public var accountKey: AccountKey
    public var holdingsSummary: HoldingsSummary
    public var allocatedValue: Double
    public var colorCode: Int

    public var alloc: AssetValue

    public init(accountKey: AccountKey,
                alloc: AssetValue,
                holdingsSummary: HoldingsSummary,
                allocatedValue: Double,
                colorCode: Int)
    {
        self.accountKey = accountKey
        self.alloc = alloc
        self.holdingsSummary = holdingsSummary
        self.allocatedValue = allocatedValue
        self.colorCode = colorCode
    }

    open func hash(into hasher: inout Hasher) {
        hasher.combine(accountKey)
        hasher.combine(alloc)
        hasher.combine(holdingsSummary)
        hasher.combine(allocatedValue)
        hasher.combine(colorCode)
    }
}

extension BaseItem: Equatable {
    public static func == (lhs: BaseItem, rhs: BaseItem) -> Bool {
        lhs.accountKey == rhs.accountKey &&
            lhs.alloc == rhs.alloc
    }
}
