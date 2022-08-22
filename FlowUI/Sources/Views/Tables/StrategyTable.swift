//
//  StrategyTable.swift
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

public struct StrategyTable: View {
    
    // MARK: - Parameters
    
    @Binding var model: BaseModel
    private let ax: BaseContext
    
    public init(model: Binding<BaseModel>, ax: BaseContext) {
        _model = model
        self.ax = ax
    }
    
    // MARK: - Field Metadata
    
    private var gridItems: [GridItem] = [
        GridItem(.flexible(minimum: 100), spacing: columnSpacing, alignment: .leading),
        GridItem(.flexible(minimum: 100), spacing: columnSpacing, alignment: .leading),
    ]

    // MARK: - Views
    
    typealias Context = TablerContext<MStrategy>
    
    private func header(_ ctx: Binding<Context>) -> some View {
        LazyVGrid(columns: gridItems, alignment: .leading, spacing: flowColumnSpacing) {
            Sort.columnTitle("Strategy ID", ctx, \.strategyID)
                .onTapGesture { tablerSort(ctx, &model.strategies, \.strategyID) { $0.primaryKey < $1.primaryKey } }
                .modifier(HeaderCell())
            Sort.columnTitle("Strategy Title", ctx, \.title)
                .onTapGesture { tablerSort(ctx, &model.strategies, \.title) { ($0.title ?? "") < ($1.title ?? "") } }
                .modifier(HeaderCell())
        }
    }
    
    private func row(_ element: MStrategy) -> some View {
        LazyVGrid(columns: gridItems, alignment: .leading, spacing: flowColumnSpacing) {
            Text(element.strategyID)
                .mpadding()
            Text(element.title ?? "")
                .mpadding()
        }
        .modifier(EditDetailerContextMenu(element, onDelete: deleteAction, onEdit: { toEdit = $0 }))
    }
    
    private func editDetail(ctx: DetailerContext<MStrategy>, element: Binding<MStrategy>) -> some View {
        let disableKey = ctx.originalID != newElement.primaryKey
        return Form {
            TextField("Strategy ID", text: element.strategyID)
                .disabled(disableKey)
                .validate(ctx, element, \.strategyID) { $0.count > 0 }
            
            StringField("Strategy Title", text: element.title)
        }
    }
    
    // MARK: - Locals
    
    private typealias Sort = TablerSort<MStrategy>
    private typealias DConfig = DetailerConfig<MStrategy>
    private typealias TConfig = TablerStackConfig<MStrategy>
    
    private var dconfig: DConfig {
        DConfig(
            onDelete: deleteAction,
            onSave: saveAction,
            titler: { _ in ("Strategy") })
    }
    
    @State var toEdit: MStrategy? = nil
    @State var selected: MStrategy.ID? = nil
    @State private var hovered: MStrategy.ID? = nil
    
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
                    results: model.strategies,
                    selected: $selected)
            }
            .editDetailer(dconfig,
                          toEdit: $toEdit,
                          originalID: toEdit?.id,
                          detailContent: editDetail)
    }
    
    // MARK: - Action Handlers
    
    private func deleteAction(element: MStrategy) {
        model.delete(element)
    }
    
    private func editAction(_ id: MStrategy.ID?) -> MStrategy? {
        guard let _id = id else { return nil }
        return model.strategies.first(where: { $0.id == _id })
    }
    
    private func saveAction(ctx: DetailerContext<MStrategy>, element: MStrategy) {
        let isNew = ctx.originalID == newElement.primaryKey
        model.save(element,
                   to: \.strategies,
                   originalID: isNew ? nil : ctx.originalID)
    }
    
    private var newElement: MStrategy {
        MStrategy(strategyID: "", title: nil)
    }
    
    private func clearAction() {
        model.strategies.forEach { model.delete($0) }
    }
    
    private func exportAction() {
        let finFormat = AllocFormat.CSV
        if let data = try? exportData(model.strategies, format: finFormat),
           let ext = finFormat.defaultFileExtension
        {
            let name = MStrategy.entityName.plural.replacingOccurrences(of: " ", with: "-")
#if os(macOS)
            NSSavePanel.saveData(data, name: name, ext: ext, completion: { _ in })
#endif
        }
    }
}
