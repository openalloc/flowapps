//
//  StatsBoxView.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//


import SwiftUI

public struct StatsBoxView<Content: View>: View {
    var title: String
    var content: () -> Content

    public init(title: String,
         @ViewBuilder content: @escaping () -> Content)
    {
        self.title = title
        self.content = content
    }

    public var body: some View {
        GroupBox(label: titleLabel) {
            VStack { // needed to keep content together; uses normal vert spacing
                content()
            }
            .frame(maxWidth: .infinity) // excluding maxHeight, as it was making boxes too big
        }
    }

    private var titleLabel: some View {
        Text(title.uppercased())
            .foregroundColor(.secondary)
            .lineLimit(1)
    }
}

public struct StatusDisplay<T>: View {
    
    var title: String?
    var value: T
    var format: (T) -> String
    var textStyle: Font.TextStyle
    var enabled: Bool

    public init(title: String? = nil, value: T, format: @escaping (T) -> String, textStyle: Font.TextStyle = .title2, enabled: Bool = true) {
        self.title = title
        self.value = value
        self.format = format
        self.textStyle = textStyle
        self.enabled = enabled
    }

    public var body: some View {
        VStack {
            if let title_ = title {
                Text(title_)
                    .font(.callout)
                    .lineLimit(1)
                    .foregroundColor(.secondary)
                    .padding(.bottom, 2)
            }
            Text(enabled ? format(value) : "n/a")
                .font(.system(textStyle, design: .monospaced))
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
