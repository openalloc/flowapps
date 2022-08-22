//
//  MAsset+Misc.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

import AllocData
import SimpleTree

extension MAsset.Key: CustomStringConvertible {
    public var description: String {
        "AssetID: '\(assetNormID)'"
    }
}

extension MAsset: Titled {
    public var titleID: String {
        guard let title_ = title else { return assetID }
        return title_ == assetID ? title_ : "\(title_) (\(assetID))"
    }
}

public extension MAsset {
    static func getTitleID(_ assetKey: AssetKey?, _ assetMap: AssetMap, withID: Bool) -> String? {
        guard let asset = getAsset(assetKey, assetMap)
        else { return nil }
        return withID ? asset.titleID : asset.title
    }

    private static func getAsset(_ assetKey: AssetKey?, _ assetMap: AssetMap) -> MAsset? {
        guard let assetKey_ = assetKey,
              let asset = assetMap[assetKey_] else { return nil }
        return asset
    }
}

public extension MAsset {
    // don't allow a child of current asset to be assigned as its parent. Or itself.
    func getParentCandidates(relatedTree: AssetKeyTree, assets: [MAsset]) -> [MAsset] {
        let node = relatedTree.getFirst(for: primaryKey)
        let childAssetKeys = node?.getChildValues() ?? []
        let childSet = Set(childAssetKeys)
        return assets.filter { !childSet.contains($0.primaryKey) && $0.primaryKey != self.primaryKey }
    }
}

public extension MAsset {
    
    static let cashAssetID = "Cash"
    static let cashAssetKey = MAsset.Key(assetID: cashAssetID)

    var isCash: Bool {
        primaryKey == MAsset.cashAssetKey
    }
}
