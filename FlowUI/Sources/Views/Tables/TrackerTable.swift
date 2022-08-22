//
//  TrackerTable.swift
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

public struct TrackerTable: View {
    
    // MARK: - Parameters
    
    @Binding private var model: BaseModel
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
    
    typealias Context = TablerContext<MTracker>
    
    private func header(_ ctx: Binding<Context>) -> some View {
        LazyVGrid(columns: gridItems, alignment: .leading, spacing: flowColumnSpacing) {
            Sort.columnTitle("Tracker ID", ctx, \.trackerID)
                .onTapGesture { tablerSort(ctx, &model.trackers, \.trackerID) { $0.primaryKey < $1.primaryKey } }
                .modifier(HeaderCell())
            Sort.columnTitle("Tracker Title", ctx, \.title)
                .onTapGesture { tablerSort(ctx, &model.trackers, \.title) { ($0.title ?? "") < ($1.title ?? "") } }
                .modifier(HeaderCell())
        }
    }
    
    private func row(_ element: MTracker) -> some View {
        LazyVGrid(columns: gridItems, alignment: .leading, spacing: flowColumnSpacing) {
            Text(element.trackerID)
                .mpadding()
            Text(element.title ?? "")
                .mpadding()
       }
        .modifier(EditDetailerContextMenu(element, onDelete: deleteAction, onEdit: { toEdit = $0 }))
    }
    
    //@State private var selectedRows = Set<MTracker.ID>()
    
    private func editDetail(ctx: DetailerContext<MTracker>, element: Binding<MTracker>) -> some View {
        let disableKey = ctx.originalID != newElement.primaryKey
        return Form {
            TextField("Tracker ID", text: element.trackerID)
                .disabled(disableKey)
                .validate(ctx, element, \.trackerID) { $0.count > 0 }
            
            StringField("Tracker Title", text: element.title)
        }
    }
    
    // MARK: - Locals
    
    private typealias Sort = TablerSort<MTracker>
    private typealias DConfig = DetailerConfig<MTracker>
    private typealias TConfig = TablerStackConfig<MTracker>
    
    private var dconfig: DConfig {
        DConfig(onDelete: { model.delete($0) },
                onSave: saveAction,
               titler: { _ in ("Tracker") })
    }
    
    @State var toEdit: MTracker? = nil
    @State var selected: MTracker.ID? = nil
    @State private var hovered: MTracker.ID? = nil
    
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
                    results: model.trackers,
                    selected: $selected)
            }
            .editDetailer(dconfig,
                          toEdit: $toEdit,
                          originalID: toEdit?.id,
                          detailContent: editDetail)
    }
    
    // MARK: - Action Handlers
    
    private func deleteAction(element: MTracker) {
        model.delete(element)
    }
    
    private func editAction(_ id: MTracker.ID?) -> MTracker? {
        guard let _id = id else { return nil }
        return model.trackers.first(where: { $0.id == _id })
    }
    
    private func saveAction(ctx: DetailerContext<MTracker>, element: MTracker) {
        let isNew = ctx.originalID == newElement.primaryKey
        model.save(element,
                   to: \.trackers,
                   originalID: isNew ? nil : ctx.originalID)
    }
    
    private var newElement: MTracker {
        MTracker(trackerID: "", title: nil)
    }
    
    private func clearAction() {
        model.trackers.forEach { model.delete($0) }
    }
    
    private func exportAction() {
        let finFormat = AllocFormat.CSV
        if let data = try? exportData(model.trackers, format: finFormat),
           let ext = finFormat.defaultFileExtension
        {
            let name = MTracker.entityName.plural.replacingOccurrences(of: " ", with: "-")
#if os(macOS)
            NSSavePanel.saveData(data, name: name, ext: ext, completion: { _ in })
#endif
        }
    }
}
