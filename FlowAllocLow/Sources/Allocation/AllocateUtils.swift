//
//  AllocateUtils.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import os

import AllocData

import FlowBase


let epsilon = 0.0001 // accuracy of Double comparisons

//let alog = Logger(subsystem: "app.flowallocator", category: "Allocate")

public func getAccountAllocationMap(allocs: [AssetValue],
                                    accountKeys: [AccountKey],
                                    allocFlowMode: Double,
                                    assetAccountLimitMap: AssetAccountLimitMap,
                                    accountUserVertLimitMap: AccountUserVertLimitMap,
                                    accountUserAssetLimitMap: AccountUserAssetLimitMap,
                                    accountCapacitiesMap: AccountCapacitiesMap,
                                    isStrict: Bool = false) throws -> AccountAssetValueMap
{
    var remainingAssetClassCapacities = allocs.map(\.value)
    
    let map: AccountAssetValueMap = try accountKeys.enumerated().reduce(into: [:]) { map, entry in
        let (accountIndex, accountKey) = entry
        
        // need to draw this down to 0 for account, or abort allocation (e.g., 33%)
        guard let accountCapacity = accountCapacitiesMap[accountKey],
              accountCapacity.isGreater(than: 0.0, accuracy: epsilon)
        else {
            map[accountKey] = [:]  // so that cells will be rendered despite no allocation/funds
            return
        }
        
        guard let userVertLimitMap = accountUserVertLimitMap[accountKey] else { throw AllocLowError1.missingVertLimit }
        guard let userAssetLimitMap = accountUserAssetLimitMap[accountKey] else { throw AllocLowError1.missingAssetLimit }
        
        map[accountKey] = try getAllocationMap(accountKeys: accountKeys,
                                               accountIndex: accountIndex,
                                               allocs: allocs,
                                               allocFlowMode: allocFlowMode,
                                               accountCapacity: accountCapacity,
                                               assetAccountLimitMap: assetAccountLimitMap,
                                               userVertLimitMap: userVertLimitMap,
                                               userAssetLimitMap: userAssetLimitMap,
                                               remainingAssetClassCapacities: &remainingAssetClassCapacities,
                                               isStrict: isStrict)
    }
    
    return map
}

func getAllocationMap(accountKeys: [AccountKey],
                      accountIndex: Int,
                      allocs: [AssetValue],
                      allocFlowMode: Double,
                      accountCapacity: Double,
                      assetAccountLimitMap: AssetAccountLimitMap,
                      userVertLimitMap: UserVertLimitMap,
                      userAssetLimitMap: UserAssetLimitMap,
                      remainingAssetClassCapacities: inout [Double],
                      isStrict: Bool = false) throws -> AssetValueMap
{
    // Horizontal: starts as 100% of account's share of strategy, and decreases (vertical)
    var remainingToAllocateInAccount = accountCapacity
    
    return try allocs.enumerated().reduce(into: [:]) { map, entry in
        let (allocIndex, alloc) = entry
        
        guard remainingToAllocateInAccount.isGreater(than: 0.0, accuracy: epsilon) else { return }
        
        guard let userVertLimit = userVertLimitMap[alloc.assetKey] else { throw AllocLowError1.missingVertLimit }
        guard let userAssetLimit = userAssetLimitMap[alloc.assetKey] else { throw AllocLowError1.missingAssetLimit }
        let accountLimitMap = assetAccountLimitMap[alloc.assetKey] ?? [:]
        
        let netAllocation = try getAllocation(accountKeys: accountKeys,
                                              alloc: alloc,
                                              allocIndex: allocIndex,
                                              allocFlowMode: allocFlowMode,
                                              accountCapacity: accountCapacity,
                                              accountLimitMap: accountLimitMap,
                                              accountIndex: accountIndex,
                                              isStrict: isStrict,
                                              userVertLimit: userVertLimit,
                                              userAssetLimit: userAssetLimit,
                                              remainingToAllocateInAccount: remainingToAllocateInAccount,
                                              remainingAssetClassCapacities: &remainingAssetClassCapacities)
        
        remainingToAllocateInAccount -= netAllocation
        
        //print("netAllocation=\(netAllocation) remainingToAllocateInAccount=\(remainingToAllocateInAccount)")
        
        // if less than zero, but within tolerance, coerce to zero, to avoid Core Data
        // validation complaining about a negative value.
        let netAllocation_ = netAllocation.coerceIfEqual(to: 0.0, accuracy: epsilon)
        
        map[alloc.assetKey] = netAllocation_ / accountCapacity
    }
}

