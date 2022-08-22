//
//  MatrixResult+Utils.swift
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
import Accelerate

extension MatrixResult: Equatable {
    public static func == (lhs: MatrixResult, rhs: MatrixResult) -> Bool {
        lhs.period == rhs.period
    }
}

extension MatrixResult {
    
    static func getSnapshotMarketValueMap(snapshotKeys: [SnapshotKey],
                                          snapshotPositionsMap: SnapshotPositionsMap
                                          //positionKeyFilter: PositionKeyFilter
    ) -> SnapshotValueMap {
        snapshotKeys.reduce(into: [:]) { map, snapshotKey in
            
            let marketValues = snapshotPositionsMap[snapshotKey]?.map(\.marketValue) ?? []
            map[snapshotKey] = marketValues.reduce(0, +)
        }
    }
    
    // for a series of snapshots, get the net market value by asset (or account)
    //
    // e.g., for two snapshots [A, B], get the net asset market values:
    //
    //  [ "lc": [10, -20], "bond": [5, 3], "gold": [100, 200] ]
    //
    static func getMatrixData<T: AllocKeyed>(_: T.Type,
                                             snapshotKeys: [SnapshotKey],
                                             snapshotPositionsMap: SnapshotPositionsMap,
                                             allocKeys: [T.Key],
                                             positionKeyFilter: PositionKeyFilter<T>) -> AllocKeyValuesMap<T> {
        snapshotKeys.reduce(into: [:]) { matrixMap, snapshotKey in
            
            // group the snapshot's positions by asset (or account)
            let keyedPositions: PositionsMap<T> = {
                let snapPositions = snapshotPositionsMap[snapshotKey] ?? []
                return Dictionary(grouping: snapPositions, by: positionKeyFilter)
            }()
            
            // for each asset (or account)
            allocKeys.forEach { allocKey in
                
                // the positions for the asset (or account)
                let positions = keyedPositions[allocKey] ?? []
                
                // net sum of market values for all positions for this asset (or account) (negative values okay!)
                let sum = positions.reduce(0) { $0 + $1.marketValue }
                
                // append value for this asset (or account)
                matrixMap[allocKey, default: []].append(sum)
            }
        }
    }
}

