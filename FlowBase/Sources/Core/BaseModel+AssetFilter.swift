//
//  BaseModel+AssetFilter.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

import AllocData

public extension BaseModel {
    
    func getFilteredAssets(strategyKey: StrategyKey, allocationKey: MAllocation.Key) -> [MAsset] {
        
        let otherAllocationsInStrategy = allocations.filter { $0.strategyKey == strategyKey && $0.primaryKey != allocationKey }
        let assetsToExclude = Set(otherAllocationsInStrategy.map(\.assetID))
        return assets.filter { !assetsToExclude.contains($0.assetID) }
    }
    
    func getFilteredAssets(accountKey: AccountKey, capKey: MCap.Key) -> [MAsset] {
        
        let otherCapsInAccount = caps.filter { $0.accountKey == accountKey && $0.primaryKey != capKey }
        let assetsToExclude = Set(otherCapsInAccount.map(\.assetID))
        return assets.filter { !assetsToExclude.contains($0.assetID) }
    }
}
