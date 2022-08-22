//
//  InfoBanner.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//


import SwiftUI

import AllocData

public struct InfoBanner: View {
    @EnvironmentObject private var infoMessageStore: InfoMessageStore

    // MARK: - Parameters

    public let modelID: UUID
    public let accent: Color
    public var onDismiss: (() -> Void)?
    
    // MARK: - Locals
    
    @State private var isPresented = false
    @State private var schemaName: String = ""
    @State private var rejectedRows: [AllocRowed.DecodedRow] = []

    public init(modelID: UUID, accent: Color, onDismiss: (() -> Void)? = nil) {
        self.modelID = modelID
        self.accent = accent
        self.onDismiss = onDismiss
    }
    
    public var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .top) {
                ZStack {
                    Image(systemName: "circle.fill")
                        .foregroundColor(.white)
                    Image(systemName: "info.circle.fill")
                        .foregroundColor(accent)
                }
                .font(.largeTitle)
                .compositingGroup()
                .shadow(radius: 3)
                .padding(.top, 15)

                List(filteredMessages) { msg in
                    HStack {
                        Text(msg.val)
                            .font(.title3)
                            .contextMenu(ContextMenu(menuItems: {
                                Button("Copy", action: {
                                    let someText = msg.val
                    #if os(macOS)
                                    let pasteboard = NSPasteboard.general; pasteboard.declareTypes([.string], owner: nil); pasteboard.setString(someText, forType: .string)
                    #endif
                                    //UIPasteboard.general.string = someText
                                })
                            }))
                        if msg.rejectedRows.count > 0 {
                            Button(action: {
                                schemaName = msg.schemaName ?? msg.val
                                rejectedRows = msg.rejectedRows
                                isPresented = true
                            }) {
                                Text("\(msg.rejectedRows.count) rejected row(s)")
                            }
                            .buttonStyle(LinkButtonStyle())
                        }
                    }
                }
                  
                DismissButton(onDismiss: dismissAction)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 1) // TODO needed to avoid weird scrolling above sidebar
        .padding(.horizontal, 40)
        .contentShape(Rectangle())
        .background(accent.opacity(0.1))
        .border(accent)
        .padding(5)
        .compositingGroup()
        .shadow(radius: 10)
//        .shadow(color: Color.accentColor, radius: 10)

        .sheet(isPresented: $isPresented) { // , onDismiss: { isPresented = false }
            RejectedRowsView(accent: accent,
                             schemaName: $schemaName,
                             rejectedRows: $rejectedRows,
                             onDismiss: { isPresented = false; rejectedRows = [] })
            .padding()
        }
    }
    
    private var filteredMessages: [InfoMessageStore.Message] {
        infoMessageStore.messages(modelID: modelID)
    }
    
    private var controlTextColor: Color {
        #if os(macOS)
        Color(.controlTextColor)
        #else
        Color.primary
        #endif
    }
    
    private var windowBackgroundColor: Color {
        #if os(macOS)
        Color(.windowBackgroundColor)
        #else
        Color.secondary
        #endif
    }
    
    private func dismissAction() {
        infoMessageStore.dismiss(modelID: modelID)
        onDismiss?()
    }
}
