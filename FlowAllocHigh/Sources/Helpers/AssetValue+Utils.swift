//
//  AssetValue+Utils.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

import AllocData

import FlowAllocLow
import FlowBase


public extension AssetValue {
    static func distribute(value: Double, allocationMap: AssetValueMap, includeZero: Bool = false) -> AssetValueMap {
        allocationMap.reduce(into: [:]) { map, entry in
            let (assetKey, targetPct) = entry
            let contrib = value * targetPct
            if includeZero || contrib > 0 { map[assetKey] = contrib }
        }
    }

    // difference = a - b
    // entries in A that are missing from B default to A's value (B is assumed to be 0).
    // entries in B that are missing from A will be -B (A is assumed to be 0).
    static func difference(_ mapA: AssetValueMap, _ mapB: AssetValueMap, includeZero: Bool = false, epsilon: Double = 0.0001) -> AssetValueMap
    {
        Set(mapA.keys).union(mapB.keys).reduce(into: [:]) { map, assetKey in
            let amountA = mapA[assetKey, default: 0]
            let amountB = mapB[assetKey, default: 0]
            let val = amountA - amountB
            if includeZero || val.isNotEqual(to: 0, accuracy: epsilon) { map[assetKey] = val }
        }
    }

    // from [AccountKey: [AssetValue]] to [AccountKey: [AssetKey: Double]]
    static func getAccountAssetValueMap(_ map: AccountAssetValuesMap) -> AccountAssetValueMap {
        let tuples: [(AccountKey, AssetValueMap)] = map.compactMap { accountKey, allocs in
            (accountKey, AssetValue.getAssetValueMap(from: allocs))
        }
        return Dictionary(uniqueKeysWithValues: tuples)
    }

    // from [AccountKey: [AssetKey: AMOUNT]] to [AccountKey: [AssetKey: PERCENT]]
    static func getAccountAssetValueMap(_ map: AccountAssetValueMap) -> AccountAssetValueMap {
        let tuples: [(AccountKey, AssetValueMap)] = map.map {
            ($0, getNormalizedAssetValueMap(from: $1, includeZeros: true))
        }
        return Dictionary(uniqueKeysWithValues: tuples)
    }

    // TODO: needs tests
    // the normalizer (e.g., from AmountMap)
    // discards blank asset classes
    // negative targetPcts are zeroed
    // duplicate asset classes are merged
    static func getNormalizedAssetValueMap(from rawMap: AssetValueMap, includeZeros: Bool = false, epsilon: Double = 0.0001) -> AssetValueMap {
        let tuples = rawMap.map { ($0.key, max(0, $0.value)) }

        let groupedByAC = Dictionary(grouping: tuples, by: { $0.0 }) // assetClass0: [tuple0, tuple1, ...], assetClass1: [tuple3, tuple4, ....]

        let mergedTargetPcts = groupedByAC.map { ($0, $1.reduce(0) { $0 + $1.1 }) } // assetClass0: 0.10, assetClass1: 0.30, ...

        let total = mergedTargetPcts.reduce(0) { $0 + $1.1 }

        guard total.isGreater(than: 0, accuracy: epsilon) else {
            return includeZeros ? Dictionary(uniqueKeysWithValues: mergedTargetPcts) : [:]
        }

        let normalizedTuples = mergedTargetPcts.map { ($0.0, $0.1 / total) }

        let filtered = includeZeros ? normalizedTuples : normalizedTuples.filter { $0.1.isGreater(than: 0, accuracy: epsilon) }

        return Dictionary(uniqueKeysWithValues: filtered)
    }
}
