//
//  Positions+Utils.swift
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
    
    /// in each account, roll-up holdings by asset as necessary to create valuation positions
    /// result is UNORDERED
    static func createPositions(holdings: [MHolding],
                                snapshotID: SnapshotID,
                                securityMap: SecurityMap,
                                assetMap: AssetMap) -> [MValuationPosition] {
        let accountHoldingsMap: AccountHoldingsMap = Dictionary(grouping: holdings, by: { $0.accountKey })
        return accountHoldingsMap.values.reduce(into: []) { array, holdings in
            
            // holdings with invalid tickers will be assigned to a blank ("") asset class
            let assetHoldingsMap: AssetHoldingsMap = Dictionary(grouping: holdings,
                                                                by: { securityMap[$0.securityKey]?.assetKey ?? MAsset.emptyKey })
            
            let positions = consolidateByAsset(assetHoldingsMap,
                                               snapshotID: snapshotID,
                                               securityMap: securityMap,
                                               assetMap: assetMap)
            array.append(contentsOf: positions)
        }
    }
    
    static func consolidateByAsset(_ assetHoldingsMap: AssetHoldingsMap,
                                   snapshotID: SnapshotID,
                                   securityMap: SecurityMap,
                                   assetMap: AssetMap) -> [MValuationPosition] {
        assetHoldingsMap.reduce(into: []) { array, entry in
            let (assetKey, holdings) = entry
            
            guard let holding = holdings.first,
                  case let accountID = holding.accountID,
                  let asset = assetMap[assetKey]
            else { return }
            
            let totalBasis = holdings.reduce(0) { $0 + (($1.shareCount ?? 0) * ($1.shareBasis ?? 0)) }
            let marketValue = holdings.reduce(0) { $0 + (($1.shareCount ?? 0) * (securityMap[$1.securityKey]?.sharePrice ?? 0)) }
            let position = MValuationPosition(snapshotID: snapshotID,
                                              accountID: accountID,
                                              assetID: asset.assetID,
                                              totalBasis: totalBasis,
                                              marketValue: marketValue)
            array.append(position)
        }
    }
}

