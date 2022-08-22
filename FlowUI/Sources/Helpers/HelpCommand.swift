//
//  HelpCommand.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import SwiftUI

public struct HelpCommand: View {
    
    @Environment(\.openURL) var openURL
    
    public init() {}
    
    public var body: some View {
        
        Divider()
        
        Button(action: {
            openURL(URL(string: "https://openalloc.github.io/privacy/")!)
        }, label: {
            Text("Privacy Policy")
        })

        Button(action: {
            openURL(URL(string: "https://openalloc.github.io/support/")!)
        }, label: {
            Text("Support")
        })

        Button(action: {
            openURL(URL(string: "https://openalloc.github.io/terms/")!)
        }, label: {
            Text("Terms & Conditions")
        })
    }
}
