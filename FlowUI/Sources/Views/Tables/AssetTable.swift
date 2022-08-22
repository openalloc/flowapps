//
//  AssetTable.swift
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

public struct AssetTable: View {
    
    // MARK: - Parameters
    
    @Binding private var model: BaseModel
    private let ax: BaseContext
    
    public init(model: Binding<BaseModel>, ax: BaseContext) {
        _model = model
        self.ax = ax
    }
    
    // MARK: - Field Metadata
    
    private var gridItems: [GridItem] = [
        GridItem(.flexible(minimum: 80), spacing: columnSpacing, alignment: .leading),
        GridItem(.flexible(minimum: 250), spacing: columnSpacing, alignment: .leading),
        GridItem(.flexible(minimum: 140), spacing: columnSpacing, alignment: .leading),
        GridItem(.flexible(minimum: 80, maximum: 150), spacing: columnSpacing, alignment: .leading),
    ]

    // MARK: - Views
    
    typealias Context = TablerContext<MAsset>
    
    private func header(_ ctx: Binding<Context>) -> some View {
        LazyVGrid(columns: gridItems, alignment: .leading, spacing: flowColumnSpacing) {
            Sort.columnTitle("Asset ID", ctx, \.assetID)
                .onTapGesture { tablerSort(ctx, &model.assets, \.assetID) { $0.primaryKey < $1.primaryKey } }
                .modifier(HeaderCell())
            Sort.columnTitle("Asset Class", ctx, \.title)
                .onTapGesture { tablerSort(ctx, &model.assets, \.title) { ($0.title ?? "") < ($1.title ?? "") } }
                .modifier(HeaderCell())
            Sort.columnTitle("Parent Asset Class", ctx, \.parentAssetID)
                .onTapGesture { tablerSort(ctx, &model.assets, \.parentAssetID) { $0.parentAssetKey < $1.parentAssetKey } }
                .modifier(HeaderCell())
            Sort.columnTitle("Color Code", ctx, \.colorCode)
                .onTapGesture { tablerSort(ctx, &model.assets, \.colorCode) { ($0.colorCode ?? 0) < ($1.colorCode ?? 0) } }
                .modifier(HeaderCell())
        }
        //.padding(outsideRowHeader)
    }
    
    private func row(_ element: MAsset) -> some View {
        LazyVGrid(columns: gridItems, alignment: .leading, spacing: flowColumnSpacing) {
            Text(element.assetID)
                .mpadding()
            Text(element.title ?? "")
                .colorCapsule(assetColorPair(element.primaryKey))
            //.modifier(Cell(element.colorCode, .trailing))
            Text(getAssetTitle(element.parentAssetKey) ?? " ")
                .colorCapsule(parentAssetColorPair(element.primaryKey))
                .opacity(element.parentAssetKey.isValid ? 1 : 0)
            //.modifier(Cell(element.colorCode, .center))
            Text("Color Code: \(getColorCodeStr(element.colorCode))")
                .colorCapsule(getColor(element.colorCode))
                //.modifier(Cell(element.colorCode, .leading))
        }
        //.padding(outsideRowHeader)        // hover/select appears outside this
        .modifier(EditDetailerContextMenu(element,
                                          canDelete: canDeleteAction,
                                          onDelete: deleteAction,
                                          onEdit: { toEdit = $0 }))
    }
    
    private func editDetail(ctx: DetailerContext<MAsset>, element: Binding<MAsset>) -> some View {
        let disableKey = ctx.originalID != newElement.primaryKey
        return Form {
            TextField("Asset ID", text: element.assetID)
                .disabled(disableKey)
                .validate(ctx, element, \.assetID) { $0.count > 0 }
            
            StringField("Asset Class", text: element.title)
            
            AssetIDPicker(assets: parentCandidateAssets(element.wrappedValue),
                          assetID: element.parentAssetID) {
                Text("Parent Asset Class")
            }
            
            ColorCodePicker(colorCode: element.colorCode)
        }
    }
    
    // MARK: - Locals
    
    private typealias Sort = TablerSort<MAsset>
    private typealias DConfig = DetailerConfig<MAsset>
    
    private var dconfig: DConfig {
        DConfig(
            canDelete: canDeleteAction,
            onDelete: deleteAction,
            onSave: saveAction,
           titler: { _ in ("Asset") }
        )
    }
    
    @State var toEdit: MAsset? = nil
    @State var selected: MAsset.ID? = nil
    @State var hovered: MAsset.ID? = nil
    
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
                    results: model.assets,
                    selected: $selected)
            }
            .editDetailer(dconfig,
                          toEdit: $toEdit,
                          originalID: toEdit?.id,
                          detailContent: editDetail)
    }
    
    // MARK: - Helpers
    
    private func getColorCodeStr(_ colorCode: Int?) -> String {
        guard let cc = colorCode else { return "(none)" }
        return "\(cc)"
    }
    
    // don't allow a child of current asset to be assigned as its parent. Or itself.
    private func parentCandidateAssets(_ asset: MAsset) -> [MAsset] {
        asset.getParentCandidates(relatedTree: ax.relatedTree,
                                  assets: model.assets)
    }
    
    private var assetMap: AssetMap {
        if ax.assetMap.count > 0 {
            return ax.assetMap
        }
        return model.makeAssetMap()
    }
    
    private func getAssetTitle(_ assetKey: AssetKey?) -> String? {
        guard let assetKey_ = assetKey,
              let asset = assetMap[assetKey_] else { return nil }
        return asset.title
    }

    private func assetColorPair(_ assetKey: AssetKey) -> (Color, Color) {
        getColor(assetMap[assetKey]?.colorCode)
    }
    
    private func parentAssetColorPair(_ parentAssetkey: AssetKey) -> (Color, Color) {
        getColor(assetMap[parentAssetkey]?.colorCode)
    }
    
    // MARK: - Action Handlers
    
    private func deleteAction(element: MAsset) {
        model.delete(element)
    }
    
    private func editAction(_ id: MAsset.ID?) -> MAsset? {
        guard let _id = id else { return nil }
        return model.assets.first(where: { $0.id == _id })
    }
    
    private func saveAction(ctx: DetailerContext<MAsset>, element: MAsset) {
        let isNew = ctx.originalID == newElement.primaryKey
        model.save(element,
                   to: \.assets,
                   originalID: isNew ? nil : ctx.originalID)
    }
    
    private var newElement: MAsset {
        MAsset(assetID: "", title: "", colorCode: 0, parentAssetID: nil)
    }
    
    private func clearAction() {
        let elements = model.assets.filter { canDeleteAction($0) }
        elements.forEach { model.delete($0) }
    }
    
    private func canDeleteAction(_ asset: MAsset?) -> Bool {
        guard let asset_ = asset else { return false }
        return asset_.primaryKey != MAsset.cashAssetKey
    }
    
    private func exportAction() {
        let finFormat = AllocFormat.CSV
        if let data = try? exportData(model.assets, format: finFormat),
           let ext = finFormat.defaultFileExtension
        {
            let name = MAsset.entityName.plural.replacingOccurrences(of: " ", with: "-")
#if os(macOS)
            NSSavePanel.saveData(data, name: name, ext: ext, completion: { _ in })
#endif
        }
    }
}
