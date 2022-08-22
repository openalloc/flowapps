//
//  BaseModelTable.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import SwiftUI

import Sideways
import Detailer
import Tabler

import FlowBase

// hover/select appears outside this
public let outsideRowHeader = EdgeInsets(top: 2, leading: 7, bottom: 2, trailing: 7)
public let columnSpacing: CGFloat = 5

public struct HeaderCell: ViewModifier {
    public init() { }
    public func body(content: Content) -> some View {
        content
            .padding(.vertical, 4)
            .padding(.horizontal, 8)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 5)
                    .fill(
                        LinearGradient(gradient: .init(colors: [Color.gray.opacity(0.5), Color.gray.opacity(0.3)]),
                                       startPoint: .top,
                                       endPoint: .bottom)))
    }
}

struct Cell: ViewModifier {

    func body(content: Content) -> some View {
        content
            .padding(.vertical, 4)
            .padding(.horizontal, 8)
    }
}

public struct BaseModelTable<Element, Content>: View
where Element: Hashable & Equatable & Identifiable & EntityNamed,
      Content: View {
    
    public typealias MyContent = () -> Content
    
    // MARK: - Parameters
    
    @Binding var selected: Element.ID?
    @Binding var toEdit: Element?
    private let onAdd: () -> Element
    private let onEdit: (Element.ID?) -> Element?
    private let onClear: OnClear?
    private let onExport: OnExport?
    private let onDelete: ((Element) -> Void)?
    private let toolbarContent: AnyViewContent?
    private let content: MyContent
    
    public init(selected: Binding<Element.ID?>,
                toEdit: Binding<Element?>,
                onAdd: @escaping () -> Element,
                onEdit: @escaping (Element.ID?) -> Element?,
                onClear: OnClear? = nil,
                onExport: OnExport? = nil,
                onDelete: ((Element) -> Void)? = nil,
                toolbarContent: AnyViewContent? = nil,
                content: @escaping MyContent) {
        _selected = selected
        _toEdit = toEdit
        self.onAdd = onAdd
        self.onEdit = onEdit
        self.onClear = onClear
        self.onExport = onExport
        self.onDelete = onDelete
        self.toolbarContent = toolbarContent
        self.content = content
    }
    
    // MARK: - Locals
    
    @State private var showClearModal = false
    
    // MARK: - Views
    
    public var body: some View {
        VStack {
            headerBar
                .padding()
            
            Sideways(minWidth: 400) {
                content()
            }
            
            footerBar
                .padding()
            
            HStack {}
            .sheet(isPresented: $showClearModal) {
                ClearRecordsAlert(title: pluralName, onClear: clearAction)
            }
        }
    }
    
    private var headerBar: some View {
        HStack {
            Text(pluralName)
                .font(.title)
            Spacer()
            HelpButton(appName: "shared", topicName: Element.entityName.singular.replacingOccurrences(of: " ", with: "_"))
            addButton
            detailButton
        }
    }
    
    private var footerBar: some View {
        HStack {
            clearButton
            Spacer()
            toolbarContent?()
            Spacer()
            exportButton
        }
    }
    
    private var addButton: some View {
        Button(action: addAction) {
            Image(systemName: "plus")
            //            Label("Add \(singularName)", systemImage: "plus")
        }
    }
    
    private var detailButton: some View {
        Button(action: { detailAction() }) {
            Text("Detail")
        }
        .disabled(selected == nil)
    }
    
    private var exportButton: some View {
        Button(action: exportAction) {
            Text("Export")
        }
    }
    
    private var clearButton: some View {
        Button(action: {
            showClearModal = true
            selected = nil
        }) {
            Text("Clear")
        }
        .disabled(onDelete == nil)
    }
    
    // MARK: - Helpers
    
    private var singularName: String {
        Element.entityName.singular.capitalized
    }
    
    private var pluralName: String {
        Element.entityName.plural.capitalized
    }
    
    // MARK: - Action Handlers
    
    private func addAction() {
        toEdit = onAdd()
    }
    
    private func detailAction() {
        toEdit = onEdit(selected)
    }
    
    private func exportAction() {
        onExport?()
    }
    
    private func clearAction() {
        onClear?()
    }
}
