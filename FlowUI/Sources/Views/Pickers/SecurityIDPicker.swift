//
//  SecurityIDPicker.swift
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

public struct SecurityIDPicker<Label>: View where Label: View {
    var securities: [MSecurity]
    var assetMap: AssetMap
    @Binding var securityID: SecurityID
    var label: () -> Label

    public init(securities: [MSecurity], assetMap: AssetMap, securityID: Binding<SecurityID>,
                @ViewBuilder label: @escaping () -> Label) {
        self.securities = securities
        self.assetMap = assetMap
        _securityID = securityID
        self.label = label
    }
    
    public var body: some View {
        Picker(selection: $securityID, label: label()) {
            Text("None (Select One)")
                .tag("")
            ForEach(ordered, id: \.self) { security in
                Text(security.getTitleID(assetMap))
                    .tag(security.securityID)
            }
        }
    }

    private var ordered: [MSecurity] {
        securities.sorted()
    }
}
