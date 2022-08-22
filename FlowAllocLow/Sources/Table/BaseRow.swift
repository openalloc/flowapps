//
//  BaseRow.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

import FlowBase


open class BaseRow: Hashable, Identifiable {
    public var id: Int { hashValue }
    public var assetKey: AssetKey
    public var targetPct: Double
    public var allocatedValue: Double
    public var cells: [BaseItem]
    public var colorCode: Int

    public init(assetKey: AssetKey, targetPct: Double, allocatedValue: Double, cells: [BaseItem], colorCode: Int) {
        self.assetKey = assetKey
        self.targetPct = targetPct
        self.allocatedValue = allocatedValue
        self.cells = cells
        self.colorCode = colorCode
    }

    open func hash(into hasher: inout Hasher) {
        // hasher.combine(id)
        hasher.combine(assetKey)
        hasher.combine(targetPct)
        hasher.combine(allocatedValue)
        hasher.combine(cells)
        hasher.combine(colorCode)
    }
}

extension BaseRow: Equatable {
    public static func == (lhs: BaseRow, rhs: BaseRow) -> Bool {
        lhs.assetKey == rhs.assetKey
    }
}
