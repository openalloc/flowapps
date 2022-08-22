//
//  MyToggleButton.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//


import SwiftUI

public struct MyToggleButton: View {
    @Binding var value: Bool
    var imageName: String
    
    public init(value: Binding<Bool>, imageName: String) {
        _value = value
        self.imageName = imageName
    }
    
    public var body: some View {
        Button(action: { value.toggle() }) {
            Image(systemName: imageName)
        }
        .buttonStyle(BorderlessButtonStyle())
    }
}
