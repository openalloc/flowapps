//
//  SecurityTable.swift
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

public struct SecurityTable: View {
    
    // MARK: - Parameters
    
    @Binding private var model: BaseModel
    private let ax: BaseContext
    private let activeTickerKeys: SecurityKeySet
    
    public init(model: Binding<BaseModel>, ax: BaseContext, activeTickerKeys: SecurityKeySet) {
        _model = model
        self.ax = ax
        self.activeTickerKeys = activeTickerKeys
    }
    
    // MARK: - Field Metadata
    
    private var gridItems: [GridItem] = [
        GridItem(.flexible(minimum: 60, maximum: 100), spacing: columnSpacing, alignment: .leading),
        GridItem(.flexible(minimum: 250), spacing: columnSpacing, alignment: .leading),
        GridItem(.flexible(minimum: 60, maximum: 80), spacing: columnSpacing, alignment: .center),
        GridItem(.flexible(minimum: 70), spacing: columnSpacing, alignment: .leading),
        GridItem(.flexible(minimum: 200), spacing: columnSpacing, alignment: .leading),
        GridItem(.flexible(minimum: 120), spacing: columnSpacing, alignment: .leading),
    ]
    
    // MARK: - Locals
    
    @State private var showActiveOnly = false
    
    // MARK: - Views
    
    typealias Context = TablerContext<MSecurity>
    
    private func header(_ ctx: Binding<Context>) -> some View {
        LazyVGrid(columns: gridItems, alignment: .leading, spacing: flowColumnSpacing) {
            Sort.columnTitle("Ticker", ctx, \.securityID)
                .onTapGesture { tablerSort(ctx, &model.securities, \.securityID) { $0.primaryKey < $1.primaryKey } }
                .modifier(HeaderCell())
            Sort.columnTitle("Asset Class", ctx, \.assetID)
                .onTapGesture { tablerSort(ctx, &model.securities, \.assetID) { $0.assetKey < $1.assetKey } }
                .modifier(HeaderCell())
            Text("Is Active?")
                .modifier(HeaderCell())
            Sort.columnTitle("Share Price", ctx, \.sharePrice)
                .onTapGesture { tablerSort(ctx, &model.securities, \.sharePrice) { ($0.sharePrice ?? 0) < ($1.sharePrice ?? 0) } }
                .modifier(HeaderCell())
            Sort.columnTitle("Updated At", ctx, \.updatedAt)
                .onTapGesture { tablerSort(ctx, &model.securities, \.updatedAt) { ($0.updatedAt ?? Date.distantPast) < ($1.updatedAt ?? Date.distantPast) } }
                .modifier(HeaderCell())
            Sort.columnTitle("Index Tracker", ctx, \.trackerID)
                .onTapGesture { tablerSort(ctx, &model.securities, \.trackerID) { $0.trackerKey < $1.trackerKey } }
                .modifier(HeaderCell())
        }
    }
    
    private func row(_ element: MSecurity) -> some View {
        LazyVGrid(columns: gridItems, alignment: .leading, spacing: flowColumnSpacing) {
            Text(element.securityID)
            AssetTitleLabel(assetKey: element.assetKey, assetMap: ax.assetMap, withID: true)
                .mpadding()
                .modifier(MissingDataModifier(isAssetMissing(element)))
            CheckmarkLabel(activeTickerKeys.contains(element.primaryKey))
            CurrencyLabel(value: element.sharePrice ?? 0, ifZero: "", style: .full)
                .mpadding()
                .modifier(MissingDataModifier(isSharePriceMissing(element)))
            DateLabel(element.updatedAt, withTime: true)
                .mpadding()
            TrackerTitleLabel(model: model, ax: ax, trackerKey: element.trackerKey, withID: true)
                .mpadding()
        }
        .modifier(EditDetailerContextMenu(element, onDelete: deleteAction, onEdit: { toEdit = $0 }))
    }
    
