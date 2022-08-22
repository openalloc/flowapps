//
//  MissingDataModifier.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//


import SwiftUI

public struct MissingDataModifier: ViewModifier {
    private var missingData: Bool

    public init(_ missingData: Bool) {
        self.missingData = missingData
    }

    public func body(content: Content) -> some View {
        Group {
            content
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                .border(missingData ? Color.red : Color.clear)
        }
    }
}
