//
//  StrategyLabels.swift
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

public struct StrategyTitleLabel: View {
    private let model: BaseModel
    private let ax: BaseContext
    private let strategyKey: StrategyKey?
    private let withID: Bool

    public init(model: BaseModel, ax: BaseContext, strategyKey: StrategyKey? = nil, withID: Bool) {
        self.model = model
        self.ax = ax
        self.strategyKey = strategyKey
        self.withID = withID
    }
    
    public var body: some View {
        Text(MStrategy.getStrategyTitleID(strategyKey, strategyMap, withID: withID) ?? "")
    }
    
    private var strategyMap: StrategyMap {
        if ax.strategyMap.count > 0 {
            return ax.strategyMap
        }
        return model.makeStrategyMap()
    }
}
