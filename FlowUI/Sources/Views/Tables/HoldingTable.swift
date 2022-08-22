//
//  HoldingTable.swift
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

public struct HoldingTable: View {
    
    // MARK: - Parameters
    
    @Binding private var model: BaseModel
    private let ax: BaseContext
    private let account: MAccount?
    
    public init(model: Binding<BaseModel>, ax: BaseContext, account: MAccount?) {
        _model = model
        self.ax = ax
        self.account = account
    }
    
    // MARK: - Field Metadata
    
    private var gridItems: [GridItem] {
        var items: [GridItem] = []
        if account == nil {
            items.append(GridItem(.flexible(minimum: 300), spacing: columnSpacing, alignment: .leading))
        }
        items.append(contentsOf: [
            GridItem(.flexible(minimum: 80), spacing: columnSpacing, alignment: .leading),
            GridItem(.flexible(minimum: 30), spacing: columnSpacing, alignment: .leading),
            GridItem(.flexible(minimum: 60), spacing: columnSpacing, alignment: .leading),
            GridItem(.flexible(minimum: 60), spacing: columnSpacing, alignment: .leading),
            GridItem(.flexible(minimum: 120), spacing: columnSpacing, alignment: .leading),
        ])
        return items
    }
    
    // MARK: - Views
    
    typealias Context = TablerContext<MHolding>
    
    private func header(_ ctx: Binding<Context>) -> some View {
        LazyVGrid(columns: gridItems, alignment: .leading, spacing: flowColumnSpacing) {
            if account == nil {
                Sort.columnTitle("Account (Number)", ctx, \.accountID)
                    .onTapGesture { tablerSort(ctx, &model.holdings, \.accountID) { $0.accountKey < $1.accountKey } }
                    .modifier(HeaderCell())
            }
            Sort.columnTitle("Security Ticker", ctx, \.securityID)
                .onTapGesture { tablerSort(ctx, &model.holdings, \.securityID) { $0.securityKey < $1.securityKey } }
                .modifier(HeaderCell())
            Sort.columnTitle("Lot ID", ctx, \.lotID)
                .onTapGesture { tablerSort(ctx, &model.holdings, \.lotID) { $0.lotID < $1.lotID } }
                .modifier(HeaderCell())
            Sort.columnTitle("Shares Held", ctx, \.shareCount)
                .onTapGesture { tablerSort(ctx, &model.holdings, \.shareCount) { ($0.shareCount ?? 0) < ($1.shareCount ?? 0) } }
                .modifier(HeaderCell())
            Sort.columnTitle("Share Basis", ctx, \.shareBasis)
                .onTapGesture { tablerSort(ctx, &model.holdings, \.shareBasis) { ($0.shareBasis ?? 0) < ($1.shareBasis ?? 0) } }
                .modifier(HeaderCell())
            Sort.columnTitle("Acquired At", ctx, \.acquiredAt)
                .onTapGesture { tablerSort(ctx, &model.holdings, \.acquiredAt) { ($0.acquiredAt ?? Date.distantPast) < ($1.acquiredAt ?? Date.distantPast) } }
                .modifier(HeaderCell())
        }
    }
    
    private func row(_ element: MHolding) -> some View {
        LazyVGrid(columns: gridItems, alignment: .leading, spacing: flowColumnSpacing) {
            if account == nil {
                AccountTitleLabel(model: model, ax: ax, accountKey: element.accountKey, withID: true)
                    .mpadding()
            }
            SecurityTitleIDLabel(model: model, ax: ax, securityKey: element.securityKey, withAssetID: true)
                .mpadding()
            Text(element.lotID)
                .mpadding()
            SharesLabel(value: element.shareCount, style: .default_)
                .mpadding()
            CurrencyLabel(value: element.shareBasis ?? 0, style: .full)
                .mpadding()
            DateLabel(element.acquiredAt, withTime: false)
                .mpadding()
        }
        .modifier(EditDetailerContextMenu(element, onDelete: deleteAction, onEdit: { toEdit = $0 }))
    }
    
    private func editDetail(ctx: DetailerContext<MHolding>, element: Binding<MHolding>) -> some View {
        let disableKey = ctx.originalID != newElement.primaryKey
        return Form {
            AccountIDPicker(accounts: model.accounts.sorted(), accountID: element.accountID) {
                Text("Account")
            }
            .disabled((account?.primaryKey.isValid ?? false) || disableKey)
            .validate(ctx, element, \.accountID) { $0.count > 0 }
            
            SecurityIDPicker(securities: model.securities.sorted(),
                             assetMap: assetMap,
                             securityID: element.securityID) {
                Text("Security")
            }
            .disabled(disableKey)
            .validate(ctx, element, \.securityID) { $0.count > 0 }
            
            TextField("Lot ID", text: element.lotID)
                .disabled(disableKey)

            SharesField("Shares Held", value: element.shareCount ?? 0)
                .validate(ctx, element, \.shareCount) { ($0 ?? 0) > 0 }
            
            CurrencyField("Cost Basis (price paid per share)", value: element.shareBasis ?? 0)
            
            DatePickerOpt("Acquired At",
                          selection: element.acquiredAt,
                          displayedComponents: [.date, .hourAndMinute])
        }
    }
    
    // MARK: - Locals
    
    private typealias Sort = TablerSort<MHolding>
    private typealias DConfig = DetailerConfig<MHolding>
    private typealias TConfig = TablerStackConfig<MHolding>
    
    private var dconfig: DConfig {
        DConfig(onDelete: { model.delete($0) },
                onSave: saveAction,
                titler: { _ in ("Holding") })
    }
    
    @State var toEdit: MHolding? = nil
    @State var selected: MHolding.ID? = nil
    @State var hovered: MHolding.ID? = nil
    
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
                    results: holdings,
                    selected: $selected)
                .sideways(minWidth: account == nil ? 1200 : 800, showIndicators: true)
            }
            .editDetailer(dconfig,
                          toEdit: $toEdit,
                          originalID: toEdit?.id,
                          detailContent: editDetail)
    }
    
    // MARK: - Helpers
    
    private var holdings: [MHolding] {
        guard account != nil else { return model.holdings }
        return model.holdings.filter {
            $0.accountKey == account!.primaryKey
        }
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
    
    private func deleteAction(element: MHolding) {
        model.delete(element)
    }
    
    private func editAction(_ id: MHolding.ID?) -> MHolding? {
        guard let _id = id else { return nil }
        return model.holdings.first(where: { $0.id == _id })
    }
    
    private func saveAction(ctx: DetailerContext<MHolding>, element: MHolding) {
        let isNew = ctx.originalID == newElement.primaryKey
        model.save(element,
                   to: \.holdings,
                   originalID: isNew ? nil : ctx.originalID)
    }
    
    private var newElement: MHolding {
        let accountID = account?.accountID ?? ""
        return MHolding(accountID: accountID,
                        securityID: "",
                        lotID: "",
                        shareCount: nil,
                        shareBasis: nil,
                        acquiredAt: nil)
    }
    
    private func clearAction() {
        var elements = model.holdings
        if let accountKey = account?.primaryKey {
            elements = elements.filter { $0.accountKey == accountKey }
        }
        elements.forEach { model.delete($0) }
    }
    
    private func exportAction() {
        let finFormat = AllocFormat.CSV
        if let data = try? exportData(model.holdings, format: finFormat),
           let ext = finFormat.defaultFileExtension
        {
            let name = MHolding.entityName.plural.replacingOccurrences(of: " ", with: "-")
#if os(macOS)
            NSSavePanel.saveData(data, name: name, ext: ext, completion: { _ in })
#endif
        }
    }
}
