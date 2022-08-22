//
//  RebalanceUtils.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import os

import FlowBase
import AllocData

public func getAccountRebalanceMap(accountKeys: [AccountKey],
                                   accountAllocMap: AccountAssetValueMap,
                                   accountHoldingsSummaryMap: AccountAssetHoldingsSummaryMap) -> AccountRebalanceMap
{
    accountKeys.reduce(into: [:]) { map, accountKey in
        guard let allocMap = accountAllocMap[accountKey],
              let holdingsSummaryMap = accountHoldingsSummaryMap[accountKey]
        else { return }

        // total presentValue for holdings in all asset classes for the account
        let holdingsPresentValue = holdingsSummaryMap.values.reduce(0) { $0 + $1.presentValue }

        map[accountKey] = getRebalanceMap(allocMap,
                                          holdingsSummaryMap,
                                          holdingsPresentValue)
    }
}

// ORIGINAL - FAST! (1.72s)
public func getRebalanceMap(_ allocMap: AssetValueMap,
                            _ holdingsSummaryMap: AssetHoldingsSummaryMap,
                            _ holdingsPresentValue: Double) -> RebalanceMap
{
    let amountEpsilon: Double = 0.001 // within nearest tenth of 'penny'

    var zPairs = [(AssetKey, Double)]()
    zPairs.reserveCapacity(allocMap.count)

    func transact(assetKey: AssetKey, targetAmount: Double, holdingValue: Double) {
        // positive: purchase/acquire
        // negative: sale/liquidate
        let diff = targetAmount - holdingValue

        if diff.isNotEqual(to: 0, accuracy: amountEpsilon) {
            zPairs.append((assetKey, diff))
        }
    }

    for (assetKey, targetPct) in allocMap {
        guard assetKey != MAsset.cashAssetKey else { continue }

        transact(assetKey: assetKey,
                 targetAmount: targetPct * holdingsPresentValue,
                 holdingValue: holdingsSummaryMap[assetKey]?.presentValue ?? 0)
    }

    // sell off the orphans
    for (assetKey, holdingsSummary) in holdingsSummaryMap {
        guard allocMap[assetKey] == nil,
              assetKey != MAsset.cashAssetKey
        else { continue }

        transact(assetKey: assetKey,
                 targetAmount: 0,
                 holdingValue: holdingsSummary.presentValue)
    }

    return Dictionary(uniqueKeysWithValues: zPairs)
}
