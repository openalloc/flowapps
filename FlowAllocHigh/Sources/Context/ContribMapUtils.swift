//
//  ContribMapUtils.swift
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

// truncate the fixed contributions to match what's needed by the combined contributions
// fixed = min(combined, fixedRaw)
func getFixedContribMap(combinedContribMap: AssetValueMap,
                        fixedValueMap: AssetValueMap) -> AssetValueMap
{
    combinedContribMap.reduce(into: [:]) { map, entry in
        let (assetKey, combinedContrib) = entry
        let val = min(combinedContrib, fixedValueMap[assetKey] ?? 0)
        if val > 0 { map[entry.key] = val }
    }
}

// report the surplus from fixed holdings
func getFixedSurplusMap(fixedRawValueMap: AssetValueMap,
                        combinedRawTotal: Double,
                        netAllocMap: AssetValueMap) -> AssetValueMap
{
    netAllocMap.reduce(into: [:]) { map, entry in
        let (assetKey, targetPct) = entry
        guard targetPct > 0 else { return }
        let maxContrib = combinedRawTotal * targetPct
        let val = max(0, fixedRawValueMap[assetKey, default: 0] - maxContrib)
        if val > 0 { map[assetKey] = val }
    }
}

func getFixedContribSum(fixedValueMap: AssetValueMap,
                        combinedTotal: Double,
                        netAllocMap: AssetValueMap) -> Double
{
    netAllocMap.reduce(0) {
        let (assetKey, targetPct) = $1
        guard targetPct > 0 else { return $0 }
        let maxContrib = combinedTotal * targetPct
        let fixedContrib = fixedValueMap[assetKey, default: 0]
        return $0 + min(maxContrib, fixedContrib)
    }
}

/*
 Calculate the largest-possible portfolio size, which can include non-tradable accounts.

 Non-tradable accounts may have one (or more) positions in surplus, meaning that their value(s) exceed the target allocation.

 For example, the non-tradeable account holds 10% in smallcap, when the portfolio only requires 3%.  It's 7% in surplus, which will be orphaned, as the account isn't tradable.

 If we shrink the portfolio size to EXCLUDE the non-tradable accounts, they are entirely orphaned.

 Starting from zero-contribution of non-tradable accounts, expand until there's no longer any contribution to the allocation.

 */
func getNetCombinedTotal(fixedValueMap: AssetValueMap,
                         variableContribTotal: Double,
                         netAllocMap: AssetValueMap,
                         precision: Double = 0.05,
                         maxCount: Int = 20) -> Double
{
    let fixedTotal = fixedValueMap.reduce(0.0) { $0 + $1.value }
    let combinedTotal = fixedTotal + variableContribTotal

    //print("getNetCombinedTotal combinedRawTotal=\(combinedTotal.currency0()) variableContrib=\(variableContribTotal.currency0())")

    // starting at top of variable, keep increasing until contributions levels off, or we reach the raw combined limit
    var totalContrib = variableContribTotal

    var lastFixedContrib = 0.0
    var count = 0

    while totalContrib < combinedTotal, count < maxCount {
        let fixedContrib = getFixedContribSum(fixedValueMap: fixedValueMap,
                                              combinedTotal: totalContrib,
                                              netAllocMap: netAllocMap)

        //print("getNetCombinedTotal: fixedContrib=\(fixedContrib.currency0()) totalContrib=\(totalContrib.currency0()) count=\(count)")

        if abs(fixedContrib - lastFixedContrib) < precision {
            break
        }

        lastFixedContrib = fixedContrib

        totalContrib = variableContribTotal + fixedContrib + precision

        count += 1
    }

    return totalContrib
}
