//
//  AccountAssetKeyed.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

import AllocData

public protocol AccountAssetKeyed {
    var accountAssetKey: AccountAssetKey { get }
}

public struct AccountAssetKey: Hashable {
    let accountNormID: String
    let assetNormID: String
    
    public init(accountID: AccountID,
                assetID: AssetID) {
        self.accountNormID = MHolding.normalizeID(accountID)
        self.assetNormID = MHolding.normalizeID(assetID)
    }
    
    public var accountKey: AccountKey {
        MAccount.Key(accountID: accountNormID)
    }
    
    public var assetKey: AssetKey {
        MAsset.Key(assetID: assetNormID)
    }
}

extension AccountAssetKey: Comparable {
    public static func < (lhs: AccountAssetKey, rhs: AccountAssetKey) -> Bool {
        lhs.accountNormID < rhs.accountNormID ||
        (lhs.accountNormID == rhs.accountNormID && lhs.assetNormID < rhs.assetNormID)
    }
}

public extension AccountAssetKeyed {
    static func getAccountAssetKeyMap<T: AccountAssetKeyed>(_ elements: [T]) -> [AccountAssetKey: [T]] {
        elements.reduce(into: [:]) { map, element in
            map[ element.accountAssetKey, default: [] ].append(element)
        }
    }
}
