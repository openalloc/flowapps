//
//  TrackerIDPicker.swift
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

public struct TrackerIDPicker<Label>: View where Label: View {
    var trackers: [MTracker]
    @Binding var trackerID: TrackerID
    var label: () -> Label

    public init(trackers: [MTracker], trackerID: Binding<TrackerID>,
                @ViewBuilder label: @escaping () -> Label) {
        self.trackers = trackers
        _trackerID = trackerID
        self.label = label
    }
    
    public var body: some View {
        Picker(selection: $trackerID, label: label()) {
            Text("None (Select One)")
                .tag("")
            ForEach(ordered, id: \.self) { tracker in
                Text(tracker.titleID)
                    .tag(tracker.trackerID)
            }
        }
    }

    private var ordered: [MTracker] {
        trackers.sorted()
    }
}
