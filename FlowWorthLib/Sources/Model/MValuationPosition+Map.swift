//
//  MValuationPosition+map.swift
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

extension MValuationPosition {
    
    /// Get the total basis difference between two sets of positions
    ///
    /// Keyed by AccountAssetKeyed (accountID,assetID)
    ///
    /// e.g., beg: 1, end: 4 => diff: +3
    ///
    /// Entries with net zero share counts are dropped.
    ///
    static func getBasisMap(begPositions: [MValuationPosition],
                             endPositions: [MValuationPosition],
                             epsilon: Double = 0.0001) -> AccountAssetValueMap {
        let begMap = MValuationPosition.getAccountAssetKeyMap(begPositions)
        let endMap = MValuationPosition.getAccountAssetKeyMap(endPositions)
        let combinedSubKeys = Set(begMap.map(\.key)).union(endMap.map(\.key))
        var rbmap: AccountAssetValueMap = combinedSubKeys.reduce(into: [:]) { map, subkey in
            
            // remove share count present at beginning, if any
            begMap[subkey]?.forEach { position in
                map[subkey, default: 0] -= position.totalBasis
            }
            
            // add sharecount present at end, if any
            endMap[subkey]?.forEach { position in
                map[subkey, default: 0] += position.totalBasis
            }
        }
        
        let zeroACs = rbmap.filter { $1.isEqual(to: 0, accuracy: epsilon) }.keys
        zeroACs.forEach { assetID in
            rbmap.removeValue(forKey: assetID)
        }
        
        return rbmap
    }

    static func getBasisMap(valuationPositions: [MValuationPosition]) -> AccountAssetValueMap {
        valuationPositions.reduce(into: [:]) { map, position in
            map[position.accountAssetKey] = position.totalBasis
        }
    }
    
    static func getMarketValueMap(valuationPositions: [MValuationPosition]) -> AccountAssetValueMap {
        valuationPositions.reduce(into: [:]) { map, position in
            map[position.accountAssetKey] = position.marketValue
        }
    }
}


