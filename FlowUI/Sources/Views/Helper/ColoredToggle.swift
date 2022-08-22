//
//  ColoredToggle.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import SwiftUI

public struct ColoredToggle<Label>: View
    where Label: View
{
    @Binding var on: Bool
    var color: Color
    var enabled: Bool = true
    let label: () -> Label
    
    public init(on: Binding<Bool>, color: Color, enabled: Bool = true, label: @escaping () -> Label) {
        _on = on
        self.color = color
        self.enabled = enabled
        self.label = label
    }

    public var body: some View {
        Toggle(isOn: $on, label: {
            ZStack {
                RoundedRectangle(cornerRadius: 3)
                    .fill(color.opacity(on ? 0.75 : 0.25))
                    .shadow(radius: 1, x: 2, y: 2)
                HStack {
                    label()
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(on ? 0.75 : 0.5))
                }
                .padding(3)
            }
        })
            .disabled(!enabled)
    }
}

public struct ColoredSystemImageToggle: View {
    @Binding var on: Bool
    var color: Color
    let systemImageNameOn: String
    let systemImageNameOff: String
    var enabled: Bool = true
    var help: String

    public init(on: Binding<Bool>, color: Color, systemImageNameOn: String, systemImageNameOff: String, enabled: Bool = true, help: String) {
        _on = on
        self.color = color
        self.systemImageNameOn = systemImageNameOn
        self.systemImageNameOff = systemImageNameOff
        self.enabled = enabled
        self.help = help
    }
    
    public var body: some View {
        Toggle(isOn: $on, label: {
                Image(systemName: on || !enabled ? systemImageNameOn : systemImageNameOff)
                    .foregroundColor(enabled ? color.opacity(on ? 1.0 : 0.8) : disabledControlTextColor)
        })
            .help(help)
            .disabled(!enabled)
    }
    
    private var disabledControlTextColor: Color {
        #if os(macOS)
        Color(.disabledControlTextColor)
        #else
        Color.secondary
        #endif
    }

}

public struct InspectorToggle: View {
    @Binding var on: Bool

    public init(on: Binding<Bool>) {
        _on = on
    }
    
    public var body: some View {
        Button(action: {
            on.toggle()
        }) {
            Label("Secondary", systemImage: "sidebar.right")
                .foregroundColor(controlTextColor)
        }
        .help("Toggle Inspector")
    }
    
    private var controlTextColor: Color {
        #if os(macOS)
        Color(.controlTextColor)
        #else
        Color.primary
        #endif
    }

}

// struct ColoredToggle_Previews: PreviewProvider {
//    static var previews: some View {
//        ColoredToggle()
//    }
// }
