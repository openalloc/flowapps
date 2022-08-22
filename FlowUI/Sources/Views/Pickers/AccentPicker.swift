//
//  AccentPicker.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//


import SwiftUI

public enum AccentColor: Int, CaseIterable, Codable {
    case blue
    case purple
    case red
    case orange
    case yellow
    case green
    
    var color: Color {
        switch self {
        case .blue:
            return Color.blue
        case .purple:
            return Color.purple
        case .red:
            return Color.red
        case .orange:
            return Color.orange
        case .green:
            return Color.green
        case .yellow:
            return Color.yellow
        }
    }
}

public struct AccentPicker: View {
    
    @Binding var selectedColor: AccentColor
    
    public init(selectedColor: Binding<AccentColor>) {
        _selectedColor = selectedColor
    }
    
    public var body: some View {
        HStack {
            ForEach(AccentColor.allCases, id: \.self) { accentColor in
                ZStack {
                    Image(systemName: "circle.fill")
                        .font(.title)
                        .foregroundColor(accentColor.color)
                        .onTapGesture {
                            selectedColor = accentColor
                        }
                    if accentColor == selectedColor {
                        Image(systemName: "circlebadge.fill")
                            .foregroundColor(.white)
                    }
                }
            }
        }
    }
}
