//
//  SidebarDataModelSection.swift
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

// NOTE mirrors DataModelCommands
public struct SidebarDataModelSection: View {
    @Binding var model: BaseModel
    var ax: BaseContext
    @Binding var activeSidebarMenuKey: String?
    var baseModelEntities: [SidebarMenuIDs]
    var fill: LinearGradient
    var warningCounts: [String: Int]
    var showGainLoss: Bool
    var warnMissingSharePrice: Bool
    var auxTableViewInfos: [DataModelViewInfo]

    public init(model: Binding<BaseModel>,
                ax: BaseContext,
                activeSidebarMenuKey: Binding<String?>,
                baseModelEntities: [SidebarMenuIDs],
                fill: LinearGradient,
                warningCounts: [String: Int],
                showGainLoss: Bool,
                warnMissingSharePrice: Bool,
                auxTableViewInfos: [DataModelViewInfo] = []) {
        _model = model
        self.ax = ax
        _activeSidebarMenuKey = activeSidebarMenuKey
        self.baseModelEntities = baseModelEntities
        self.fill = fill
        self.warningCounts = warningCounts
        self.showGainLoss = showGainLoss
        self.warnMissingSharePrice = warnMissingSharePrice
        self.auxTableViewInfos = auxTableViewInfos
    }
    
    public var body: some View {
    
        // NOTE because of possible SwiftUI bug, making the header navigable
        NavigationLink(destination: Text(""),
                       tag: SidebarMenuIDs.dataModelHeader.rawValue,
                       selection: $activeSidebarMenuKey) {
            SidebarHeaderLabel(title: "Data Model", letter: "M", fill: fill)
        }

        ForEach(tableViewInfos) { tvInfo in
            NavigationLink(destination: tvInfo.tableView,
                           tag: tvInfo.id,
                           selection: $activeSidebarMenuKey) {
                
                HStack {
                    SidebarNumberedLabel(tvInfo.count, fill: fill) { Text(tvInfo.title) }
                    
                    if let count = warningCounts[tvInfo.id] {
                        WarningIndicator(n: count)
                            .font(.title2)
                    }
                }
            }
        }
    }
    
    private var tableViewInfos: [DataModelViewInfo] {
        var infos = [DataModelViewInfo]()
        
        for x in baseModelEntities {
            infos.append(DataModelViewInfo(id: x.rawValue,
                                           tableView: getModelView(x),
                                           title: x.title,
                                           count: getModelCount(x)))
        }
        
        infos.append(contentsOf: auxTableViewInfos)
        
        return infos
    }
    
    private func getModelView(_ menuID: SidebarMenuIDs) -> AnyView {
        switch menuID {
        case .modelStrategies:
            return StrategyTable(model: $model, ax: ax).eraseToAnyView()
        case .modelAccounts:
            return AccountTable(model: $model, ax: ax).eraseToAnyView()
        case .modelAssets:
            return AssetTable(model: $model, ax: ax).eraseToAnyView()
        case .modelSecurities:
            return SecurityTable(model: $model, ax: ax, activeTickerKeys: activeTickerKeys).eraseToAnyView()
        case .modelTrackers:
            return TrackerTable(model: $model, ax: ax).eraseToAnyView()
        case .modelHoldings:
            return HoldingTable(model: $model, ax: ax, account: nil).eraseToAnyView()
        case .modelTxns:
            return TransactionTable(model: $model, ax: ax, account: nil, showGainLoss: showGainLoss, warnMissingSharePrice: warnMissingSharePrice).eraseToAnyView()
        default:
            return EmptyView().eraseToAnyView()
        }
    }
    
    private func getModelCount(_ menuID: SidebarMenuIDs) -> Int {
        switch menuID {
        case .modelStrategies:
            return model.strategies.count
        case .modelAccounts:
            return model.accounts.count
        case .modelAssets:
            return model.assets.count
        case .modelSecurities:
            return model.securities.count
        case .modelTrackers:
            return model.trackers.count
        case .modelHoldings:
            return model.holdings.count
        case .modelTxns:
            return model.transactions.count
        default:
            return 0
        }
    }
    
    private var activeTickerKeys: SecurityKeySet {
        if ax.activeTickerKeySet.count > 0 {
            return ax.activeTickerKeySet
        }
        let securityKeys = MSecurity.getTickerKeys(for: model.strategiedAccounts, accountHoldingsMap: model.makeAccountHoldingsMap())
        return Set(securityKeys)
    }
}
