//
//  SidebarView.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//


import SwiftUI

//import KeyWindow

import AllocData

import FlowBase
// activeSidebarMenuKey constants (see also Data Model constants)
public enum SidebarMenuIDs: String, CaseIterable {
    case globalHoldings = "34AA716D-3BD1-4592-B83D-05439B053587"
    case activeStrategy = "E2FEE472-8DCA-4F06-8B1B-BBE21A3EEA67"
    case tradingAccountsSummary = "A4F42A3F-BA02-4BFF-AFF7-7004EF4F83E5"
    case nonTradingAccountsSummary = "2DDD94F2-D091-4981-A67D-9D8E93EB36D1"
    case modelStrategies = "B0564B17-B0DE-4D6C-8343-CCCB94BCE091"
    case modelAccounts = "B0564B17-B0DE-4D6C-8343-CCCB94BCE092"
    case modelAssets = "B0564B17-B0DE-4D6C-8343-CCCB94BCE093"
    case modelSecurities = "B0564B17-B0DE-4D6C-8343-CCCB94BCE094"
    case modelTrackers = "B0564B17-B0DE-4D6C-8343-CCCB94BCE095"
    case modelHoldings = "4194E211-CCD8-4C45-ABBF-549C52D6A120"
    case modelTxns = "B0564B17-B0DE-4D6C-8343-CCCB94BCE096"
//    case modelValuationSnapshots = "98363443-B922-4C00-84AC-F04173D4D03C"
//    case modelValuationPositions = "B03004CC-AE96-44BB-8557-CCD3FFCEE6D5"
//    case modelValuationCashflow = "0856B316-111D-4E20-85E4-8B2072726482"
    case dataModelHeader = "5A6B812A-92E6-4704-80B2-A004B4864ACD"
    case spacer0 = "8F38DAC5-D947-4008-86B0-CC33B8AF8F6A"
    case spacer1 = "404D79DA-EFC0-4992-87AE-604080C4F082"
    case spacer2 = "C5BF3A23-4E4B-4034-8F90-8069A3FDE391"

    public var title: String {
        switch self {
        case .globalHoldings:
            return "All Holdings"
        case .activeStrategy:
            return "Active Strategy"
        case .tradingAccountsSummary:
            return "Trading Accounts"
        case .nonTradingAccountsSummary:
            return "Non-trading Accounts"
        case .modelStrategies:
            return "Strategies"
        case .modelAccounts:
            return "Accounts"
        case .modelAssets:
            return "Assets"
        case .modelSecurities:
            return "Securities"
        case .modelTrackers:
            return "Trackers"
        case .modelHoldings:
            return "Holdings"
        case .modelTxns:
            return "Transactions"
//        case .modelValuationSnapshots:
//            return "Valuation Snapshots"
//        case .modelValuationPositions:
//            return "Valuation Positions"
//        case .modelValuationCashflow:
//            return "Valuation Cash Flow"
        case .dataModelHeader:
            return "Data Models"
        default:
            return ""
        }
    }
}

public struct SidebarView<THS, NHS, SS, AS, TC, BC>: View where THS: View, NHS: View, SS: View, AS: View, TC: View, BC: View {
    let topContent: TC
    let bottomContent: BC
    let tradingHoldingsSummary: THS
    let nonTradingHoldingsSummary: NHS
    let strategySummary: (MStrategy) -> SS
    let accountSummary: (MAccount) -> AS
    @Binding var model: BaseModel
    var ax: BaseContext
    let fill: LinearGradient
    var assetColorMap: AssetColorMap
    @Binding var activeStrategyKey: MStrategy.Key
    @Binding var activeSidebarMenuKey: String?
    var strategyAssetValues: [AssetValue]
    var fetchAssetValues: FetchAssetValues

