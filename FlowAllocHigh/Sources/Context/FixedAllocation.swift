//
//  FixedAllocation.swift
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

public typealias FixedAllocationMapPair = (allocated: AccountAssetAmountMap, orphans: AccountAssetAmountMap)

func allocateFixed(accounts: [MAccount],
                   fixedNetContribMap: AssetValueMap,
                   accountHoldingsSummaryMap: AccountAssetHoldingsSummaryMap,
                   topRankedTargetMap: ClosestTargetMap,
                   epsilon: Double = 0.0001) -> FixedAllocationMapPair
{
    //print(AssetValue.describe(fixedNetContribMap, prefix: "fixedNetContribMap", style: .currency2))

    var remainingAmountsMap = fixedNetContribMap // remaining to allocate among asset classes in fixed accounts
    var accountAllocatedMap = AccountAssetAmountMap()
    var accountOrphanedMap = AccountAssetAmountMap()

    for accountKey in accounts.map(\.primaryKey) {
        guard let summaryMap = accountHoldingsSummaryMap[accountKey] else { continue }

        var allocatedMap = AssetValueMap()
        var orphanedMap = AssetValueMap()

        // use the sort to avoid non-deterministic behavior
        for (assetKey, holdingsSummary) in summaryMap { // .sorted(by: { $0.value.gainLoss < $1.value.gainLoss }) {
            let holdingPV = holdingsSummary.presentValue
            let netAssetKey = topRankedTargetMap[assetKey] ?? assetKey // pacific -> intl, total -> lc, em -> intl, intlbond -> intlbond (no key)
            let remainingPV = remainingAmountsMap[netAssetKey] ?? 0
            let diff = holdingPV - remainingPV
            if diff.isGreater(than: 0, accuracy: epsilon) {
                // We're in surplus: holding MORE than is remaining to be allocated.
                // There will be an orphan.
                // remainingPV for this assetID is closed (to 0)
                var orphaned = orphanedMap[netAssetKey] ?? 0.0
                orphaned += diff
                orphanedMap[netAssetKey] = orphaned
            }

            let nuRemaining = max(0, -diff)
            remainingAmountsMap[netAssetKey] = nuRemaining

            let nuAllocated = min(holdingPV, remainingPV)

            // NOTE including the following line may cause StrategyCells to be omitted from non-trading accounts
            //guard nuAllocated.isGreater(than: 0, accuracy: epsilon) else { continue }

            // it's okay to have unallocated account (that's active) where we don't show any data
            allocatedMap[netAssetKey, default: 0] += nuAllocated
        }

        if !allocatedMap.isEmpty {
            accountAllocatedMap[accountKey] = allocatedMap
        }
        if !orphanedMap.isEmpty {
            accountOrphanedMap[accountKey] = orphanedMap
        }
    }

    //print(AssetValue.describe(accountAllocatedMap, prefix: "accountAllocatedMap", style: .currency2))

    return (allocated: accountAllocatedMap, orphans: accountOrphanedMap)
}
