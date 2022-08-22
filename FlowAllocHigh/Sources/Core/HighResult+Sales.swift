//
//  HighResult+Sales.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

import FlowAllocLow
import FlowBase


public extension HighResult {
    func getSaleMap(_ ax: HighContext, accountKey: AccountKey) -> SaleMap {
        guard let rebalanceMap = accountRebalanceMap[accountKey],
              let assetHoldingsMap = ax.mergedAccountAssetHoldingsMap[accountKey]
        else { return [:] }
        return Sale.getSaleMap(rebalanceMap, assetHoldingsMap, ax.securityMap,
                               minimumSaleAmount: Double(ax.settings.minimumSaleAmount),
                               minimumPositionValue: Double(ax.settings.minimumPositionValue))
    }

    // TODO may need tests
    func getAccountSalesMap(_ ax: HighContext) -> AccountSalesMap {
        accountKeys.reduce(into: [:]) { map, accountKey in
            guard let rebalanceMap = self.accountRebalanceMap[accountKey],
                  let assetHoldingsMap = ax.mergedAccountAssetHoldingsMap[accountKey]
            else { return }
            let sales = Sale.getSales(rebalanceMap,
                                      assetHoldingsMap,
                                      ax.securityMap,
                                      minimumSaleAmount: Double(ax.settings.minimumSaleAmount),
                                      minimumPositionValue: Double(ax.settings.minimumPositionValue))
            map[accountKey] = sales
        }
    }

    func getPurchaseMap(_ ax: HighContext, accountKey: AccountKey) -> PurchaseMap {
        guard let rebalanceMap = accountRebalanceMap[accountKey]
        else { return [:] }
        return Purchase.getPurchaseMap(rebalanceMap: rebalanceMap)
    }

    func getAccountPurchasesMap(_ ax: HighContext) -> AccountPurchasesMap {
        accountKeys.reduce(into: [:]) { map, accountKey in
            guard let rebalanceMap = self.accountRebalanceMap[accountKey]
            else { return }
            let purchases = Purchase.getPurchases(rebalanceMap: rebalanceMap)
            map[accountKey] = purchases
        }
    }

    static func getLosingSalesMap(_ ax: HighContext, _ accountSalesMap: AccountSalesMap) -> AssetSalesMap {
        let losingSales: [Sale] = accountSalesMap.reduce(into: []) {
            guard let account = ax.strategiedAccountMap[$1.key],
                  account.isTaxable,
                  let sales = accountSalesMap[$1.key]
            else { return }
            let losingSales_ = sales.filter { $0.netGainLoss < 0 }
            $0.append(contentsOf: losingSales_)
        }
        return Dictionary(grouping: losingSales, by: { $0.assetKey })
    }
}
