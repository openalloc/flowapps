//
//  StrategyAssetKeyed.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

import AllocData

public protocol StrategyAssetKeyed {
    var strategyAssetKey: StrategyAssetKey { get }
}

public struct StrategyAssetKey: Hashable {
    let strategyNormID: String
    let assetNormID: String
    
    public init(strategyID: StrategyID,
                assetID: AssetID) {
        self.strategyNormID = MHolding.normalizeID(strategyID)
        self.assetNormID = MHolding.normalizeID(assetID)
    }
    
    public var strategyKey: StrategyKey {
        MStrategy.Key(strategyID: strategyNormID)
    }
    
    public var assetKey: AssetKey {
        MAsset.Key(assetID: assetNormID)
    }
}

extension StrategyAssetKey: Comparable {
    public static func < (lhs: StrategyAssetKey, rhs: StrategyAssetKey) -> Bool {
        lhs.strategyNormID < rhs.strategyNormID ||
        (lhs.strategyNormID == rhs.strategyNormID && lhs.assetNormID < rhs.assetNormID)
    }
}

public extension StrategyAssetKeyed {
    static func getStrategyAssetKeyMap<T: StrategyAssetKeyed>(_ elements: [T]) -> [StrategyAssetKey: [T]] {
        elements.reduce(into: [:]) { map, element in
            map[ element.strategyAssetKey, default: [] ].append(element)
        }
    }
}
