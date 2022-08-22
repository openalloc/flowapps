//
//  Rollup.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import SimpleTree

import FlowAllocLow
import FlowBase


// simplify an asset allocation by 'rolling up' thinner slices into thicker ones
// NOTE: does not normalize or validate the allocation map. You may wish to do this separately.
public func rollup(_ relatedTree: AssetKeyTree,
                   _ sliceMapIn: AssetValueMap,
                   threshold: Double = 0.1,
                   epsilon: Double = 0.0001) throws -> RollupResult
{
    var sliceMap = sliceMapIn

    let treeAssetKeys = relatedTree.getSelfAndChildValues()

    guard treeAssetKeys.isUnique else {
        throw FlowBaseError.validationFailure("Duplicate asset class found.")
    }

    guard sliceMap.map(\.key).allSatisfy({ treeAssetKeys.contains($0) }) else {
        throw FlowBaseError.validationFailure("Asset class not found (rollup).")
    }

    // transformation

    // Scan through slices, starting with the thinnest one, merging smaller slices into larger ones until all are over threshold.

    var rollupMap = RollupMap() // parent: [children]

    // from the thinnest to the thickest, with assetKey as secondary key
    for (assetKey, targetPct) in sliceMap.sorted(by: {
        $0.value < $1.value ||
            ($0.value.isEqual(to: $1.value, accuracy: epsilon) && $0.key < $1.key)
    }) {
        guard targetPct.isLessThanOrEqual(to: threshold, accuracy: epsilon),
              let node = relatedTree.getFirst(for: assetKey)
        else { continue }

        if targetPct == 0 {
            sliceMap.removeValue(forKey: assetKey)
            continue
        }

        for parentAC in node.getParentValues() {
            // is there another slice that can absorb this value?
            if let parentTargetPct = sliceMap[parentAC] {
                // transfer targetPct to the parent slice (and remove empty one)
                sliceMap[parentAC] = parentTargetPct + targetPct
                sliceMap.removeValue(forKey: assetKey)

                // consolidate our children, if any, under parentAC
                // e.g., micro, small, and mid all map to large
                var children = rollupMap[parentAC] ?? []
                if let other = rollupMap[assetKey] {
                    children.append(contentsOf: other)
                    rollupMap.removeValue(forKey: assetKey)
                }
                children.append(assetKey)
                rollupMap[parentAC] = children
                break
            }
        }
    }

    return (sliceMap, rollupMap) // describes how the mappings played out
}

// sum of contribution of the specified assetClasses to an allocation
public func getAllocationSum(assetKeys: [AssetKey], allocMap: AssetValueMap) -> Double {
    assetKeys.reduce(0) { $0 + (allocMap[$1] ?? 0) }
}

// this is the base (unmodified) allocation, assuming full contribution
public func getAllocationMap(allocationSum: Double,
                             assetKeys: [AssetKey],
                             allocMap: AssetValueMap) -> AssetValueMap
{
    let fixedPcts = assetKeys.map { (allocMap[$0] ?? 0) / allocationSum }
    return Dictionary(uniqueKeysWithValues: zip(assetKeys, fixedPcts))
}
