//
//  MRebalanceAllocation+Utils.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

import AllocData

import FlowBase


public extension MRebalanceAllocation {
    
    static func getAllocations(_ accountKeys: [AccountKey],
                               _ accountAmountMap: AccountAmountMap,
                               _ accountAllocMap: AccountAssetValueMap,
                               _ accountMap: AccountMap,
                               _ assetMap: AssetMap) -> [MRebalanceAllocation] {
        accountKeys.reduce(into: []) { array, accountKey in
            guard let account = accountMap[accountKey],
                  let assetValueMap = accountAllocMap[accountKey]
            else { return }
            let mallocations: [MRebalanceAllocation] = assetValueMap.compactMap {
                guard let assetID = assetMap[$0.key]?.assetID,
                      let presentValue = accountAmountMap[accountKey] else { return nil }
                let amount = $0.value * presentValue
                return MRebalanceAllocation(accountID: account.accountID, assetID: assetID, amount: amount)
            }
            array.append(contentsOf: mallocations)
        }
    }
}
