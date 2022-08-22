//
//  HoldingsSummary+Rollup.swift
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

public extension HoldingsSummary {
    // consolidate holdingSummary per rollup map
    static func rollup(_ map: inout AssetHoldingsSummaryMap, _ rollupMap: RollupMap) {
        rollupMap.forEach { parentKey, childrenKeys in
            guard var parentHS = map[parentKey] else { return }
            childrenKeys.forEach { childKey in
                if let hs = map[childKey] {
                    parentHS.presentValue += hs.presentValue // absorb child into parent
                    parentHS.costBasis += hs.costBasis
                    parentHS.count += hs.count
                    map.removeValue(forKey: childKey)
                }
            }
            map[parentKey] = parentHS
        }
    }

    // consolidate holdingSummary for each account per rollup map
    static func rollup(_ accountMap: inout AccountAssetHoldingsSummaryMap, _ rollupMap: RollupMap) {
        for (accountKey, var assetSummaryMap) in accountMap {
            rollup(&assetSummaryMap, rollupMap)
            accountMap[accountKey] = assetSummaryMap
        }
    }
}
