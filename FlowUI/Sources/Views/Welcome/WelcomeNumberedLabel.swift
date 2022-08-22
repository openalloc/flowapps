//
//  WelcomeNumberedLabel.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import SwiftUI

import Compactor

fileprivate var wholeFormatter = NumberCompactor(ifZero: nil, roundSmallToWhole: true)

public struct WelcomeNumberedLabel<Content>: View where Content: View {
    
    private var value: Int
    private var fill: LinearGradient
    private var content: () -> Content
    
    public init(_ value: Int,
                fill: LinearGradient,
                content: @escaping () -> Content) {
        self.value = value
        self.fill = fill
        self.content = content
    }
    
    public var body: some View {
        PrefixedLabel(value, width: 25, height: 25, fill: fill, format: formatter, textStyle: .title2, content: content)
    }
    
    private func formatter(value: Int) -> some View {
        Text(wholeFormatter.string(from: NSNumber(value: value)) ?? "")
    }
}

