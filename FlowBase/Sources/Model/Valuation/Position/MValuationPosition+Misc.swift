//
//  MValuationPosition+Misc.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

import AllocData

extension MValuationPosition.Key: CustomStringConvertible {
    public var description: String {
        "SnapshotID: '\(snapshotNormID)', AccountID : '\(accountNormID)', AssetID : '\(assetNormID)'"
    }
}

extension MValuationPosition: AccountAssetKeyed {
    public var accountAssetKey: AccountAssetKey {
        AccountAssetKey(accountID: accountID, assetID: assetID)
    }
    
    public func getStrategyAssetKey(accountMap: AccountMap) -> StrategyAssetKey? {
        guard let strategyID = accountMap[accountKey]?.strategyID else { return nil }
        return StrategyAssetKey(strategyID: strategyID, assetID: assetID)
    }
}

