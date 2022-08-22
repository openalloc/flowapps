//
//  PreferencesButton.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import SwiftUI

public struct PreferencesButton<Content>: View where Content: View {
    
    var content: () -> Content
    
    public init(content: @escaping () -> Content) {
        self.content = content
    }
        
    public var body: some View {
        #if os(macOS)
        Button(action: {
            NSApp.sendAction(Selector(("showPreferencesWindow:")), to: nil, from: nil)
        }) {
            content()
        }
        //.buttonStyle(BorderlessButtonStyle())
        #endif
    }
}