// returns the size of the allocation, as a fraction of the entire strategy
func getAllocation(accountKeys: [AccountKey],
                   alloc: AssetValue,
                   allocIndex: Int,
                   allocFlowMode: Double,
                   accountCapacity: Double,
                   accountLimitMap: AccountLimitMap,
                   accountIndex: Int,
                   isStrict: Bool,
                   userVertLimit: Double,
                   userAssetLimit: Double,
                   remainingToAllocateInAccount: Double,
                   remainingAssetClassCapacities: inout [Double]) throws -> Double
{
    // is the folio's asset class explicitly supported by this account?
    // guard let assetID = strategySlice.assetID else { throw StrategySliceError.missingAssetClass }
    
    // remaining capacity to allocate in current assetID, across subsequent accounts (horizontal)
    let remainingAssetClassCapacity = remainingAssetClassCapacities[allocIndex]
    
    // os_log("[%@] %@ strategySliceIndex=%d remainingAssetClassCapacity=%0.4f", #function, strategySlice.assetID, strategySliceIndex, remainingAssetClassCapacity)
    
    guard remainingAssetClassCapacity.isGreater(than: 0, accuracy: epsilon) else { return 0 }
    
    //print("remainingAssetClassCapacities=\(remainingAssetClassCapacities) index=\(strategySliceIndex)")
    
    // remaining capacity to allocate in subsequent asset classes, across all accounts
    let forwardAssetClassCapacity = remainingAssetClassCapacities.forwardSum(start: allocIndex + 1)
    
    // os_log("[%@] GGG forwardAssetCapacity=%0.4f", #function, forwardAssetClassCapacity)
    
    // user will tolerate up to 100% of the account to be allocated to an asset class
    // e.g., 100% of $64K Roth in SPY
    
    // calculate the user-suggested limit on allocations for this asset class for all subsequent accounts
    // e.g., the user wishes to limit bonds to 0% in the taxable (rightmost) account
    let forwardAssetClassLimit: Double = accountLimitMap.forwardSum(order: accountKeys, start: accountIndex + 1)
    
    //print("forwardAssetClassLimit=\(forwardAssetClassLimit) assetID=\(strategySlice.assetID)")
    
    // os_log("[%@] HHH forwardAssetClassLimit=%0.4f", #function, forwardAssetClassLimit)
    
    let skewedAllocFlowMode = getSkewedAllocFlowMode(rawAllocFlowMode: allocFlowMode)
    
    let flowTarget = getFlowTarget(targetPct: alloc.value,
                                   accountCapacity: accountCapacity,
                                   allocFlowMode: skewedAllocFlowMode)
    
    let surplusRequired = getSurplusRequired(remainingAssetClassCapacity: remainingAssetClassCapacity,
                                             forwardAssetClassLimit: forwardAssetClassLimit,
                                             flowTarget: flowTarget)
    
    // suggest a limit for the current cap based on user preference and degree to which we're mirroring
    let userMaxLimit = getUserMaxLimit(userLimit: userAssetLimit,
                                       flowTarget: flowTarget,
                                       accountCapacity: accountCapacity,
                                       surplusRequired: surplusRequired)
    
    // os_log("[%@] cap flowTarget=%0.4f surplusRequired=%0.4f userMaxLimit=%0.4f", #function, flowTarget, surplusRequired, userMaxLimit)
    
    // limit amount allocated to asset class in account, if specified in allocation slice
    let netAllocation = getStrategyPct(remainingAccountCapacity: remainingToAllocateInAccount,
                                       remainingAssetClassCapacity: remainingAssetClassCapacity,
                                       forwardAssetClassCapacity: forwardAssetClassCapacity,
                                       userMaxLimit: userMaxLimit,
                                       userVertLimit: userVertLimit)
    
    //print("remainingAssetClassCapacity=\(remainingAssetClassCapacity) forwardAssetClassCapacity=\(forwardAssetClassCapacity) forwardAssetClassLimit=\(forwardAssetClassLimit) skewedAllocFlowMode=\(skewedAllocFlowMode) flowTarget=\(flowTarget) surplusRequired=\(surplusRequired) userMaxLimit=\(userMaxLimit) netAllocation=\(netAllocation)")
    
    if isStrict, netAllocation > userAssetLimit {
        throw AllocLowError1.userLimitExceededUnderStrict
    }
    
    // os_log("[%@] MMM netAllocation=%0.4f", #function, netAllocation)
    
    guard netAllocation.isGreater(than: 0.0, accuracy: epsilon) else { return 0 }
    
    // for the benefit of future accounts, deduct our current allocation
    remainingAssetClassCapacities[allocIndex] -= netAllocation
    
    // if substantially less than zero, raise the alarm
    if netAllocation.isLess(than: 0.0, accuracy: epsilon) {
        throw AllocLowError1.unexpectedResult("netSlice less than zero")
    }
    
    return netAllocation
}

