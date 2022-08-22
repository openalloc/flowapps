//
//  AssetValue+Map.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

import FlowBase

public extension AssetValue {
    // raw allocations (non-rolled up)
    static func getStrategyAssetValuesMap(_ strategyAllocationsMap: StrategyAllocationsMap) -> StrategyAssetValuesMap { // [StrategyKey: [AssetValue]]
        let strategyKeys = strategyAllocationsMap.map(\.key)
        let allocArrays: [[AssetValue]] = strategyKeys.map {
            let allocations = strategyAllocationsMap[$0] ?? []
            return getAssetValues(allocations: allocations)
        }
        return Dictionary(uniqueKeysWithValues: zip(strategyKeys, allocArrays))
    }

}
