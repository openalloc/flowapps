//
//  ColorCodePicker.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import SwiftUI

struct ColorCodePicker: View {
    @Binding var colorCode: Int?

    let nilColorCode: Int? = nil
    @State var showPopover = false

    var body: some View {
        HStack {
            ColorCodeLabel(colorCode: colorCode)
            Button(action: { showPopover = true }) {
                Text("Select")
            }
            .popover(isPresented: $showPopover, arrowEdge: .top) {
                colorSelectView
            }
            
            Button(action: { colorCode = nilColorCode }) {
                Text("Clear")
            }
        }
    }
    
    private var colorSelectView: some View {
        VStack {
            List(selection: $colorCode) {
                ForEach(colorKeys, id: \.self) { colorCode in
                    let c = getColor(colorCode)
                    Text("\(colorCode)")
                        .foregroundColor(c.0)
                        .listRowBackground(c.1)
                        .tag(colorCode as Int?)
                }
            }
        }
        .frame(width: 200, height: 300)
    }
    
    private var colorKeys: [Int] {
        Array(colorDict.keys.sorted())
    }
}