// convex skew for greater sensitivity when adjusting towards flow
func getSkewedAllocFlowMode(rawAllocFlowMode: Double) -> Double {
    1 - ((1 - rawAllocFlowMode) * (1 - rawAllocFlowMode))
}

func getFlowTarget(targetPct: Double,
                   accountCapacity: Double,
                   allocFlowMode: Double) -> Double
{
    let mirrorTarget = targetPct * accountCapacity
    
    return mirrorTarget + ((targetPct - mirrorTarget) * allocFlowMode)
}

func getSurplusRequired(remainingAssetClassCapacity: Double,
                        forwardAssetClassLimit: Double,
                        flowTarget: Double) -> Double
{
    max(0, remainingAssetClassCapacity - forwardAssetClassLimit - flowTarget)
}

// Suggest a limit based on user preference and degree to which we're mirroring.
//
// If mirroring (allocFlowMode<1) for assetID, maximize UP TO current limitPct
// to accommodate user's limitPct on forward allocations in assetID.
//
// With 100% flow (allocFlowMode==1) we're always maximizing to limitPct, so no
// special treatment.
//
func getUserMaxLimit(userLimit: Double,
                     flowTarget: Double,
                     accountCapacity: Double,
                     surplusRequired: Double) -> Double
{
    let baseLimit = min(userLimit, flowTarget)
    
    return min(accountCapacity, baseLimit + surplusRequired)
}

//
//    In current slice:                            Example
//    - can allocate as most A%                    80%
//    - must allocate as least B%                  10%
//    - user wants to allocate at most C%          50%
//
//    min( A, max( B, C ) )                        50%
//
//    tested in MStrategyTargetGetPercentTests
//
//
func getStrategyPct(remainingAccountCapacity: Double,
                    remainingAssetClassCapacity: Double,
                    forwardAssetClassCapacity: Double,
                    userMaxLimit: Double,
                    userVertLimit: Double) -> Double
{
    // can allocate at most
    let a = min(remainingAccountCapacity, remainingAssetClassCapacity)
    
    // must allocate at least
    let b = max(0, remainingAccountCapacity - forwardAssetClassCapacity)
    
    // user wants to allocate at most
    let c = max(userMaxLimit, userVertLimit)
    
    return min(a, max(b, c))
}

func getCapacitiesMap(_ accountKeys: [AccountKey],
                      _ accountPresentValueMap: AccountPresentValueMap) -> AccountCapacitiesMap
{
    let accountsTotal = accountKeys.reduce(0) { $0 + (accountPresentValueMap[$1] ?? 0) }
    if accountsTotal <= 0 { return AccountCapacitiesMap() }
    return accountKeys.reduce(into: [:]) { map, accountKey in
        let accountTotal = accountPresentValueMap[accountKey] ?? 0
        map[accountKey] = accountTotal / accountsTotal
    }
}

func getLimitPctMap(_ caps: [MCap]) -> LimitPctMap {
    caps.reduce(into: [:]) { map, cap in
        guard cap.assetKey.isValid else { return }
        map[cap.assetKey] = cap.limitPct
    }
}
