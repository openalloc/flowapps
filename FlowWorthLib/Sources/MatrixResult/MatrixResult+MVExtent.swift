//
//  MatrixResult+MVExtent.swift
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

// these routines used to calculate maximum positive and negative extents for NiceScale
extension MatrixResult {
    
    private typealias SnapshotMarketValueExtentMap = [SnapshotKey: ExtentTuple]
    
    // sum of negative and positive MVs for each snapshot, by asset or account
    // used to determine vertical scale for stacked asset/account chart
    static func getAssetMarketValueExtentRange(snapshotKeys: [SnapshotKey],
                                               snapshotPositionsMap: SnapshotPositionsMap) -> ClosedRange<Double>? {
        let map: SnapshotMarketValueExtentMap = snapshotKeys.reduce(into: [:]) { map, snapshotKey in
            
            let positions = snapshotPositionsMap[snapshotKey] ?? []
            let positionsMap = Dictionary(grouping: positions, by: { $0.assetKey })
            map[snapshotKey] = getExtent(MAsset.self, positionsMap)
        }
        
        return getMarketValueExtentRange(map)
    }
    
    static func getAccountMarketValueExtentRange(snapshotKeys: [SnapshotKey],
                                                 snapshotPositionsMap: SnapshotPositionsMap) -> ClosedRange<Double>? {
        let map: SnapshotMarketValueExtentMap = snapshotKeys.reduce(into: [:]) { map, snapshotKey in
            
            let positions = snapshotPositionsMap[snapshotKey] ?? []
            let positionsMap = Dictionary(grouping: positions, by: { $0.accountKey })
            map[snapshotKey] = getExtent(MAccount.self, positionsMap)
        }
        
        return getMarketValueExtentRange(map)
    }
    
    func getStrategyMarketValueExtentRange(snapshotKeys: [SnapshotKey],
                                                 snapshotPositionsMap: SnapshotPositionsMap) -> ClosedRange<Double>? {
        let map: SnapshotMarketValueExtentMap = snapshotKeys.reduce(into: [:]) { map, snapshotKey in
            
            let positions = snapshotPositionsMap[snapshotKey] ?? []
            let positionsMap = Dictionary(grouping: positions, by: { getStrategyKey($0.accountKey) })
            map[snapshotKey] = MatrixResult.getExtent(MStrategy.self, positionsMap)
        }
        
        return MatrixResult.getMarketValueExtentRange(map)
    }
    
    private static func getExtent<T>(_ type: T.Type,
                                     _ positionsMap: [T.Key: [MValuationPosition]]) -> ExtentTuple
    where T: AllocBase & AllocKeyed {
        
        // sum market values of positions, by AccountKey or AssetKey
        let map: AllocKeyValueMap<T> = positionsMap.reduce(into: [:]) { map, entry in
            let (key, positions) = entry
            map[key] = positions.map(\.marketValue).reduce(0, +)
        }
        
        let marketValues = map.map(\.value)
        let negSum = marketValues.filter { $0 < 0 }.reduce(0, +)
        let posSum = marketValues.filter { $0 > 0 }.reduce(0, +)
        
        return ExtentTuple(negative: negSum, positive: posSum)
    }
    
    private static func getMarketValueExtentRange(_ map: SnapshotMarketValueExtentMap) -> ClosedRange<Double>? {
        let mvTuples = map.map(\.value)
        var min = Double.greatestFiniteMagnitude
        var max = Double.leastNonzeroMagnitude
        mvTuples.forEach {
            if $0.negative < min {
                min = $0.negative
            }
            if $0.positive > max {
                max = $0.positive
            }
        }
        guard min <= max else { return nil }
        return min...max
    }
}
