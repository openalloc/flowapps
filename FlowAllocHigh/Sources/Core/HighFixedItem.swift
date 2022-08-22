//
//  HighFixedItem.swift
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


public final class HighFixedItem: BaseItem {
    public var orphanedValue: Double

    public init(accountKey: AccountKey,
                alloc: AssetValue,
                holdingsSummary: HoldingsSummary,
                allocatedValue: Double,
                colorCode: Int,
                orphanedValue: Double)
    {
        self.orphanedValue = orphanedValue

        super.init(accountKey: accountKey,
                   alloc: alloc,
                   holdingsSummary: holdingsSummary,
                   allocatedValue: allocatedValue,
                   colorCode: colorCode)
    }

    override public func hash(into hasher: inout Hasher) {
        hasher.combine(orphanedValue)
        super.hash(into: &hasher)
    }
}