    private func isAssetMissing(_ element: MSecurity) -> Bool {
        !element.assetKey.isValid && ax.activeTickersMissingAssetClass.contains(element.primaryKey)
    }
    
    private func isSharePriceMissing(_ element: MSecurity) -> Bool {
        let sharePrice = element.sharePrice ?? 0
        return sharePrice == 0 && ax.activeTickersMissingSharePrice.contains(element.primaryKey)
    }
                          
    private func editDetail(ctx: DetailerContext<MSecurity>, element: Binding<MSecurity>) -> some View {
        let isActive = ax.activeTickerKeys.contains(element.wrappedValue.primaryKey)
        let disableKey = ctx.originalID != newElement.primaryKey
        return Form {
            TextField("Ticker", text: element.securityID)
                .disabled(disableKey)
                .validate(ctx, element, \.securityID) { $0.count > 0 }
            
            AssetIDPicker(assets: model.assets.sorted(), assetID: element.assetID) {
                Text("Asset Class")
            }
            .validate(ctx, element, \.assetID) { !isActive || $0.count > 0 }
            
            CurrencyField("Share Price", value: element.sharePrice ?? 0)
                .validate(ctx, element, \.sharePrice) { !isActive || ($0 ?? 0) > 0 }
            
            DatePickerOpt("Updated At",
                          selection: element.updatedAt,
                          displayedComponents: [.date, .hourAndMinute])
            
            TrackerIDPicker(trackers: model.trackers.sorted(), trackerID: element.trackerID) {
                Text("Tracking Index")
            }
        }
    }
    
    // MARK: - Locals
    
    private typealias Sort = TablerSort<MSecurity>
    private typealias DConfig = DetailerConfig<MSecurity>
    private typealias TConfig = TablerStackConfig<MSecurity>
    
    private var dconfig: DConfig {
        DConfig(
            onDelete: deleteAction,
            onSave: saveAction,
            titler: { _ in ("Security") })
    }
    
    @State var toEdit: MSecurity? = nil
    @State var selected: MSecurity.ID? = nil
    @State var hovered: MSecurity.ID? = nil
    
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
                    results: model.securities,
                    selected: $selected)
                .sideways(minWidth: 1050, showIndicators: true)
            }
            .editDetailer(dconfig,
                          toEdit: $toEdit,
                          originalID: toEdit?.id,
                          detailContent: editDetail)
            .onChange(of: model.securities) { _ in
                // ensure active missing tickers, etc. causes warning indicator in sidebar to refresh
                
                NotificationCenter.default.post(name: .refreshContext, object: model.id)
            }
    }
    
    // MARK: - Helpers
    
    private var assetMap: AssetMap {
        if ax.assetMap.count > 0 {
            return ax.assetMap
        }
        return model.makeAssetMap()
    }
    
    // MARK: - Action Handlers
    
    private func deleteAction(element: MSecurity) {
        model.delete(element)
    }
    
    private func editAction(_ id: MSecurity.ID?) -> MSecurity? {
        guard let _id = id else { return nil }
        return model.securities.first(where: { $0.id == _id })
    }
    
    private func saveAction(ctx: DetailerContext<MSecurity>, element: MSecurity) {
        let isNew = ctx.originalID == newElement.primaryKey
        model.save(element,
                   to: \.securities,
                   originalID: isNew ? nil : ctx.originalID)
    }
    
    private var newElement: MSecurity {
        MSecurity(securityID: "", assetID: nil, sharePrice: nil, updatedAt: nil, trackerID: nil)
    }
    
    private func clearAction() {
        model.securities.forEach { model.delete($0) } // TODO filtered
    }
    
    private func exportAction() {
        let finFormat = AllocFormat.CSV
        if let data = try? exportData(model.securities, format: finFormat),
           let ext = finFormat.defaultFileExtension
        {
            let name = MSecurity.entityName.plural.replacingOccurrences(of: " ", with: "-")
#if os(macOS)
            NSSavePanel.saveData(data, name: name, ext: ext, completion: { _ in })
#endif
        }
    }
}
