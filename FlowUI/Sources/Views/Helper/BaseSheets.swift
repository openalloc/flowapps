//
//  BaseSheets.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//


import SwiftUI

import AllocData

import FlowBase

// NOTE: this monstrostity is necessary because .sheet modals don't work inside of NavigationView

public struct BaseSheets: View
{
    public init() {}
    
    @State private var showTerms = false
    
    private let showTermsPublisher = NotificationCenter.default.publisher(for: .showTerms)
    
    public var body: some View
    {
        VStack
        {
            HStack {}.sheet(isPresented: $showTerms) { TermsView(showTerms: $showTerms, onUpdate: {}) }
        }
        .onReceive(showTermsPublisher) { p in
            showTerms = true
        }
    }
}
