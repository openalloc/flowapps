//
//  HighRow.swift
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


public final class HighRow: BaseRow {
    public var netAlloc: AssetValue
    public var fixedCells: [HighFixedItem]

    public init(assetKey: AssetKey,
                targetPct: Double,
                allocatedValue: Double,
                cells: [BaseItem],
                colorCode: Int,
                netAlloc: AssetValue,
                fixedCells: [HighFixedItem])
    {
        self.netAlloc = netAlloc
        self.fixedCells = fixedCells

        super.init(assetKey: assetKey,
                   targetPct: targetPct,
                   allocatedValue: allocatedValue,
                   cells: cells,
                   colorCode: colorCode)
    }

    override public func hash(into hasher: inout Hasher) {
        hasher.combine(netAlloc)
        hasher.combine(fixedCells)
        super.hash(into: &hasher)
    }
}
