//
//  HighResult+Allocate.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import os

import SimpleTree

import FlowAllocLow
import FlowBase

//@available(macOS 11.0, iOS 14.0, *)
//let slog = Logger(subsystem: "app.flowallocator", category: "Summarize")

extension HighResult {
    public static func allocateRebalanceSummarize(_ ax: HighContext,
                                                  _ ap: BaseParams) throws -> HighResult
    {
        guard ap.accountKeys.count > 0, ap.assetKeys.count > 0
        else {
            throw AllocLowError2.invalidParams("no accountNumbers or no assetClasses")
        }

        let accountAllocMap = try allocate(ax, ap)

        // slog.debug("\(#function) accountAllocMap=\(accountAllocMap)")

        let accountHoldingsSummaryMap =
            ax.isGroupRelatedHoldings
                ? ax.mergedVariableAccountHoldingsSummaryMap
                : ax.baseAccountHoldingsSummaryMap

        // LOW-LEVEL function unaware of asset grouping magic
        let accountRebalanceMap = getAccountRebalanceMap(accountKeys: ax.allocatingAccountKeys,
                                                         accountAllocMap: accountAllocMap,
                                                         accountHoldingsSummaryMap: accountHoldingsSummaryMap)

        // slog.debug("\(#function) accountRebalanceMap=\(accountRebalanceMap)")

        // consolidate the rebalance, if reduceRebalance == true
        let accountReducerMap: AccountReducerMap =
            ax.isReduceRebalance
                ? consolidateRebalance(accountHoldingsSummaryMap, ax.rawRankedTargetsMap, accountRebalanceMap)
                : [:]

        // slog.debug("\(#function) accountReducerMap=\(accountReducerMap)")

        let summary = summarize(ax, ap,
                                accountAllocMap: accountAllocMap,
                                accountRebalanceMap: accountRebalanceMap,
                                accountReducerMap: accountReducerMap)

        // slog.debug("\(#function) summary=\(summary)")

        return summary
    }

    internal static func allocate(_ ax: HighContext, _ ap: BaseParams) throws -> AccountAssetValueMap {

        let allocMap = AssetValue.getAssetValueMap(from: ax.allocatingAllocs)

        // TODO: may benefit from further optimization
        let orderedAllocs = AssetValue.getAssetValues(from: allocMap, orderBy: ap.assetKeys)

        return try getAccountAllocationMap(allocs: orderedAllocs,
                                           accountKeys: ap.accountKeys,
                                           allocFlowMode: ap.flowMode,
                                           assetAccountLimitMap: ax.assetAccountLimitMap,
                                           accountUserVertLimitMap: ax.accountUserVertLimitMap,
                                           accountUserAssetLimitMap: ax.accountUserAssetLimitMap,
                                           accountCapacitiesMap: ax.accountCapacitiesMap,
                                           isStrict: ap.isStrict)
    }

    // rollup the rebalances for each account
    internal static func consolidateRebalance(_ accountHoldingsSummaryMap: AccountAssetHoldingsSummaryMap,
                                              _ rawRankedTargetsMap: DeepRelationsMap,
                                              _ accountRebalanceMap: AccountRebalanceMap) -> AccountReducerMap
    {
        accountRebalanceMap.reduce(into: [:]) { map, entry in
            let accountKey = entry.key
            let rebalanceMap = entry.value
            guard let holdingsSummaryMap = accountHoldingsSummaryMap[accountKey]
            else { return }
            let orderBy = { (holdingsSummaryMap[$0]?.gainLoss ?? 0) > (holdingsSummaryMap[$1]?.gainLoss ?? 0) }
            let accountReducerMap = generateReducerMap(rebalanceMap, rawRankedTargetsMap, orderBy: orderBy)
            guard !accountReducerMap.isEmpty else { return }
            map[accountKey] = accountReducerMap
        }
    }

    internal static func summarize(_ ax: HighContext,
                                   _ ap: BaseParams,
                                   accountAllocMap: AccountAssetValueMap,
                                   accountRebalanceMap: AccountRebalanceMap,
                                   accountReducerMap: AccountReducerMap) -> HighResult
    {
        var transactionCount: Int = 0
        var netTaxGains: Double = 0
        var absTaxGains: Double = 0
        var saleVolume: Double = 0
        var saleWashAmount: Double = 0

        for (accountKey, rebalanceMap) in accountRebalanceMap {
            guard let assetHoldingsMap = ax.mergedAccountAssetHoldingsMap[accountKey],
                  let account = ax.strategiedAccountMap[accountKey]
            else { continue }

            let netRebalanceMap: AssetValueMap = {
                if let reducerMap = accountReducerMap[accountKey] {
                    return applyReducerMap(rebalanceMap, reducerMap, preserveZero: false)
                }
                return rebalanceMap
            }()

            // TODO: optimize
            let sales = Sale.getSales(netRebalanceMap,
                                      assetHoldingsMap,
                                      ax.securityMap,
                                      minimumSaleAmount: Double(ax.settings.minimumSaleAmount),
                                      minimumPositionValue: Double(ax.settings.minimumPositionValue))

            if account.isTaxable {
                netTaxGains += Sale.getNetGainLossSum(ax, sales)
                absTaxGains += Sale.getAbsGainsSum(ax, sales)
            }
            transactionCount += netRebalanceMap.count
            saleVolume += netRebalanceMap.reduce(0) { $0 + max(0, -1 * $1.value) } // flip sales to positive with -1

            // NOTE because user can avoid creating a wash when making a purchase,
            // we don't have to track 'purchase wash' during optimization. Note that
            // user should be warned of potential wash if buying same (or similar
            // security) that is being sold.

            // Losing sale(s) will have a wash if recent purchases for the securityID (and similar) show an unrealized gain.
            saleWashAmount += Sale.getWashAmount(sales,
                                                 recentPurchasesMap: ax.recentPurchasesMap,
                                                 securityMap: ax.securityMap,
                                                 trackerSecuritiesMap: ax.trackerSecuritiesMap)
        }

        return HighResult(accountKeys: ap.accountKeys,
                           assetKeys: ap.assetKeys,
                           flowMode: ap.flowMode,
                           accountAllocMap: accountAllocMap,
                           accountRebalanceMap: accountRebalanceMap,
                           accountReducerMap: accountReducerMap,
                           transactionCount: transactionCount,
                           netTaxGains: netTaxGains,
                           absTaxGains: absTaxGains,
                           saleVolume: saleVolume,
                           washAmount: saleWashAmount)
    }
}
