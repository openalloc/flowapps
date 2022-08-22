//
//  MRebalancePurchase+Utils.swift
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


public extension MRebalancePurchase {
    
    static func getPurchases(_ accountPurchasesMap: AccountPurchasesMap, _ accountMap: AccountMap, _ assetMap: AssetMap) -> [MRebalancePurchase] {
        accountPurchasesMap.reduce(into: []) { array, entry in
            let (accountKey, purchases) = entry // [AccountKey: [Purchase]]
            guard let account = accountMap[accountKey] else { return }
            let mpurchases: [MRebalancePurchase] = purchases.compactMap {
                guard let assetID = assetMap[$0.assetKey]?.assetID else { return nil }
                return MRebalancePurchase(accountID: account.accountID, assetID: assetID, amount: $0.amount)
            }
            array.append(contentsOf: mpurchases)
        }
    }
    
}
