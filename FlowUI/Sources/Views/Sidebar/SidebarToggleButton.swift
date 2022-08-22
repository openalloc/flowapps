//
//  SidebarToggleButton.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//


import SwiftUI

public struct SidebarToggleButton: View {
    
    public init() {}
    
    public var body: some View {
        Button(action: toggleSidebar) {
            Label("Sidebar", systemImage: "sidebar.left")
                .foregroundColor(.primary)
        }
        .help("Toggle Sidebar")
    }
    
    // via https://developer.apple.com/forums/thread/651807
    private func toggleSidebar() {
#if os(iOS)
#else
        NSApp.keyWindow?.firstResponder?.tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
#endif
    }
}
