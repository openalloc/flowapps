//
//  MValuationPosition+Utils.swift
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

public extension MValuationPosition {
    
    static func getTotalMarketValue(_ items: [MValuationPosition]) -> Double {
        items.reduce(0) { $0 + $1.marketValue }
    }
}

extension MValuationPosition {
    
    var snapshotKey: SnapshotKey {
        MValuationSnapshot.Key(snapshotID: snapshotID)
    }

    var unrealizedGainLoss: Double {
        marketValue - totalBasis
    }
    
    /// obtain an unordered and uniqued list of account IDs for a collection of positions
    static func getAccountIDs(positions: [MValuationPosition]) -> [AccountID] {
        let keyedIDMap: [AccountKey: AccountID] = positions.reduce(into: [:]) { map, position in
            let accountKey = position.accountKey
            guard accountKey.isValid else { return }
            map[accountKey] = position.accountID
        }
        return keyedIDMap.map(\.value)
    }
    
    /// TODO replace with IndexSet
    /// Obtain positions, filtered by account.
    /// Producees a map showing which accounts from the set of positions were filtered.
    static func getPositions(rawPositions: [MValuationPosition],
                             snapshotKeySet: Set<SnapshotKey>,
                             accountKeyFilter: AccountKeyFilter, // = { _ in true },
                             accountFilteredMap: inout AccountFilteredMap) -> [MValuationPosition] {
        rawPositions.compactMap { position in
            guard snapshotKeySet.contains(position.snapshotKey) else { return nil }
            let accountKey = position.accountKey
            let keep = accountKeyFilter(accountKey)
            accountFilteredMap[accountKey] = keep
            guard keep else { return nil }
            return position
        }
    }
}
