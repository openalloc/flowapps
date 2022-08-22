//
//  MHolding+Maps.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

import AllocData


public extension MHolding {
    // obtain a unique list of asset classes for the specified holdings
    static func getAssetKeys(_ holdings: [MHolding], securityMap: SecurityMap) -> [AssetKey] {
        Set(holdings.compactMap {
            let securityKey = $0.securityKey
            guard securityKey.isValid
            else { return nil }

            // in case user hasn't populated all the assets in their securities
            guard let assetKey = securityMap[securityKey]?.assetKey,
                  assetKey.isValid
            else { return nil }

            return assetKey
        }).sorted()
    }

    static func getPresentValueMap(holdingsMap: AssetHoldingsMap, securityMap: SecurityMap) -> AssetValueMap {
        var map = AssetValueMap()
        for (assetKey, holdings) in holdingsMap {
            map[assetKey] = holdings.reduce(0) { $0 + ($1.getPresentValue(securityMap) ?? 0) }
        }
        return map
    }

    static func getHoldings(_ holdingsMap: AssetHoldingsMap) -> [MHolding] {
        holdingsMap.flatMap(\.value)
    }

    static func getAccountAssetHoldingsMap(accountKeys: [AccountKey],
                                           _ accountHoldingsMap: AccountHoldingsMap,
                                           _ securityMap: SecurityMap) -> AccountAssetHoldingsMap
    {
        let maps: [AssetHoldingsMap] = accountKeys.map { getAssetHoldingsMap(accountKey: $0, accountHoldingsMap, securityMap) }
        return Dictionary(uniqueKeysWithValues: zip(accountKeys, maps))
    }

    static func getAssetHoldingsMap(accountKey: AccountKey,
                                    _ accountHoldingsMap: AccountHoldingsMap,
                                    _ securityMap: SecurityMap) -> AssetHoldingsMap
    {
        guard let holdings = accountHoldingsMap[accountKey]
        else { return [:] }
        return getAssetHoldingsMap(holdings, securityMap)
    }

    // NOTE that holdings are sorted by gainLoss (ascending) to avoid realizing gains
    static func getAssetHoldingsMap(_ holdings: [MHolding],
                                    _ securityMap: SecurityMap) -> AssetHoldingsMap
    {
        holdings
            .sorted(by: { ($0.getGainLoss(securityMap) ?? 0) < ($1.getGainLoss(securityMap) ?? 0) })
            .reduce(into: [:]) { map, holding in
                let tickerKey = holding.securityKey
                guard let security = securityMap[tickerKey] else { return }
                map[security.assetKey, default: []].append(holding)
            }
    }
}
