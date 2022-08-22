//
//  HoldingsSummaryTable.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//


import SwiftUI
import Tabler

import AllocData

import FlowBase

public struct HoldingsSummaryTable: View {
    var model: BaseModel
    var ax: BaseContext
    
    var holdingsSummaryMap: AssetHoldingsSummaryMap
    var assetTickerSummaryMap: AssetTickerHoldingsSummaryMap // for breakdown by ticker
    
    @Binding var summarySelection: SummarySelection
    
    public init(model: BaseModel,
                ax: BaseContext,
                holdingsSummaryMap: AssetHoldingsSummaryMap,
                assetTickerSummaryMap: AssetTickerHoldingsSummaryMap,
                summarySelection: Binding<SummarySelection>) {
        self.model = model
        self.ax = ax
        self.holdingsSummaryMap = holdingsSummaryMap
        self.assetTickerSummaryMap = assetTickerSummaryMap
        _summarySelection = summarySelection
    }
    
    private let gridItems: [GridItem] = [
        GridItem(.flexible(minimum: 200), spacing: columnSpacing),
        GridItem(.flexible(minimum: 100), spacing: columnSpacing),
        GridItem(.flexible(minimum: 100), spacing: columnSpacing),
        GridItem(.flexible(minimum: 100), spacing: columnSpacing),
        GridItem(.flexible(minimum: 100), spacing: columnSpacing),
    ]
    
    public var body: some View {
        TablerStack(.init(rowSpacing: flowRowSpacing),
                    header: header,
                    row: row,
                    rowBackground: rowBackground,
                    results: assetKeys)
            .sideways(minWidth: 800, showIndicators: true)
    }
    
    private func header(ctx: Binding<TablerContext<AssetKey>>) -> some View {
        LazyVGrid(columns: gridItems, alignment: .leading, spacing: flowColumnSpacing) {
            Text("Asset Class")
                .modifier(HeaderCell())
            Text("Asset Class Value")
                .modifier(HeaderCell())
            Text("Ticker(s)")
                .modifier(HeaderCell())
            Text("Share(s) Held")
                .modifier(HeaderCell())
            Text("Amount(s) Held")
                .modifier(HeaderCell())
        }
    }
    
    private func row(_ assetKey: AssetKey) -> some View {
        LazyVGrid(columns: gridItems, alignment: .leading, spacing: flowColumnSpacing) {
            Text(getAssetClassTitle(assetKey))
                .mpadding()

            switch summarySelection {
            case .presentValue:
                CurrencyLabel(value: holdingsSummaryMap[assetKey]?.presentValue ?? 0, style: .whole)
                    .mpadding()
           case .gainLossAmount:
                CurrencyLabel(value: holdingsSummaryMap[assetKey]?.gainLoss ?? 0, style: .whole)
                    .mpadding()
            case .gainLossPercent:
                PercentLabel(value: holdingsSummaryMap[assetKey]?.gainLossPercent, leadingPlus: true)
                    .mpadding()
            }
            
            HoldingsCell(ax: ax,
                         tickerSummaryMap: getTickerSummaryMap(for: assetKey),
                         //colorCode: getColorCode(assetKey),
                         field: .ticker)
                .mpadding()

            HoldingsCell(ax: ax,
                         tickerSummaryMap: getTickerSummaryMap(for: assetKey),
                         //colorCode: getColorCode(assetKey),
                         field: .tickerShareCount)
                .mpadding()

            switch summarySelection {
            case .presentValue:
                HoldingsCell(ax: ax,
                             tickerSummaryMap: getTickerSummaryMap(for: assetKey),
                             //colorCode: getColorCode(assetKey),
                             field: .presentValue)
                    .mpadding()
            case .gainLossAmount:
                HoldingsCell(ax: ax,
                             tickerSummaryMap: getTickerSummaryMap(for: assetKey),
                             //colorCode: getColorCode(assetKey),
                             field: .gainLossAmount)
                    .mpadding()
            case .gainLossPercent:
                HoldingsCell(ax: ax,
                             tickerSummaryMap: getTickerSummaryMap(for: assetKey),
                             //colorCode: getColorCode(assetKey),
                             field: .gainLossPercent)
                    .mpadding()
            }
        }
        .foregroundColor(colorPair(assetKey).0)
    }
    
    // MARK: - Helpers
        
    private func getTickerSummaryMap(for assetKey: AssetKey) -> TickerHoldingsSummaryMap {
        assetTickerSummaryMap[assetKey] ?? [:]
    }
    
    // asset keys, sorted by asset title
    private var assetKeys: [AssetKey] {
        holdingsSummaryMap.map(\.key).compactMap { assetMap[$0] }.sorted().map(\.primaryKey)
    }
    
    private var assetMap: AssetMap {
        if ax.assetMap.count > 0 {
            return ax.assetMap
        }
        return model.makeAssetMap()
    }
    
    private func getAssetClassTitle(_ assetKey: AssetKey) -> String {
        assetMap[assetKey]?.titleID ?? ""
    }
    
    private func rowBackground(assetKey: AssetKey) -> some View {
        MyColor.getBackgroundFill(colorPair(assetKey).1)
    }
    
    private func colorPair(_ assetKey: AssetKey) -> (Color, Color) {
        let colorCode = ax.colorCodeMap[assetKey] ?? 0
        return getColor(colorCode)
    }
}
