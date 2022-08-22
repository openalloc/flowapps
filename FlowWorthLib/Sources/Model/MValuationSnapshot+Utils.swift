//
//  MValuationSnapshot+Utils.swift
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

extension MValuationSnapshot {
        
    static func getSnapshotMarketValueMap(positionsMap: SnapshotPositionsMap,
                                          accountKeyFilter: AccountKeyFilter = { _ in true }) -> SnapshotValueMap {
        positionsMap.reduce(into: [:]) { map, entry in
            let (snapshotKey, positions) = entry
            let _positions = positions.filter { accountKeyFilter($0.accountKey) }
            map[snapshotKey] = _positions.reduce(0) { $0 + $1.marketValue }
        }
    }
    
    /// obtain market values for each snapshot
    static func getSnapshotMarketValueMap(positions: [MValuationPosition],
                                          accountKeyFilter: AccountKeyFilter = { _ in true }) -> SnapshotValueMap {
        let _positions = positions.filter { accountKeyFilter($0.accountKey) }
        return _positions.reduce(into: [:]) { map, position in
            map[position.snapshotKey, default: 0] += position.marketValue
        }
    }
    
    static func getSnapshotTotalBasisMap(positionsMap: SnapshotPositionsMap) -> SnapshotValueMap {
        positionsMap.reduce(into: [:]) { map, entry in
            let (snapshotKey, positions) = entry
            map[snapshotKey] = positions.reduce(0) { $0 + $1.totalBasis }
        }
    }

    /// obtain total basis values for each snapshot
    static func getSnapshotTotalBasisMap(positions: [MValuationPosition]) -> SnapshotValueMap {
        positions.reduce(into: [:]) { map, position in
            map[position.snapshotKey, default: 0] += position.totalBasis
        }
    }
    
    // get a map of [current: previous] snapshot keys, where first snapshot will have an 'empty' value
    internal static func getPreviousSnapshotKeyMap(snapshotDateIntervalMap: SnapshotDateIntervalMap) -> [SnapshotKey: SnapshotKey] {
        let snapshotsByDate = getSnapshotsByDate(snapshotDateIntervalMap: snapshotDateIntervalMap)
        return snapshotDateIntervalMap.reduce(into: [:]) { map, entry in
            let (snapshotKey, dateInterval) = entry
            let previousKey = snapshotsByDate[dateInterval.start] ?? SnapshotKey.empty
            map[snapshotKey] = previousKey
        }
    }
    
    // map the snapshots by their timestamp (same as the end of their date interval)
    internal static func getSnapshotsByDate(snapshotDateIntervalMap: SnapshotDateIntervalMap) -> [Date: SnapshotKey] {
        snapshotDateIntervalMap.reduce(into: [:]) { map, entry in
            map[entry.value.end] = entry.key
        }
    }
}
