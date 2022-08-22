//
//  AssetValue.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

import AllocData


// for holding amounts and targetPct for assets
public struct AssetValue: Codable, Hashable {
    public var assetKey: AssetKey
    public var value: Double

    public init(_ assetKey: AssetKey, _ value: Double) {
        self.assetKey = assetKey
        self.value = value
    }
}

extension AssetValue: Comparable {
    public static func < (lhs: AssetValue, rhs: AssetValue) -> Bool {
        lhs.value < rhs.value ||
            (lhs.value == rhs.value && lhs.assetKey < rhs.assetKey)
    }
}

public extension AssetValue {
    // consolidates an array of allocs into a map, summing by asset
    static func getAssetValueMap(from assetValues: [AssetValue]) -> AssetValueMap {
        let grouped: [AssetKey: [AssetValue]] = Dictionary(grouping: assetValues, by: { $0.assetKey })
        return grouped.reduce(into: [:]) { resultMap, entry in
            let (assetKey, assetValues) = entry
            resultMap[assetKey] = sumOf(assetValues)
        }
    }

    // largest to smallest
    static func getAssetValues(from assetValueMap: AssetValueMap) -> [AssetValue] {
        assetValueMap
            .sorted(by: { $0.value > $1.value })
            .map { AssetValue($0.key, $0.value) }
    }

    // allocMap may not have corresponding values in assetKeys, but we'll add them at end
    // TODO: rethink implementation, as it's showing up as SLOW in profiling
    static func getAssetValues(from assetValueMap: AssetValueMap, orderBy targetKeys: [AssetKey]) -> [AssetValue] {
        let sourceKeys = assetValueMap.map(\.key)
        let targetKeySet = Set(targetKeys)
        let missingFromTarget = sourceKeys.filter { !targetKeySet.contains($0) }.sorted()
        let fullTargetKeys = targetKeys + missingFromTarget
        let nuOrder = sourceKeys.reorder(by: fullTargetKeys)
        return nuOrder.compactMap {
            guard let targetPct = assetValueMap[$0] else { return nil }
            return AssetValue($0, targetPct)
        }
    }

    // for rolled-up, or not
    static func getAssetValues(allocations: [MAllocation]) -> [AssetValue] {
        allocations.compactMap {
            guard $0.assetKey.isValid else { return nil }
            return AssetValue($0.assetKey, $0.targetPct)
        }
    }

    static func sumOf(_ map: AssetValueMap) -> Double {
        sumOf(getAssetValues(from: map))
    }

    static func sumOf(_ assetValues: [AssetValue]) -> Double {
        assetValues.map(\.value).reduce(0) { $0 + $1 }
    }

    static func sumOf(_ map: [String: AssetValue]) -> Double {
        sumOf(map.values.map { $0 })
    }

    // used for summing orphans, etc.
    static func sumOf(_ map: [AccountKey: AssetValueMap]) -> Double {
        map.reduce(0.0) { $0 + sumOf($1.value) }
    }

    // for AccountAssetValueMap, sum a specific asset for all accounts
    static func sumOf(_ map: [AccountKey: AssetValueMap], assetKey: AssetKey) -> Double {
        map.reduce(0.0) { $0 + ($1.value[assetKey] ?? 0) }
    }

    // NOTE does NOT match against list of valid asset classes
    static func validateAllocMap(_ assetValueMap: AssetValueMap, epsilon: Double = 0.0001) throws {
        let allocs = assetValueMap.map { AssetValue($0.key, $0.value) }
        try validateAllocs(allocs, epsilon: epsilon)
    }

    // NOTE does NOT match against list of valid asset classes
    static func validateAllocs(_ assetValues: [AssetValue], epsilon: Double = 0.0001) throws {
        let assetKeys = assetValues.map(\.assetKey)
        guard assetKeys.allSatisfy({ $0.isValid }) else {
            throw FlowBaseError.validationFailure("Asset classes must not be blank.")
        }
        guard assetKeys.isUnique else {
            throw FlowBaseError.validationFailure("Asset classes must be unique.")
        }
        guard assetValues.map(\.value).allSatisfy({ $0 >= 0 }) else {
            throw FlowBaseError.validationFailure("Each slice must be >= 0.")
        }

        let sum = sumOf(assetValues)
        guard abs(sum - 1.0) < epsilon else {
            throw FlowBaseError.validationFailure("Sum of slices must be 1.")
        }
    }

    // Normalize allocation percentages so that allocation sums to 1.0, in case they're just a bit off.
    // NOTE: does NOT do full validation. You may wish to do this following a normalize.
    // NOTE: unordered
    static func normalize(_ assetValues: [AssetValue]) throws -> [AssetValue] {
        let nonNegative = assetValues.map { AssetValue($0.assetKey, max(0, $0.value)) }
        let total = nonNegative.map(\.value).reduce(0) { $0 + $1 }
        guard total > 0 else {
            throw FlowBaseError.validationFailure("Sum of slices must be >0.")
        }
        return nonNegative.map { AssetValue($0.assetKey, $0.value / total) }
    }

    // NOTE: unordered
    static func normalize(_ map: AssetValueMap) throws -> AssetValueMap {
        let allocs = getAssetValues(from: map)
        let scrubbed = try normalize(allocs)
        return getAssetValueMap(from: scrubbed)
    }
}
