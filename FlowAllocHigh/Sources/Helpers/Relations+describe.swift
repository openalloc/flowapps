//
//  Relations+describe.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

import SimpleTree
import AllocData

import FlowAllocLow
import FlowBase

public extension Relations {
    static func describe(_ map: ClosestTargetMap, assetMap: AssetMap, prefix: String) -> String {
        let vals: [String] = map.sorted(by: { $0.key < $1.key }).reduce(into: []) { array, entry in
            guard let asset1 = assetMap[entry.key],
                  let asset2 = assetMap[entry.value]
            else { return }
            array.append("\(asset1.assetID) → \(asset2.assetID)")
        }
        let joinedVals = vals.joined(separator: ", ")
        return "\(prefix): \(joinedVals)"
    }

    static func describe(_ map: DeepRelationsMap, assetMap: AssetMap, prefix: String) -> String {
        let array: [String] = map.sorted(by: { $0.key < $1.key }).reduce(into: []) { array, entry in
            guard let asset1 = assetMap[entry.key]
            else { return }
            let assets2 = entry.value.compactMap { assetMap[$0]?.assetID }
            array.append("\(asset1.assetID) → [\(assets2.joined(separator: ", "))]")
        }
        return "\(prefix): \(array.joined(separator: "; "))"
    }
}
