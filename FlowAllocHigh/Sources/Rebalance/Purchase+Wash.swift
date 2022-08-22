//
//  Purchase+Wash.swift
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

public extension Purchase {
    /// Given recent history of realized losses on an asset, how much wash is (potentially) produced by a purchase of that asset?
    func getWashAmount(assetSellTxnsMap: AssetTxnsMap) -> Double {
        guard let recentSellTxns = assetSellTxnsMap[assetKey]
        else { return 0 }
        return Purchase.getPurchaseWash(recentSellTxns, buyAmount: amount)
    }
}

extension Purchase {
    /// Given recent history of realized losses on an asset, how much wash is (potentially) produced by a purchase of that asset?
    static func getPurchaseWash(_ recentTxns: [MTransaction],
                                buyAmount: Double) -> Double
    {
        let totalRealizedGain = recentTxns.reduce(0.0) {
            guard case let shareCount = $1.shareCount,
                  shareCount < 0 else { return $0 } // filter out non-sales
            let realizedGainShort = $1.realizedGainShort ?? 0
            let realizedGainLong = $1.realizedGainLong ?? 0
            return $0 + realizedGainShort + realizedGainLong // assume net realized gain cancels out net realized loss, and verse-visa
        }
        return min(0, max(-buyAmount, totalRealizedGain))
    }
}
