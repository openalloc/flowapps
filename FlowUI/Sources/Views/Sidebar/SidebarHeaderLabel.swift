//
//  SidebarHeaderLabel.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//


import SwiftUI

public struct SidebarHeaderLabel: View {
    let title: String
    let letter: String
    let fill: LinearGradient

    public init(title: String, letter: String, fill: LinearGradient) {
        self.title = title
        self.letter = letter
        self.fill = fill
    }
    
    public var body: some View {
        HStack(spacing: 5) {
            PrefixedLabel(letter, width: 20, height: 20, fill: fill, format: { Text($0) }, textStyle: .headline) {
                
                Text(title)
                    .bold()
                    .textCase(.uppercase)
                    .font(.callout)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
