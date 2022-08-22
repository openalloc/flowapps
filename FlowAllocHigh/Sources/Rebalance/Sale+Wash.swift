//
//  Sale+Wash.swift
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


public extension Sale {
    static func getNetGainLossSum(_: HighContext, _ sales: [Sale]) -> Double {
        sales.reduce(0) { $0 + $1.netGainLoss }
    }

    static func getAbsGainsSum(_: HighContext, _ sales: [Sale]) -> Double {
        sales.reduce(0) { $0 + ($1.netGainLoss > 0 ? $1.netGainLoss : 0) }
    }

    static func getWashAmount(_ sales: [Sale],
                              recentPurchasesMap: RecentPurchasesMap,
                              securityMap: SecurityMap,
                              trackerSecuritiesMap: TrackerSecuritiesMap) -> Double
    {
        sales.reduce(0) { $0 + $1.getWashAmount(recentPurchasesMap: recentPurchasesMap,
                                                securityMap: securityMap,
                                                trackerSecuritiesMap: trackerSecuritiesMap) }
    }

    // Losing sale(s) will have a wash if recent purchases for the securityID (and similar) show an unrealized gain.
    // Note that RecentPurchasesMap should have similar securities (SPY, VOO, etc. following same index) share the same history
    func getWashAmount(recentPurchasesMap: RecentPurchasesMap,
                       securityMap: SecurityMap,
                       trackerSecuritiesMap: TrackerSecuritiesMap) -> Double
    {
        let netGainLoss_ = netGainLoss
        guard netGainLoss_ < 0 else { return 0 } // only consider losses

        return liquidateHoldings.reduce(0.0) {
            let securityKey = $1.holding.securityKey
            guard securityKey.isValid else { return $0 }

            let securityKeys: [SecurityKey] = {
                if let security = securityMap[securityKey],
                   security.trackerKey.isValid,
                   let trackedSecurities = trackerSecuritiesMap[security.trackerKey],
                   trackedSecurities.count > 0
                {
                    return trackedSecurities.map(\.primaryKey)
                }
                return [securityKey]
            }()

            // collect all recent purchases of SPY, VOO, etc. to compare to sale of S&P500 ETF
            let recentPurchases: [PurchaseInfo] = recentPurchasesMap.reduce(into: []) {
                if securityKeys.contains($1.key) {
                    return $0.append(contentsOf: $1.value)
                }
            }

            return $0 + Sale.getSaleWash(recentPurchases, netGainLoss: netGainLoss_)
        }
    }

    // return as a non-negative value (0...)
    internal static func getSaleWash(_ recentPurchases: [PurchaseInfo],
                                     netGainLoss: Double) -> Double
    {
        guard netGainLoss < 0 else { return 0 } // only consider losses

        let purchasesBasis = recentPurchases.reduce(0) { $0 + $1.basisValue }

        return -1 * max(-purchasesBasis, netGainLoss)
    }
}
