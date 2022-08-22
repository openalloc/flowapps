//
//  WarningIndicator.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//


import SwiftUI

public struct WarningIndicator: View {
    let n: Int
    let fgColor: Color
    let bgColor: Color

    public init(n: Int, fgColor: Color = .white, bgColor: Color = .red) {
        self.n = n
        self.fgColor = fgColor
        self.bgColor = bgColor
    }
    
    public var body: some View {
        ZStack {
            Image(systemName: "circle.fill")
                .foregroundColor(bgColor)
                .shadow(radius: 1, x: 2, y: 2)
            Text(netN)
                .lineLimit(1)
                .font(.caption)
                .foregroundColor(fgColor)
        }
        .compositingGroup()
        .shadow(radius: 2)
    }

    private var netN: String {
        switch n {
        case ..<0:
            return "-"
        case 0..<100:
            return String(n)
        default:
            return "!"
        }
    }
}
