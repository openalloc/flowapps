//
//  MonoCell.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//


import SwiftUI

public struct MonoCell<Content: View>: View {
    let content: () -> Content

    public init(content: @escaping () -> Content) {
        self.content = content
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            content()
        }
        .padding(.horizontal, 3)
        .padding(.vertical, 5)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .foregroundColor(fgColor)
        .background(bgColor.opacity(0.2))
    }
    
    private var fgColor: Color {
        #if os(macOS)
        //Color(.windowBackgroundColor)
        Color(.controlTextColor)
        #else
        Color.primary
        #endif
    }
    
    private var bgColor: Color {
        #if os(macOS)
        //Color(.windowBackgroundColor)
        Color(.controlBackgroundColor)
        #else
        Color.secondary
        #endif
    }
}

