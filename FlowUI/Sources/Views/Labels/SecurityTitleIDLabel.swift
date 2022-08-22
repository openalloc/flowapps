//
//  SecurityTitleIDLabel.swift
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


public struct SecurityTitleIDLabel: View {
    private let model: BaseModel
    private let ax: BaseContext
    private let securityKey: SecurityKey?
    private let withAssetID: Bool

    public init(model: BaseModel, ax: BaseContext, securityKey: SecurityKey? = nil, withAssetID: Bool = false) {
        self.model = model
        self.ax = ax
        self.securityKey = securityKey
        self.withAssetID = withAssetID
    }
    
    public var body: some View {
        Text(MSecurity.getTitleID(securityKey, securityMap, assetMap, withAssetID: withAssetID) ?? "")
            .colorCapsule(pair)
    }
    
    private var securityMap: SecurityMap {
        if ax.securityMap.count > 0 {
            return ax.securityMap
        }
        return model.makeSecurityMap()
    }
    
    private var assetMap: AssetMap {
        if ax.assetMap.count > 0 {
            return ax.assetMap
        }
        return model.makeAssetMap()
    }
    
    private var pair: (Color, Color) {
        if let _securityKey = securityKey,
           let security = securityMap[_securityKey],
           let colorCode = assetMap[security.assetKey]?.colorCode {
            return getColor(colorCode)
        } else {
            return (.primary, .clear)
        }
    }
}
