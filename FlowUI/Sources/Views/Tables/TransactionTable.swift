//
//  TransactionTable.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import SwiftUI
import Detailer
import DetailerMenu
import AllocData
import Tabler
import FlowBase

public struct TransactionTable: View {
    
    // MARK: - Parameters
    
    @Binding private var model: BaseModel
    private let ax: BaseContext
    private let account: MAccount? // if nil, show all history
    private let showGainLoss: Bool
    private let warnMissingSharePrice: Bool
    
    public init(model: Binding<BaseModel>, ax: BaseContext, account: MAccount?, showGainLoss: Bool, warnMissingSharePrice: Bool) {
        _model = model
        self.ax = ax
        self.account = account
        self.showGainLoss = showGainLoss
        self.warnMissingSharePrice = warnMissingSharePrice
    }
    
    // MARK: - Field Metadata
    
    private var gridItems: [GridItem] {
        var items: [GridItem] = [
            GridItem(.flexible(minimum: 60, maximum: 80), spacing: columnSpacing, alignment: .leading),
            GridItem(.flexible(minimum: 250), spacing: columnSpacing, alignment: .leading),
            GridItem(.flexible(minimum: 100), spacing: columnSpacing, alignment: .leading),
            GridItem(.flexible(minimum: 50), spacing: columnSpacing, alignment: .leading),
            GridItem(.flexible(minimum: 50), spacing: columnSpacing, alignment: .leading),
        ]
        if showGainLoss {
            items.append(contentsOf: [
                GridItem(.flexible(minimum: 50), spacing: columnSpacing, alignment: .leading),
                GridItem(.flexible(minimum: 50), spacing: columnSpacing, alignment: .leading),
            ])
        }
        items.append(
            GridItem(.flexible(minimum: 100), spacing: columnSpacing, alignment: .leading))
        return items
    }
    
    // MARK: - Views
    
    typealias Context = TablerContext<MTransaction>
    
    private func header(_ ctx: Binding<Context>) -> some View {
        LazyVGrid(columns: gridItems, alignment: .leading, spacing: flowColumnSpacing) {
            Sort.columnTitle("Action", ctx, \.action)
                .onTapGesture { tablerSort(ctx, &model.transactions, \.action) { $0.action < $1.action } }
                .modifier(HeaderCell())
            Sort.columnTitle("Account (Number)", ctx, \.accountID)
                .onTapGesture { tablerSort(ctx, &model.transactions, \.accountID) { $0.accountKey < $1.accountKey } }
                .modifier(HeaderCell())
            Sort.columnTitle("Security (Asset)", ctx, \.securityID)
                .onTapGesture { tablerSort(ctx, &model.transactions, \.securityID) { $0.securityKey < $1.securityKey } }
                .modifier(HeaderCell())
            Sort.columnTitle("Shares Held", ctx, \.shareCount)
                .onTapGesture { tablerSort(ctx, &model.transactions, \.shareCount) { $0.shareCount < $1.shareCount } }
                .modifier(HeaderCell())
            Sort.columnTitle("Share Price", ctx, \.sharePrice)
                .onTapGesture { tablerSort(ctx, &model.transactions, \.sharePrice) { ($0.sharePrice ?? 0) < ($1.sharePrice ?? 0) } }
                .modifier(HeaderCell())
            if showGainLoss {
                Sort.columnTitle("ST Gain/Loss", ctx, \.realizedGainShort)
                    .onTapGesture { tablerSort(ctx, &model.transactions, \.realizedGainShort) { ($0.realizedGainShort ?? 0) < ($1.realizedGainShort ?? 0) } }
                    .modifier(HeaderCell())
                Sort.columnTitle("LT Gain/Loss", ctx, \.realizedGainLong)
                    .onTapGesture { tablerSort(ctx, &model.transactions, \.realizedGainLong) { ($0.realizedGainLong ?? 0) < ($1.realizedGainLong ?? 0) } }
                    .modifier(HeaderCell())
            }
            Sort.columnTitle("Transacted At", ctx, \.transactedAt)
                .onTapGesture { tablerSort(ctx, &model.transactions, \.transactedAt) { $0.transactedAt < $1.transactedAt } }
                .modifier(HeaderCell())
        }
    }
    
    private func row(_ element: MTransaction) -> some View {
        LazyVGrid(columns: gridItems, alignment: .leading, spacing: flowColumnSpacing) {
            Text(element.action.displayDescription)
                .mpadding()
            AccountTitleLabel(model: model, ax: ax, accountKey: element.accountKey, withID: true)
                .mpadding()
            SecurityTitleIDLabel(model: model, ax: ax, securityKey: element.securityKey, withAssetID: true)
                .mpadding()
            SharesLabel(value: element.shareCount, style: .default_)
                .mpadding()
            CurrencyLabel(value: element.sharePrice ?? 0, ifZero: "", style: .full)
                .mpadding()
                .modifier(MissingDataModifier(isMissingSharePrice(element)))
            
            if showGainLoss {
                CurrencyLabel(value: element.realizedGainShort ?? 0, ifZero: "", style: .full)
                    .mpadding()
                    .modifier(MissingDataModifier(element.needsRealizedGain(ax.thirtyDaysBack,
                                                                            ax.securityMap,
                                                                            ax.accountMap)))
                CurrencyLabel(value: element.realizedGainLong ?? 0, ifZero: "", style: .full)
                    .mpadding()
                    .modifier(MissingDataModifier(element.needsRealizedGain(ax.thirtyDaysBack,
                                                                            ax.securityMap,
                                                                            ax.accountMap)))
            }
            DateLabel(element.transactedAt, withTime: false)
                .mpadding()
        }
        .modifier(EditDetailerContextMenu(element, onDelete: deleteAction, onEdit: { toEdit = $0 }))
    }
    
