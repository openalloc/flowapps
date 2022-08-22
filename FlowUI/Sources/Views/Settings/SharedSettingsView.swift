//
//  SharedSettingsView.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import os
import SwiftUI

public struct SharedSettingsView<General: View>: View {
    
    let termsURL: URL
    let privacyURL: URL
    let general: () -> General

    public init(termsURL: URL,
                privacyURL: URL,
                general: @escaping () -> General) {
        self.termsURL = termsURL
        self.privacyURL = privacyURL
        self.general = general
    }
    
    public var body: some View {
        VStack {
//            TabView(selection: $tab) {

                general()
//                    .tabItem {
//                        Label("General", systemImage: "gearshape")
//                    }
//                    .tag(TabsSettings.general)
//            }
        }
        .padding(.bottom, 50) // otherwise message at bottom will be truncated
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
