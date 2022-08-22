//
//  MTransaction+Utils.swift
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

public extension MTransaction {
    static func getAssetRecentPurchaseMap(assetBuyTxnsMap: AssetTxnsMap) -> AssetTickerAmountMap {
        assetBuyTxnsMap.reduce(into: [:]) { map, entry in
            let (assetKey, txns) = entry
            map[assetKey] = getRecentTickerPurchaseMap(recentBuyTxns: txns)
        }
    }

    // NOTE: unknown accounts are considered taxable
    static func getAssetNetRealizedGainMap(assetSellTxnsMap: AssetTxnsMap, accountMap: AccountMap) -> AssetTickerAmountMap {
        assetSellTxnsMap.reduce(into: [:]) { map, entry in
            let (assetKey, txns) = entry
            map[assetKey] = getNetRealizedGainMap(recentSellTxns: txns, accountMap: accountMap)
        }
    }
}

extension MTransaction {    
    static func getAssetTxnsMap(_ txns: [MTransaction], _ securityMap: SecurityMap) -> AssetTxnsMap {
        txns.reduce(into: [:]) { map, txn in
            guard let assetKey = securityMap[txn.securityKey]?.assetKey
            else { return }
            map[assetKey, default: []].append(txn)
        }
    }

    static func getRecentPurchasesMap(recentBuyTxns: [MTransaction]) -> RecentPurchasesMap {
        recentBuyTxns.reduce(into: [:]) { map, txn in
            guard txn.isBuy else { return } // ensure it's a purchase
            guard txn.securityKey.isValid else { return } // consider only well-formed security keys
            let purchaseInfo = PurchaseInfo(tickerKey: txn.securityKey, shareCount: txn.shareCount, shareBasis: txn.sharePrice ?? 0)
            map[txn.securityKey, default: []].append(purchaseInfo)
        }
    }

    static func getRecentTickerPurchaseMap(recentBuyTxns: [MTransaction]) -> TickerAmountMap {
        recentBuyTxns.reduce(into: [:]) { map, txn in
            guard txn.isBuy else { return } // ensure it's a purchase
            guard txn.securityKey.isValid else { return } // consider only well-formed security keys
            let amount = txn.shareCount * (txn.sharePrice ?? 0)
            map[txn.securityKey, default: 0] += amount
        }
    }

    // obtain recent sales in asset class that realized a gain (or loss)
    // NOTE: unknown accounts are considered taxable
    static func getNetRealizedGainMap(recentSellTxns: [MTransaction], accountMap: AccountMap) -> TickerAmountMap {
        recentSellTxns.reduce(into: [:]) { map, txn in
            guard txn.isSell else { return } // ensure it's a sale
            guard txn.securityKey.isValid else { return } // consider only well-formed security keys
            
            // if account is known, and known to be non-taxable, exclude it from results
            if let account = accountMap[txn.accountKey],
               !account.isTaxable {
                return
            }
            
            let netGain = (txn.realizedGainShort ?? 0) + (txn.realizedGainLong ?? 0)
            guard netGain != 0 else { return }
            
            map[txn.securityKey, default: 0] += netGain
        }
    }
}
