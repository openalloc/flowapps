//
//  ModelSettings.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

import FlowBase
import AllocData


// settings usually requiring a context-reset
// shouldn't include navigation-oriented settings, such as tab selection or navigation state
// okay to include infrequently-changed formatting details, such as locale
public struct ModelSettings: Codable, Equatable {
    public var activeStrategyKey: MStrategy.Key
    public var rollupAssets: Bool
    public var rollupThreshold: Int
    public var groupRelatedHoldings: Bool
    public var reduceRebalance: Bool
    public var sharesSignificantDigits: Int
    public var optimizeMaxHeap: Int
    public var optimizeMaxCores: Int
    public var optimizePriority: Int
    public var optimizeSortA: [ResultSort]
    public var optimizeSortB: [ResultSort]
    public var optimizeSortC: [ResultSort]
    public var minimumSaleAmount: Int
    public var minimumPositionValue: Int

    public static let defaultActiveStrategyKey = MStrategy.emptyKey
    public static let defaultRollupAssets = false
    public static let defaultRollupThreshold = 10
    public static let defaultGroupRelatedHoldings = false
    public static let defaultReduceRebalance = false
    public static let defaultSharesSignificantDigits = 6
    public static let defaultOptimizeMaxHeap = 10
    public static let defaultOptimizeMaxCores = 8
    public static let defaultOptimizePriority = OptimizePriority.default_.rawValue
    public static let defaultOptimizeSortA = [
        ResultSort(.netTaxGains),
        ResultSort(.wash),
        ResultSort(.saleVolume),
        ResultSort(.flowMode),
    ]
    public static let defaultOptimizeSortB = [
        ResultSort(.wash),
        ResultSort(.netTaxGains),
        ResultSort(.saleVolume),
        ResultSort(.flowMode),
    ]
    public static let defaultOptimizeSortC = [
        ResultSort(.saleVolume),
        ResultSort(.netTaxGains),
        ResultSort(.wash),
        ResultSort(.flowMode),
    ]
    public static let defaultMinimumSaleAmount = 10
    public static let defaultMinimumPositionValue = 100

    public enum CodingKeys: String, CodingKey, CaseIterable {
        case activeStrategyKey
        case rollupAssets
        case rollupThreshold
        case groupRelatedHoldings
        case reduceRebalance
        case sharesSignificantDigits
        case optimizeMaxHeap
        case optimizeMaxCores
        case optimizePriority
        case optimizeSortA
        case optimizeSortB
        case optimizeSortC
        case minimumSaleAmount
        case minimumPositionValue
    }

    public init() {
        activeStrategyKey = ModelSettings.defaultActiveStrategyKey
        rollupAssets = ModelSettings.defaultRollupAssets
        rollupThreshold = ModelSettings.defaultRollupThreshold
        groupRelatedHoldings = ModelSettings.defaultGroupRelatedHoldings
        reduceRebalance = ModelSettings.defaultReduceRebalance
        sharesSignificantDigits = ModelSettings.defaultSharesSignificantDigits
        optimizeMaxHeap = ModelSettings.defaultOptimizeMaxHeap
        optimizeMaxCores = ModelSettings.defaultOptimizeMaxCores
        optimizePriority = ModelSettings.defaultOptimizePriority
        optimizeSortA = ModelSettings.defaultOptimizeSortA
        optimizeSortB = ModelSettings.defaultOptimizeSortB
        optimizeSortC = ModelSettings.defaultOptimizeSortC
        minimumSaleAmount = ModelSettings.defaultMinimumSaleAmount
        minimumPositionValue = ModelSettings.defaultMinimumPositionValue
    }

    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        activeStrategyKey = try c.decodeIfPresent(StrategyKey.self, forKey: .activeStrategyKey) ?? ModelSettings.defaultActiveStrategyKey
        rollupAssets = try c.decodeIfPresent(Bool.self, forKey: .rollupAssets) ?? ModelSettings.defaultRollupAssets
        rollupThreshold = try c.decodeIfPresent(Int.self, forKey: .rollupThreshold) ?? ModelSettings.defaultRollupThreshold
        groupRelatedHoldings = try c.decodeIfPresent(Bool.self, forKey: .groupRelatedHoldings) ?? ModelSettings.defaultGroupRelatedHoldings
        reduceRebalance = try c.decodeIfPresent(Bool.self, forKey: .reduceRebalance) ?? ModelSettings.defaultReduceRebalance
        sharesSignificantDigits = try c.decodeIfPresent(Int.self, forKey: .sharesSignificantDigits) ?? ModelSettings.defaultSharesSignificantDigits
        optimizeMaxHeap = try c.decodeIfPresent(Int.self, forKey: .optimizeMaxHeap) ?? ModelSettings.defaultOptimizeMaxHeap
        optimizeMaxCores = try c.decodeIfPresent(Int.self, forKey: .optimizeMaxCores) ?? ModelSettings.defaultOptimizeMaxCores
        optimizePriority = try c.decodeIfPresent(Int.self, forKey: .optimizePriority) ?? ModelSettings.defaultOptimizePriority
        optimizeSortA = try c.decodeIfPresent([ResultSort].self, forKey: .optimizeSortA) ?? ModelSettings.defaultOptimizeSortA
        optimizeSortB = try c.decodeIfPresent([ResultSort].self, forKey: .optimizeSortB) ?? ModelSettings.defaultOptimizeSortB
        optimizeSortC = try c.decodeIfPresent([ResultSort].self, forKey: .optimizeSortC) ?? ModelSettings.defaultOptimizeSortC
        minimumSaleAmount = try c.decodeIfPresent(Int.self, forKey: .minimumSaleAmount) ?? ModelSettings.defaultMinimumSaleAmount
        minimumPositionValue = try c.decodeIfPresent(Int.self, forKey: .minimumPositionValue) ?? ModelSettings.defaultMinimumPositionValue
    }
}
