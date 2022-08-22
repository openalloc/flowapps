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

import AllocData

public struct Relations {
    
    public static let rootAssetKey = MAsset.Key(assetID: "593D776C-E48E-4D47-9353-027DEBC0D55A")
    public static let rootSet = Set([Relations.rootAssetKey])

    public static func getTree(assetMap: AssetMap) throws -> AssetKeyTree {
        let root = AssetKeyTree(value: rootAssetKey)
        
        // NOTE: sorting the keys to ensure deterministic behavior
        try assetMap.keys.sorted().forEach { try addNodes(root, $0, assetMap) }
        
        return root
    }

    private static func addNodes(_ root: AssetKeyTree, _ assetKey: AssetKey, _ assetMap: AssetMap) throws {
        guard let asset = assetMap[assetKey] else {
            throw FlowBaseError.validationFailure("Asset class \(assetKey) not found.")
        }
        
        let parentAssetKey = asset.parentAssetKey
        
        // recursively add parent nodes first
        if parentAssetKey.isValid {
            try addNodes(root, parentAssetKey, assetMap)
        }
        
        let parentNode: AssetKeyTree = try {
            guard parentAssetKey.isValid else { return root }
            
            if let parentNode_ = root.getFirst(for: parentAssetKey) {
                return parentNode_
            }
            
            throw FlowBaseError.validationFailure("\(parentAssetKey) node not found.")
        }()
        
        guard root.getFirst(for: assetKey) == nil else { return }
        
        _ = parentNode.addChild(value: assetKey)
    }
}
