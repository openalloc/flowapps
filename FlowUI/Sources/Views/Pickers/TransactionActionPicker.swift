//
//  TransactionActionPicker.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//


import SwiftUI

import AllocData

private let defaultAction = MTransaction.Action.miscflow

struct TransactionActionPicker<Label>: View where Label: View {
    @Binding var selectedAction: MTransaction.Action
    var label: () -> Label
    
    public init(selectedAction: Binding<MTransaction.Action>,
                @ViewBuilder label: @escaping () -> Label) {
        _selectedAction = selectedAction
        self.label = label
    }
    
    @State private var rawAction: String = defaultAction.rawValue

    public var body: some View {
        Picker(selection: $rawAction, label: label()) {
            ForEach(MTransaction.Action.allCases, id: \.self) { action in
                Text(action.displayDescription)
                    .tag(action.rawValue)
            }
        }
        .onAppear {
            rawAction = selectedAction.rawValue
        }
        .onChange(of: rawAction, perform: {
            selectedAction = MTransaction.Action(rawValue: $0) ?? defaultAction
        })
    }
}