    public init(topContent: TC,
                bottomContent: BC,
                tradingHoldingsSummary: THS,
                nonTradingHoldingsSummary: NHS,
                strategySummary: @escaping (MStrategy) -> SS,
                accountSummary: @escaping (MAccount) -> AS,
                model: Binding<BaseModel>,
                ax: BaseContext,
                fill: LinearGradient,
                assetColorMap: AssetColorMap,
                activeStrategyKey: Binding<MStrategy.Key>,
                activeSidebarMenuKey: Binding<String?>,
                strategyAssetValues: [AssetValue],
                fetchAssetValues: @escaping FetchAssetValues) {
        self.topContent = topContent
        self.bottomContent = bottomContent
        self.tradingHoldingsSummary = tradingHoldingsSummary
        self.nonTradingHoldingsSummary = nonTradingHoldingsSummary
        self.strategySummary = strategySummary
        self.accountSummary = accountSummary
        _model = model
        self.ax = ax
        self.fill = fill
        self.assetColorMap = assetColorMap
        _activeStrategyKey = activeStrategyKey
        _activeSidebarMenuKey = activeSidebarMenuKey
        self.strategyAssetValues = strategyAssetValues
        self.fetchAssetValues = fetchAssetValues
    }
    
    // MARK: - Locals

    public var body: some View {
        List {
            topContent
            
            SidebarHeaderLabel(title: "Strategy",
                               letter: "S", fill: fill)
                .contentShape(Rectangle()) // to ensure taps work in empty space
                .onTapGesture {
                    activeSidebarMenuKey = SidebarMenuIDs.activeStrategy.rawValue
                }
            
            StrategyNavPicker(strategySummary: strategySummary,
                              model: $model,
                              ax: ax,
                              assetColorMap: assetColorMap,
                              activeStrategyKey: $activeStrategyKey,
                              activeSidebarMenuKey: $activeSidebarMenuKey,
                              assetValues: strategyAssetValues,
                              strategies: model.strategies)
            
            spacer(.spacer0)
            
            if tradingAccounts.count > 0 {
                NavigationLink(
                    destination: tradingHoldingsSummary,
                    tag: SidebarMenuIDs.tradingAccountsSummary.rawValue,
                    selection: $activeSidebarMenuKey) {
                        SidebarHeaderLabel(title: "Trading Accounts",
                                           letter: "T", fill: fill)
                    }
                
                SidebarAccountsView(accountSummary: accountSummary,
                                    assetColorMap: assetColorMap,
                                    fetchAssetValues: fetchAssetValues,
                                    accounts: tradingAccounts,
                                    activeSidebarMenuKey: $activeSidebarMenuKey)
                
                spacer(.spacer1)
            }
            
            if nonTradingAccounts.count > 0 {
                NavigationLink(
                    destination: nonTradingHoldingsSummary,
                    tag: SidebarMenuIDs.nonTradingAccountsSummary.rawValue,
                    selection: $activeSidebarMenuKey) {
                        SidebarHeaderLabel(title: "Non-Trading Accounts",
                                           letter: "N", fill: fill)
                    }
            
                SidebarAccountsView(accountSummary: accountSummary,
                                    assetColorMap: assetColorMap,
                                    fetchAssetValues: fetchAssetValues,
                                    accounts: nonTradingAccounts,
                                    activeSidebarMenuKey: $activeSidebarMenuKey)
                
                spacer(.spacer2)
            }
            
            bottomContent
        }
        .listStyle(SidebarListStyle())
    }

    private func spacer(_ menuID: SidebarMenuIDs) -> some View {
        
        // NOTE because of possible SwiftUI bug, making the spacer navigable
        NavigationLink(destination: Text(""), // WelcomeView() { GettingStarted(document: $document) },
                       tag: menuID.rawValue,
                       selection: $activeSidebarMenuKey) {
            Spacer()
        }
    }
    
    // MARK: - Properties
    
    private var tradingAccounts: [MAccount] {
        let accounts = activeStrategyKey.isValid
        ? ax.strategyVariableAccountsMap[activeStrategyKey] ?? []
        : ax.variableAccounts
        return accounts
    }
    
    private var nonTradingAccounts: [MAccount] {
        let accounts = activeStrategyKey.isValid
        ? ax.strategyFixedAccountsMap[activeStrategyKey] ?? []
        : ax.fixedAccounts
        return accounts
    }
}
