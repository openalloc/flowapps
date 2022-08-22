//
//  Reducer.swift
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


public struct ReducerPair: Hashable {
    public var left: AssetKey // adding during apply
    public var right: AssetKey // subtracting during apply

    internal init(_ lhs: AssetKey, _ rhs: AssetKey) {
        left = lhs
        right = rhs
    }

    var mirror: ReducerPair {
        ReducerPair(right, left)
    }
}

extension ReducerPair: Comparable {
    public static func < (lhs: ReducerPair, rhs: ReducerPair) -> Bool {
        lhs.left < rhs.left ||
            (lhs.left == rhs.left && lhs.right < rhs.right)
    }
}

/*
 Generate target rebalance amounts by asset class.

 Goal is to reduce trading costs by retaining holdings whose asset classes are closely related to those we'd otherwise sell.

 E.g., if we already hold SMALL CAP, there is no need to liquidate it to acquire SMALL CAP VALUE to meet the allocation.

 CASE #1:

 Holding:
 SMALL CAP (VB)          $100

 Target:
 SMALL CAP VALUE (VBR)   $200

 RebalanceMap should reflect keeping the VB and acquiring $100 of VBR.

 CASE #2:

 Holding:
 SMALL CAP (VB)          $100

 Target:
 SMALL CAP VALUE         $50

 RebalanceMap should reflect selling $50 of VB and NOT acquiring ANY VBR.

 ** Important exception: if BOTH asset classes are present as separate allocation targets, treat them independently.
 */
public func generateReducerMap(_ rebalanceMap: AssetValueMap,
                               _ rawRankedTargetsMap: DeepRelationsMap,
                               orderBy: (AssetKey, AssetKey) -> Bool) -> ReducerMap
{
    var rbmap = rebalanceMap // used to track the remaining rebalance

    // filter: include only sales
    // map: by liquidating AssetKey
    // sort: order assets by gains (ascending), to prioritize their preservation
    // reduce: into a "diff" that can be applied to a rebalance map

    return rebalanceMap.filter { $1 < 0 }
        .map(\.key)
        .sorted(by: orderBy)
        .reduce(into: [:]) { map, liquidatingAC in

            for acquiringAC in rawRankedTargetsMap[liquidatingAC, default: []] {
                guard let liquidatingAmount = rbmap[liquidatingAC],
                      liquidatingAmount < 0
                else { break } // nothing more to do!

                guard let acquiringAmount = rbmap[acquiringAC],
                      acquiringAmount > 0
                else { continue }

                // we can eliminate a portion of (or all) of the sale

                let transferAmount = min(-liquidatingAmount, acquiringAmount)

                rbmap[liquidatingAC, default: 0] += transferAmount
                rbmap[acquiringAC, default: 0] -= transferAmount

                let pair = ReducerPair(liquidatingAC, acquiringAC)
                map[pair] = transferAmount
            }
        }
}

public func applyReducerMap(_ rebalanceMap: AssetValueMap,
                            _ reducerMap: ReducerMap,
                            preserveZero: Bool = false,
                            epsilon: Double = 0.0001) -> AssetValueMap
{
    var rbmap = rebalanceMap

    for (reducer, amount) in reducerMap {
        rbmap[reducer.left, default: 0] += amount
        rbmap[reducer.right, default: 0] -= amount
    }

    // we want to keep the zeroes for display in account rebalance grids
    if !preserveZero {
        let zeroACs = rbmap.filter { $1.isEqual(to: 0, accuracy: epsilon) }.keys
        zeroACs.forEach { assetID in
            rbmap.removeValue(forKey: assetID)
        }
    }

    return rbmap
}
