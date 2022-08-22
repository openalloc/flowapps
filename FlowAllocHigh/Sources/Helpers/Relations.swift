//
//  Relations.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

import SimpleTree
import AllocData

import FlowAllocLow
import FlowBase

public extension Relations {
    
    /// map each 'held' asset key to its top-ranked 'target' asset key
    static func getTopRankedTargetMap(rankedTargetsMap: DeepRelationsMap) -> ClosestTargetMap {
        rankedTargetsMap.reduce(into: [:]) { map, entry in
            let (holdingAssetKey, rankedTargetKeys) = entry
            guard let topTarget = rankedTargetKeys.first else { return }
            map[holdingAssetKey] = topTarget
        }
    }
    
    /// map the held asset keys (value) to their top-ranked target asset key (key)
    // This inverts the topRankedTargetMap dictionary
    //  [topRankedTargetAssetKey: heldAssetKeys]
    static func getTopRankedHeldMap(topRankedTargetMap: ClosestTargetMap) -> DeepRelationsMap {
        Dictionary(grouping: topRankedTargetMap.keys, by: { topRankedTargetMap[$0]! })
    }

    /// map each 'held' asset key to a ranked list of 'target' asset keys
    // NOTE there may be overlap in the held assetKeys, as this is a raw translation of the relatedTree.
    // Starts with self, then nearest parent, grandparent, and so on until root. Then children, in a breadth-first traversal.
    static func getRawRankedTargetsMap(heldAssetKeySet: AssetKeySet,
                                              targetAssetKeySet: AssetKeySet,
                                              relatedTree: AssetKeyTree) -> DeepRelationsMap
    {
        heldAssetKeySet.reduce(into: [:]) { map, heldAssetKey in
            let buffer = getRawRelated(assetKey: heldAssetKey, relatedTree: relatedTree)
            let filtered = buffer.filter { targetAssetKeySet.contains($0) } //&& heldAssetKey != $0 }
            guard filtered.count > 0 else { return }
            map[heldAssetKey] = filtered
        }
    }
        
    /// map each 'target' asset key to sorted list of 'held' asset keys
    static func getRawRelatedHeldMap(heldAssetKeySet: AssetKeySet,
                                            targetAssetKeySet: AssetKeySet,
                                            relatedTree: AssetKeyTree) -> DeepRelationsMap {
        targetAssetKeySet.reduce(into: [:]) { map, targetAssetKey in
            let buffer = getRawRelated(assetKey: targetAssetKey, relatedTree: relatedTree)
            let filtered = buffer.filter { heldAssetKeySet.contains($0) }
            guard filtered.count > 0 else { return }
            map[targetAssetKey] = filtered.sorted()
        }
    }
    
    private static func getRawRelated(assetKey: AssetKey, relatedTree: AssetKeyTree) -> [AssetKey] {
        var buffer = [assetKey]
        if let node = relatedTree.getFirst(for: assetKey) {
            let parentTargets = node.getParentValues(excludeValues: Relations.rootSet)
            if parentTargets.count > 0 {
                buffer.append(contentsOf: parentTargets)
            }
            let childTargets = node.getChildValues()
            if childTargets.count > 0 {
                buffer.append(contentsOf: childTargets)
            }
        }
        return buffer
    }
    
    // Given an arbitrary set of holdings (across accounts), filter out those which cannot fit within the target asset classes.
    // Keys of resulting map are the closest related asset class for each of the holdings.
    // NOTE that unused holdings are not returned. That must be resolved in the rebalance.
    static func getDistilledMap(_ holdings: [MHolding],
                                       topRankedTargetMap: ClosestTargetMap, // nearest targetACs, if any
                                       securityMap: SecurityMap) -> DistillationResult
    {
        // .sorted(by: { $0.getGainLoss(securityMap) ?? 0 < $1.getGainLoss(securityMap) ?? 0 })
        holdings.reduce(into: (accepted: [:], rejected: [:])) { map, holding in
            
            guard holding.securityKey.isValid,
                  let security = securityMap[holding.securityKey],
                  case let holdingAssetKey = security.assetKey,
                  holdingAssetKey.isValid
            else { return }
            
            if let targetAssetKey = topRankedTargetMap[holdingAssetKey] {
                // may be multiple matches, but first should be strongest (includes the holding's assetKey, if it's a target)
                map.accepted[targetAssetKey, default: []].append(holding)
            } else {
                // no fit for the holding among target asset classes
                map.rejected[holdingAssetKey, default: []].append(holding)
            }
        }
    }
}
