//
//  AssetIDPicker.swift
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

public struct AssetIDPicker<Label>: View where Label: View {
    var assets: [MAsset]
    @Binding var assetID: AssetID
    var label: () -> Label
    
    public init(assets: [MAsset], assetID: Binding<AssetID>,
                @ViewBuilder label: @escaping () -> Label) {
        self.assets = assets
        _assetID = assetID
        self.label = label
    }

    public var body: some View {
        Picker(selection: $assetID, label: label()) {
            Text("None (Select One)")
                .tag("")
            ForEach(ordered, id: \.self) { asset in
                Text(asset.titleID)
                    .tag(asset.assetID)
            }
        }
    }

    private var ordered: [MAsset] {
        assets.sorted()
    }
}
