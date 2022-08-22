//
//  HoldingsSummary+Utils.swift
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
    static func getSummary(_ holdings: [MHolding], _ securityMap: SecurityMap) -> HoldingsSummary {
        holdings.reduce(HoldingsSummary()) {
            guard $1.securityKey.isValid,
                  let security = securityMap[$1.securityKey],
                  let pv = $1.getPresentValue(securityMap),
                  pv > 0,
                  security.assetKey.isValid
            else { return $0 }

            let costBasis_ = $1.costBasis ?? 0 // assume it was a gift

            var tsm = $0.tickerShareMap
            if let _shareCount = $1.shareCount {
                tsm[$1.securityKey, default: 0] += _shareCount
            }
            
            return HoldingsSummary(presentValue: $0.presentValue + pv,
                                   costBasis: $0.costBasis + costBasis_,
                                   count: $0.count + 1,
                                   tickerShareMap: tsm)
        }
    }

    static func getSummary(_ assetHoldingsMap: AssetHoldingsMap, _ securityMap: SecurityMap) -> HoldingsSummary {
        let holdings = MHolding.getHoldings(assetHoldingsMap)
        return getSummary(holdings, securityMap)
    }

    static func getAssetSummaryMap(_ holdings: [MHolding],
                                   _ securityMap: SecurityMap) -> AssetHoldingsSummaryMap
    {
        let assetHoldingsMap: [AssetKey: [MHolding]] = MHolding.getAssetHoldingsMap(holdings, securityMap)

        let assetSummaryTuples: [(AssetKey, HoldingsSummary)] = assetHoldingsMap.compactMap { assetKey, holdings in
            let summary = getSummary(holdings, securityMap)
            return (assetKey, summary)
        }

        return Dictionary(uniqueKeysWithValues: assetSummaryTuples)
    }

    static func getAssetSummaryMap(_ accountKey: AccountKey,
                                   _ accountHoldingsMap: AccountHoldingsMap,
                                   _ securityMap: SecurityMap) -> AssetHoldingsSummaryMap
    {
        guard let holdings = accountHoldingsMap[accountKey] else { return [:] }
        return getAssetSummaryMap(holdings, securityMap)
    }

    static func getAccountAssetSummaryMap(_ accountKeys: [AccountKey],
                                          _ accountHoldingsMap: AccountHoldingsMap,
                                          _ securityMap: SecurityMap) -> AccountAssetHoldingsSummaryMap
    {
        let maps: [AssetHoldingsSummaryMap] = accountKeys.map { getAssetSummaryMap($0, accountHoldingsMap, securityMap) }
        return Dictionary(uniqueKeysWithValues: zip(accountKeys, maps))
    }

    static func getAccountSummaryMap(_: [AccountKey],
                                     _ accountHoldingsMap: [AccountKey: [MHolding]],
                                     _ securityMap: SecurityMap) -> AccountHoldingsSummaryMap
    {
        accountHoldingsMap.reduce(into: [:]) { map, entry in
            let (accountKey, holdings) = entry
            map[accountKey] = HoldingsSummary.getSummary(holdings, securityMap)
        }
    }
}
