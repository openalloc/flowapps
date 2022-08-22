//
//  WelcomeView.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//


import SwiftUI

public struct WelcomeView<Content>: View where Content: View {
    @AppStorage(UserDefShared.userAgreedTermsAt.rawValue) var userAgreedTermsAt: String = ""
    
    @EnvironmentObject private var infoMessageStore: InfoMessageStore
    
    var content: () -> Content
    
    public init(content: @escaping () -> Content) {
        self.content = content
    }
    
    public var body: some View {
        VStack {
            Text("Welcome to \(Bundle.main.applicationName ?? "")!")
                .font(.largeTitle)
                .padding()
            
            if userAcknowledgedTerms {
                //GettingStarted(document: $document)
                content()
            } else {
                MustAcknowledgeTerms()
            }
        }
    }
    
    private var userAcknowledgedTerms: Bool {
        userAgreedTermsAt.trimmingCharacters(in: .whitespaces).count > 0
    }
}
