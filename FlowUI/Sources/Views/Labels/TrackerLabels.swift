//
//  TrackerLabels.swift
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

public struct TrackerTitleLabel: View {
    private let model: BaseModel
    private let ax: BaseContext
    private let trackerKey: TrackerKey?
    private let withID: Bool

    public init(model: BaseModel, ax: BaseContext, trackerKey: TrackerKey? = nil, withID: Bool) {
        self.model = model
        self.ax = ax
        self.trackerKey = trackerKey
        self.withID = withID
    }
    
    public var body: some View {
        Text(MTracker.getTitleID(trackerKey, trackerMap, withID: withID) ?? "")
    }
    
    private var trackerMap: TrackerMap {
        if ax.trackerMap.count > 0 {
            return ax.trackerMap
        }
        return model.makeTrackerMap()
    }
}
