//
//  MyToolbarToggle.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//


import SwiftUI

public struct MyToolbarToggle: View {
    @Binding var value: Bool
    var imageNames: (String, String)
    
    public init(value: Binding<Bool>, imageNames: (String, String)) {
        _value = value
        self.imageNames = imageNames
    }
    
    public var body: some View {
        Button(action: { value.toggle() }) {
            Image(systemName: value ? imageNames.1 : imageNames.0)
        }
    }
}
