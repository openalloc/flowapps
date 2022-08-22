//
//  AccountTable.swift
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

public struct AccountTable: View {
    
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
        GridItem(.flexible(minimum: 120), spacing: columnSpacing, alignment: .leading),
        GridItem(.flexible(minimum: 300), spacing: columnSpacing, alignment: .leading),
        GridItem(.flexible(minimum: 100, maximum: 130), spacing: columnSpacing, alignment: .center),
        GridItem(.flexible(minimum: 100, maximum: 130), spacing: columnSpacing, alignment: .center),
    ]
    
    // MARK: - Views
    
    typealias Context = TablerContext<MAccount>
    
    private func header(_ ctx: Binding<Context>) -> some View {
        LazyVGrid(columns: gridItems, alignment: .leading) {
            Sort.columnTitle("Account Number", ctx, \.accountID)
                .onTapGesture { tablerSort(ctx, &model.accounts, \.accountID) { $0.primaryKey < $1.primaryKey } }
                .modifier(HeaderCell())
            Sort.columnTitle("Account Title", ctx, \.title)
                .onTapGesture { tablerSort(ctx, &model.accounts, \.title) { ($0.title ?? "") < ($1.title ?? "") } }
                .modifier(HeaderCell())
            Sort.columnTitle("Strategy", ctx, \.strategyID)
                .onTapGesture { tablerSort(ctx, &model.accounts, \.strategyID) { $0.strategyKey < $1.strategyKey } }
                .modifier(HeaderCell())
            Sort.columnTitle("Taxable?", ctx, \.isTaxable)
                .onTapGesture { tablerSort(ctx, &model.accounts, \.isTaxable) { $0.isTaxable.description < $1.isTaxable.description } }
                .modifier(HeaderCell())
            Sort.columnTitle("Tradeable?", ctx, \.canTrade)
                .onTapGesture { tablerSort(ctx, &model.accounts, \.canTrade) { $0.canTrade.description < $1.canTrade.description } }
                .modifier(HeaderCell())
        }
        //.padding(.horizontal, 15)
    }
    
    private func brow(_ element: Binding<MAccount>) -> some View {
        LazyVGrid(columns: gridItems, alignment: .leading) {
            Text(element.wrappedValue.accountID)
                .mpadding()
            Text(element.wrappedValue.title ?? "")
                .mpadding()
            StrategyIDPicker(strategies: strategies,
                             strategyID: element.strategyID) { Text("") }
                             .labelsHidden()
            Toggle(isOn: element.isTaxable, label: { Text("") })
                .labelsHidden()
            Toggle(isOn: element.canTrade, label: { Text("") })
                .labelsHidden()
        }
        //.padding(.vertical, 10)
        .modifier(EditDetailerContextMenu(element.wrappedValue,
                                          canDelete: canDeleteAction,
                                          onDelete: deleteAction,
                                          onEdit: { toEdit = $0 }))
    }
    
    private func editDetail(ctx: DetailerContext<MAccount>, element: Binding<MAccount>) -> some View {
        let disableKey = ctx.originalID != newElement.primaryKey
        return Form {
            TextField("Account Number", text: element.accountID)
                .disabled(disableKey)
                .validate(ctx, element, \.accountID) { $0.count > 0 }
            
            StringField("Account Title", text: element.title)

            StrategyIDPicker(strategies: strategies,
                             strategyID: element.strategyID) {
                Text("Strategy")
            }
            
            Toggle(isOn: element.isTaxable, label: { Text("Is Taxable?") })
            Toggle(isOn: element.canTrade, label: { Text("Can Trade?") })
        }
    }
    
    // MARK: - Locals
    
    private typealias Sort = TablerSort<MAccount>
    private typealias DConfig = DetailerConfig<MAccount>
    
    private var strategies: [MStrategy] {
        self.model.strategies.sorted()
    }
    
    private var dconfig: DConfig {
        DConfig(
            //canEdit: { _ in true },
            canDelete: canDeleteAction,
            onDelete: deleteAction,
            onValidate: validateAction,
            onSave: saveAction,
            titler: { _ in ("Account") })
    }
    
    @State private var toEdit: MAccount? = nil
    @State private var selected: MAccount.ID? = nil
    @State private var hovered: MAccount.ID? = nil

    public var body: some View {
        BaseModelTable(
            selected: $selected,
            toEdit: $toEdit,
            onAdd: { newElement },
            onEdit: editAction,
            onClear: clearAction,
            onExport: exportAction,
            onDelete: dconfig.onDelete) {
                TablerStack1B(
                    .init(onHover: { if $1 { hovered = $0 } else { hovered = nil } }),
                    header: header,
                    row: brow,
                    rowBackground: { MyRowBackground($0, hovered: hovered, selected: selected) },
                    results: $model.accounts,
                    selected: $selected)
                .sideways(minWidth: 1050, showIndicators: true)
            }
            .editDetailer(dconfig,
                          toEdit: $toEdit,
                          originalID: toEdit?.id,
                          detailContent: editDetail)
            .onChange(of: model.accounts) { _ in
                
                // ensure toggling canTrade automatically updates sidebar, as an example
                
                NotificationCenter.default.post(name: .refreshContext, object: model.id)
            }
    }
    
    // MARK: - Action Handlers
    
    private func canDeleteAction(_ element: MAccount) -> Bool {
        !element.strategyKey.isValid
    }
    
    private func clearAction() {
        let elements = model.accounts.filter { canDeleteAction($0) }
        elements.forEach { model.delete($0) }
    }
    
    private func deleteAction(element: MAccount) {
        model.delete(element)
    }
    
    private func validateAction(_ ctx: DetailerContext<MAccount>, _ account: MAccount) -> [String] {
        do {
            try account.validate()
            try account.validate(against: model, isNew: ctx.originalID == MAccount.emptyKey)
        } catch let error as FlowBaseError {
            return [error.description]
        } catch {
            return [error.localizedDescription]
        }
        return []
    }
    
    private func editAction(_ id: MAccount.ID?) -> MAccount? {
        guard let _id = id else { return nil }
        return model.accounts.first(where: { $0.id == _id })
    }
    
    private func saveAction(ctx: DetailerContext<MAccount>, element: MAccount) {
        let isNew = ctx.originalID == newElement.primaryKey
        model.save(element,
                   to: \.accounts,
                   originalID: isNew ? nil : ctx.originalID)
    }
    
    private var newElement: MAccount {
        MAccount(accountID: "", title: "", isActive: false, isTaxable: false, canTrade: false, strategyID: "")
    }
    
    private func exportAction() {
        let finFormat = AllocFormat.CSV
        if let data = try? exportData(model.accounts, format: finFormat),
           let ext = finFormat.defaultFileExtension
        {
            let name = MAccount.entityName.plural.replacingOccurrences(of: " ", with: "-")
#if os(macOS)
            NSSavePanel.saveData(data, name: name, ext: ext, completion: { _ in })
#endif
        }
    }
}
