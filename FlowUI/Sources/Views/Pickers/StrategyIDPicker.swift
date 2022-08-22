//
//  StrategyIDPicker.swift
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

public struct StrategyIDPicker<Label>: View where Label: View {
    var strategies: [MStrategy]
    @Binding var strategyID: StrategyID
    var label: () -> Label

    public init(strategies: [MStrategy], strategyID: Binding<StrategyID>,
                @ViewBuilder label: @escaping () -> Label) {
        self.strategies = strategies
        _strategyID = strategyID
        self.label = label
    }
    
    public var body: some View {
        Picker(selection: $strategyID, label: label()) {
            Text("None (Select One)")
                .tag("")
            ForEach(ordered, id: \.self) { strategy in
                Text(strategy.titleID)
                    .tag(strategy.strategyID)
            }
        }
    }

    private var ordered: [MStrategy] {
        strategies.sorted()
    }
}
