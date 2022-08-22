//  PrefixedLabel.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import SwiftUI

public struct PrefixedLabel<T, Prefix, Suffix>: View where Prefix: View, Suffix: View {
    
    private var value: T
    private var width: CGFloat
    private var height: CGFloat
    private var fill: LinearGradient
    private var prefixFormatter: (T) -> Prefix
    private var textStyle: Font.TextStyle
    private var suffixContent: () -> Suffix
   
    public init(_ value: T,
                width: CGFloat,
                height: CGFloat,
                fill: LinearGradient,
                format: @escaping (T) -> Prefix,
                textStyle: Font.TextStyle = .caption2,
                content: @escaping () -> Suffix) {
        self.value = value
        self.width = width
        self.height = height
        self.fill = fill
        self.prefixFormatter = format
        self.textStyle = textStyle
        self.suffixContent = content
    }
    
    public var body: some View {
        HStack {
            prefix
            suffixContent()
        }
    }
    
    private var prefix: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 3)
                .fill(fill) // .opacity(0.75))
                .frame(width: width, height: height)
            prefixFormatter(value)
                .font(.system(textStyle, design: .monospaced))
                .lineLimit(1)
                //.font(.caption)
                .foregroundColor(.white)
                .shadow(radius: 1, x: 1, y: 1)
        }
        .compositingGroup()
        .shadow(radius: 2)
        .padding(.leading, 2)
    }
}
