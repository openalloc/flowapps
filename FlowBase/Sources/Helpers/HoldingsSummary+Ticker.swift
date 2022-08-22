//
//  HoldingsSummary+Ticker.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

import AllocData

public extension HoldingsSummary {
    
    static func getTickerSummaryMap(_ holdings: [MHolding], _ securityMap: SecurityMap) -> TickerHoldingsSummaryMap {
        let tickerHoldingsMap: [SecurityKey: [MHolding]] = Dictionary(grouping: holdings, by: { $0.securityKey })
        let tickerSummaryTuples: [(SecurityKey, HoldingsSummary)] = tickerHoldingsMap.compactMap { tickerKey, holdings in
            let summary = HoldingsSummary.getSummary(holdings, securityMap)
            return (tickerKey, summary)
        }
        return Dictionary(uniqueKeysWithValues: tickerSummaryTuples)
    }

    static func getAssetTickerSummaryMap(_ assetHoldingsMap: AssetHoldingsMap, _ securityMap: SecurityMap) -> AssetTickerHoldingsSummaryMap {
        assetHoldingsMap.reduce(into: [:]) { map, entry in
            let assetKey = entry.key
            let assetHoldings = entry.value
            let tickerSummaryMap: [SecurityKey: HoldingsSummary] = getTickerSummaryMap(assetHoldings, securityMap)
            map[assetKey] = tickerSummaryMap
        }
    }
}
