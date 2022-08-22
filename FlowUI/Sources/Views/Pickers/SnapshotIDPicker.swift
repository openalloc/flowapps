//
//  SnapshotIDPicker.swift
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

public struct SnapshotIDPicker<Label>: View where Label: View {
    var snapshots: [MValuationSnapshot]
    @Binding var snapshotID: SnapshotID
    var label: () -> Label

    public init(snapshots: [MValuationSnapshot], snapshotID: Binding<SnapshotID>,
                @ViewBuilder label: @escaping () -> Label) {
        self.snapshots = snapshots
        _snapshotID = snapshotID
        self.label = label
    }
    
    public var body: some View {
        Picker(selection: $snapshotID, label: label()) {
            Text("None (Select One)")
                .tag("")
            ForEach(ordered, id: \.self) { snapshot in
                Text(snapshot.titleID)
                    .tag(snapshot.snapshotID)
            }
        }
    }

    private var ordered: [MValuationSnapshot] {
        snapshots.sorted()
    }
}
