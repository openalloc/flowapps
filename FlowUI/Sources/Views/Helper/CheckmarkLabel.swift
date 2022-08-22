//
//  CheckmarkLabel.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import SwiftUI

public struct CheckmarkLabel: View {
    private var value: Bool
    public init(_ value: Bool) {
        self.value = value
    }
    public var body: some View {
        Image(systemName: "checkmark").opacity(value ? 1 : 0)
        //Image(systemName: value ? "checkmark.square" : "square")
    }
}