    private func editDetail(ctx: DetailerContext<MTransaction>, element: Binding<MTransaction>) -> some View {
        let disableKey = ctx.originalID != newElement.primaryKey
        return Form {
            TransactionActionPicker(selectedAction: element.action) {
                Text("Action")
            }
            .disabled(disableKey)
            TextField("Account Number", text: element.accountID)
                .disabled(disableKey)
            TextField("Security Ticker", text: element.securityID)
                .disabled(disableKey)
            TextField("Lot ID", text: element.lotID)
                .disabled(disableKey)
            SharesField("Shares Held", value: element.shareCount)
                .disabled(disableKey)
            CurrencyField("Share Price", value: element.sharePrice ?? 0)
                .modifier(MissingDataModifier(isMissingSharePrice(element.wrappedValue)))
            if showGainLoss {
                CurrencyField("Short Term Realized Gain(+)/Loss(-)", value: element.realizedGainShort ?? 0)
                    .modifier(MissingDataModifier(element.wrappedValue.needsRealizedGain(ax.thirtyDaysBack,
                                                                                         ax.securityMap,
                                                                                         ax.accountMap)))
                CurrencyField("Long Term Realized Gain(+)/Loss(-)", value: element.realizedGainLong ?? 0)
                    .modifier(MissingDataModifier(element.wrappedValue.needsRealizedGain(ax.thirtyDaysBack,
                                                                                         ax.securityMap,
                                                                                         ax.accountMap)))
            }
            DatePicker(selection: element.transactedAt) {
                Text("Transacted At:")
            }
            .disabled(disableKey)
        }
    }
    
    // MARK: - Locals
    
    private typealias Sort = TablerSort<MTransaction>
    private typealias DConfig = DetailerConfig<MTransaction>
    private typealias TConfig = TablerStackConfig<MTransaction>
    
    private var dconfig: DConfig {
        DConfig(
            onDelete: deleteAction,
            onSave: saveAction,
            titler: { _ in ("Transaction") })
    }
    
    @State var toEdit: MTransaction? = nil
    @State var selected: MTransaction.ID? = nil
    @State var hovered: MTransaction.ID? = nil
    
    public var body: some View {
        BaseModelTable(
            selected: $selected,
            toEdit: $toEdit,
            onAdd: { newElement },
            onEdit: editAction,
            onClear: clearAction,
            onExport: exportAction,
            onDelete: dconfig.onDelete) {
                TablerStack1(
                    .init(onHover: { if $1 { hovered = $0 } else { hovered = nil } }),
                    header: header,
                    row: row,
                    rowBackground: { MyRowBackground($0, hovered: hovered, selected: selected) },
                    results: model.transactions,
                    selected: $selected)
                    .sideways(minWidth: 1300, showIndicators: true)
            }
            .editDetailer(dconfig,
                          toEdit: $toEdit,
                          originalID: toEdit?.id,
                          detailContent: editDetail)
            .onChange(of: model.transactions) { _ in
                // ensure missing realized gains, etc. causes warning indicator in sidebar to refresh
                
                NotificationCenter.default.post(name: .refreshContext, object: model.id)
            }
    }
    
    // MARK: - Helpers
    
    private func isMissingSharePrice(_ element: MTransaction) -> Bool {
        warnMissingSharePrice &&
        //element.action != .transfer &&
        (element.sharePrice ?? 0) <= 0
    }
    
    private var assetMap: AssetMap {
        if ax.assetMap.count > 0 {
            return ax.assetMap
        }
        return model.makeAssetMap()
    }
    
    private var securityMap: SecurityMap {
        if ax.securityMap.count > 0 {
            return ax.securityMap
        }
        return model.makeSecurityMap()
    }
    
    // MARK: - Action Handlers
    
    private func deleteAction(element: MTransaction) {
        model.delete(element)
    }
    
    private func editAction(_ id: MTransaction.ID?) -> MTransaction? {
        guard let _id = id else { return nil }
        return model.transactions.first(where: { $0.id == _id })
    }
    
    private func saveAction(ctx: DetailerContext<MTransaction>, element: MTransaction) {
        let isNew = ctx.originalID == newElement.primaryKey
        model.save(element,
                   to: \.transactions,
                   originalID: isNew ? nil : ctx.originalID)
    }
    
    private var newElement: MTransaction {
        let accountID = account?.accountID ?? ""
        let transactedAt = Date.init(timeIntervalSince1970: 0)
        return MTransaction(action: .miscflow, transactedAt: transactedAt, accountID: accountID, securityID: "")
    }
    
    private func clearAction() {
        var elements = model.transactions
        if let accountKey = account?.primaryKey {
            elements = elements.filter { $0.accountKey == accountKey }
        }
        elements.forEach { model.delete($0) }
    }
    
    private func exportAction() {
        let finFormat = AllocFormat.CSV
        if let data = try? exportData(model.transactions, format: finFormat),
           let ext = finFormat.defaultFileExtension
        {
            let name = MTransaction.entityName.plural.replacingOccurrences(of: " ", with: "-")
#if os(macOS)
            NSSavePanel.saveData(data, name: name, ext: ext, completion: { _ in })
#endif
        }
    }
}
