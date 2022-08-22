//
//  MAllocation+Utils.swift
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

public extension MAllocation {

    private static func getAllocations(strategyKey: StrategyKey,
                                       allocations: [MAllocation],
                                       filteredBy assetKeys: AssetKeySet) -> [MAllocation]
    {
        allocations.filter {
            strategyKey.isValid &&
                $0.strategyKey == strategyKey &&
                $0.assetKey.isValid &&
                assetKeys.contains($0.assetKey) &&
                $0.targetPct > 0
        }
    }
}

public extension MAllocation {
    static func getAllocMap(allocations: [MAllocation]) -> AssetValueMap {
        let assetKeys = allocations.map(\.assetKey)
        let targetPcts = allocations.map(\.targetPct)
        return Dictionary(uniqueKeysWithValues: zip(assetKeys, targetPcts))
    }

    static func getAllocMap(strategyKey: StrategyKey,
                            allocations: [MAllocation],
                            filteredBy assetKeySet: AssetKeySet) -> AssetValueMap
    {
        let tuples: [(AssetKey, Double)] = getAllocations(strategyKey: strategyKey, allocations: allocations, filteredBy: assetKeySet).compactMap {
            guard $0.assetKey.isValid else { return nil }
            return ($0.assetKey, $0.targetPct)
        }
        return Dictionary(uniqueKeysWithValues: tuples)
    }
}

public extension BaseModel {
    var strategyAllocationsMap: StrategyAllocationsMap { // [StrategyKey: [MAllocation]]
        Dictionary(grouping: allocations, by: { $0.strategyKey })
    }

    var strategyAllocsMap: StrategyAssetValuesMap { // [StrategyKey: [AssetValue]]
        AssetValue.getStrategyAssetValuesMap(strategyAllocationsMap)
    }
}
