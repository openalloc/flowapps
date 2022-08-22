//
//  ContextUtils.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

import FlowBase


// horizontal limits
func getAssetAccountLimitMap(accountKeys: [AccountKey],
                             baseAllocs: [AssetValue],
                             accountCapacitiesMap: AccountCapacitiesMap,
                             accountCapsMap: AccountCapsMap) -> AssetAccountLimitMap
{
    guard accountKeys.count == accountCapacitiesMap.count else {
        // os_log(.error, "[%@] account:accountCapacities size mismatch (%d != %d) ", #function, accounts.count, accountCapacities.count)
        return [:]
    }

    return baseAllocs.reduce(into: [:]) { dict, alloc in

        let map: AccountLimitMap = accountKeys.reduce(into: [:]) { map, accountKey in
            guard let accountCapacity = accountCapacitiesMap[accountKey] else { return }

            let limitPct: Double = {
                let caps = accountCapsMap[accountKey] ?? []
                return caps.first(where: { $0.assetKey == alloc.assetKey })?.limitPct ?? 1.0
            }()

            map[accountKey] = limitPct * accountCapacity
        }
        
        dict[alloc.assetKey] = map
    }
}

func getAccountUserAssetLimitMap(accountKeys: [AccountKey],
                                 baseAllocs: [AssetValue],
                                 accountCapacitiesMap: AccountCapacitiesMap,
                                 accountCapsMap: AccountCapsMap) throws -> AccountUserAssetLimitMap
{
    guard accountKeys.count == accountCapacitiesMap.count else {
        // os_log(.error, "[%@] account:accountCapacities size mismatch (%d != %d) ", #function, accounts.count, accountCapacities.count)
        return [:]
    }

    return accountKeys.reduce(into: [:]) { dict, accountKey in
        guard let accountCapacity = accountCapacitiesMap[accountKey] else { return }

        let caps = accountCapsMap[accountKey] ?? []
        let limitPctMap = getLimitPctMap(caps)

        let userAssetLimitMap: UserAssetLimitMap = baseAllocs.reduce(into: [:]) { map, alloc in
            
            let userLimitAccountPct: Double = limitPctMap[alloc.assetKey] ?? 1.0
            let userLimit: Double = userLimitAccountPct * accountCapacity

            map[alloc.assetKey] = userLimit
        }

        dict[accountKey] = userAssetLimitMap
    }
}

// vertical limits
func getAccountUserVertLimitMap(accountKeys: [AccountKey],
                                baseAllocs: [AssetValue],
                                accountCapacitiesMap: AccountCapacitiesMap,
                                accountCapsMap: AccountCapsMap) throws -> AccountUserVertLimitMap
{
    guard accountKeys.count == accountCapacitiesMap.count else {
        // os_log(.error, "[%@] account:accountCapacities size mismatch (%d != %d) ", #function, accounts.count, accountCapacities.count)
        return [:]
    }

    let allocMap = AssetValue.getAssetValueMap(from: baseAllocs)
    
    return try accountKeys.reduce(into: [:]) { dict, accountKey in
        guard let accountCapacity = accountCapacitiesMap[accountKey] else { return }

        let caps = accountCapsMap[accountKey] ?? []
        let limitPctMap = getLimitPctMap(caps)

        dict[accountKey] = try getUserVertLimits(allocMap: allocMap,
                                                 limitPctMap: limitPctMap,
                                                 accountCapacity: accountCapacity)
    }
}

internal func getUserVertLimits(allocMap: AssetValueMap,
                                limitPctMap: LimitPctMap,
                                accountCapacity: Double) throws -> UserVertLimitMap
{
    var restricted_sum = 0.0
    var unrestricted_sum = 0.0
    allocMap.forEach { assetKey, targetPct in
        let userLimit = limitPctMap[assetKey] ?? 1.0
        if userLimit <= targetPct {
            restricted_sum += userLimit
        } else {
            unrestricted_sum += targetPct
        }
    }
    
    guard restricted_sum + unrestricted_sum > 0 else { throw AllocLowError1.invalidLimits }
    
    return allocMap.reduce(into: [:]) { map, entry in
        let (assetKey, targetPct) = entry
        
        let userLimit = limitPctMap[assetKey] ?? 1.0
        
        let xRatio: Double = {
            if userLimit <= targetPct {
                return userLimit
            } else {
                return targetPct / unrestricted_sum * (1 - restricted_sum)
            }
        }()
        
        map[assetKey] = xRatio * accountCapacity
    }
}
