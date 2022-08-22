//
//  ColorCodeLabel.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//


import SwiftUI

struct ColorCodeLabel: View {
    var colorCode: Int?
    
    var body: some View {
        Text(formattedValue)
            .padding(5)
            .foregroundColor(colorPair.0)
            .background(colorPair.1)
    }
    
    private var formattedValue: String {
        let suffix = colorCode != nil && colorCode != 0 ? String(colorCode!) : "(none)"
        return "Color Code: \(suffix)"
    }
    
    private var colorPair: (Color, Color) {
        getColor(colorCode)
    }
}

//struct SwiftUIView_Previews: PreviewProvider {
//    static var previews: some View {
//        SwiftUIView()
//    }
//}
