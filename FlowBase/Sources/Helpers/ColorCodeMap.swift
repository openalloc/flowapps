//
//  ColorCodeMap.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

import AllocData

public typealias ColorCodeMap = [MAsset.Key: Int]  // AssetKey: Int

public extension MAsset {
    static func getColorCodeMap(_ assets: [MAsset]) -> ColorCodeMap {
        let assetKeys = assets.map(\.primaryKey)
        let colorCodes = assets.map { $0.colorCode ?? 0 }
        return Dictionary(uniqueKeysWithValues: zip(assetKeys, colorCodes))
    }
}
