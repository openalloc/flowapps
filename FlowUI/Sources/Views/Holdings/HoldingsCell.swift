//
//  HoldingsCell.swift
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

public struct HoldingsCell: View {
    public enum SummaryField: Int {
        case ticker
        case presentValue
        case costBasis
        case gainLossAmount
        case gainLossPercent
        case tickerShareCount
    }
    
    var ax: BaseContext
    var tickerSummaryMap: TickerHoldingsSummaryMap
    var field: SummaryField
    
    public init(ax: BaseContext,
                tickerSummaryMap: TickerHoldingsSummaryMap,
                field: SummaryField) {
        self.ax = ax
        self.tickerSummaryMap = tickerSummaryMap
        self.field = field
    }
    
    public var body: some View {
        VStack {
            ForEach(securities, id: \.self) { security in
                if let summary = tickerSummaryMap[security.primaryKey] {
                    switch field {
                    case .ticker:
                        Text(security.securityID)
                    case .presentValue:
                        CurrencyLabel(value: summary.presentValue, style: .whole)
                    case .costBasis:
                        CurrencyLabel(value: summary.costBasis, style: .whole)
                    case .gainLossAmount:
                        CurrencyLabel(value: summary.gainLoss, style: .whole)
                    case .gainLossPercent:
                        PercentLabel(value: summary.gainLossPercent, leadingPlus: true)
                    case .tickerShareCount:
                        SharesLabel(value: summary.tickerShareMap[security.primaryKey, default: 0])
                    }
                } else {
                    EmptyView()
                }
            }
        }
    }
    
    // MARK: - Helpers
    
    private var securityKeys: [SecurityKey] {
        tickerSummaryMap.map(\.key)
    }
    
    private var securities: [MSecurity] {
        securityKeys.compactMap { ax.securityMap[$0] }.sorted(by: { $0.securityID < $1.securityID })
    }
}
