//
//  AssetTitleLabel.swift
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

public struct AssetTitleLabel: View {
    private let assetKey: AssetKey?
    private let assetMap: AssetMap
    private let withID: Bool
    
    public init(assetKey: AssetKey? = nil, assetMap: AssetMap, withID: Bool) {
        self.assetKey = assetKey
        self.assetMap = assetMap
        self.withID = withID
    }
    
    public var body: some View {
        Text(MAsset.getTitleID(assetKey, assetMap, withID: withID) ?? "")
            .colorCapsule(pair)
            //.opacity(assetKey?.isValid ?? false ? 1 : 0)
    }
    
    private var pair: (Color, Color) {
        if let _assetKey = assetKey,
           let colorCode = assetMap[_assetKey]?.colorCode {
            return getColor(colorCode)
        } else {
            return (.primary, .clear)
        }
    }
}
