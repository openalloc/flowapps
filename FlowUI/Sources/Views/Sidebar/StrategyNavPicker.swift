//
//  StrategyNavPicker.swift
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
import FlowViz
struct StrategyNavPicker<HS>: View where HS: View {
    
    let strategySummary: (MStrategy) -> HS
    @Binding var model: BaseModel
    var ax: BaseContext
    var assetColorMap: AssetColorMap
    @Binding var activeStrategyKey: MStrategy.Key
    @Binding var activeSidebarMenuKey: String?
    var assetValues: [AssetValue]    // endPositions for FlowWorth; surge-calculated for FlowAllocator
    var strategies: [MStrategy]

    var body: some View {
        VStack {
            if activeStrategyKey.isValid,
               let strategy_ = ax.strategyMap[activeStrategyKey]
            {
                NavigationLink(
                    destination: strategySummary(strategy_),
                    tag: SidebarMenuIDs.activeStrategy.rawValue,
                    selection: $activeSidebarMenuKey,
                    label: {
                        cell
                    }
                )
            } else {
                cell
            }
        }
    }

    private var cell: some View {
        VStack {
            KeyedPickerTitled(elements: model.strategies.sorted(),
                        key: $activeStrategyKey)
            { Text(strategyTitle) }
                .modify {
                    #if os(macOS)
                    $0.pickerStyle(DefaultPickerStyle())
                        .labelsHidden()
                    #else
                    $0.pickerStyle(MenuPickerStyle())
                        .foregroundColor(.primary) // to contrast with the background accent color when selected
                    #endif
                }

            let targetAllocs: [VizSlice] = {
                let av = assetValues
                let ta = av.map { VizSlice($0.value, assetColorMap[$0.assetKey]?.1 ?? Color.gray) }
                guard ta.count > 0 else { return [VizSlice(1.0, Color.gray)] }
                return ta
            }()
            VizBarView(targetAllocs)
                .frame(height: 12)
                .shadow(radius: 1, x: 2, y: 2)
        }
    }
    
    // MARK: - Helpers

    private var strategyTitle: String {
        guard activeStrategyKey.isValid,
              let strategy = ax.strategyMap[activeStrategyKey],
              let title = strategy.title?.trimmingCharacters(in: .whitespaces)
        else { return "None" }
        return title
    }
}
