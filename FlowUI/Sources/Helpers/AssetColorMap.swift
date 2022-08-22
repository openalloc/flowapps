//
//  AssetColorMap.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import SwiftUI

import AllocData

import FlowBase

public typealias AssetColorMap = [AssetKey: ColorPair]

public func getAssetColorMap(colorCodeMap: ColorCodeMap) -> AssetColorMap {
    let tuples: [(assetKey: AssetKey, colorPair: ColorPair)] = colorCodeMap.map { (assetKey: $0, colorPair: getColor($1)) }
    return Dictionary(uniqueKeysWithValues: tuples)
}

