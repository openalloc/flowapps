//
//  HoldingsSummary+Map.swift
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


public extension HoldingsSummary {
    
    // TODO: may need tests
    static func getAccountAssetHoldingsSummaryMap(_ assetHoldingsMap: AssetHoldingsMap,
                                                  _ securityMap: SecurityMap) -> AccountAssetHoldingsSummaryMap
    {
        typealias TupleA = (assetKey: AssetKey, holding: MHolding)
        typealias TupleB = (AccountKey, AssetHoldingsSummaryMap)
        typealias TupleC = (AssetKey, HoldingsSummary)

        let tuples: [TupleA] = assetHoldingsMap.flatMap { assetKey, holdings in
            holdings.map { (assetKey, $0) }
        }

        let accountTuplesMap: [AccountKey: [TupleA]] = Dictionary(grouping: tuples, by: { $0.holding.accountKey })

        let tuplesB: [TupleB] = accountTuplesMap.compactMap { accountKey, tuples in

            let assetTuplesMap: [AssetKey: [TupleA]] = Dictionary(grouping: tuples, by: { $0.assetKey })

            let assetSummaryTuple: [TupleC] = assetTuplesMap.compactMap { assetKey, tuples in
                let holdings = tuples.map(\.holding)
                let holdingsSummary = HoldingsSummary.getSummary(holdings, securityMap)
                return (assetKey, holdingsSummary)
            }

            let assetSummaryMap = Dictionary(uniqueKeysWithValues: assetSummaryTuple)

            return (accountKey, assetSummaryMap)
        }

        return Dictionary(uniqueKeysWithValues: tuplesB)
    }

    static func getAssetHoldingsSummaryMap(_ assetHoldingsMap: AssetHoldingsMap,
                                           _ securityMap: SecurityMap) -> AssetHoldingsSummaryMap
    {
        let tuples: [(AssetKey, HoldingsSummary)] = {
            assetHoldingsMap.map { assetKey, holdings in
                let summary = HoldingsSummary.getSummary(holdings, securityMap)
                return (assetKey, summary)
            }
        }()
        return Dictionary(uniqueKeysWithValues: tuples)
    }
}
