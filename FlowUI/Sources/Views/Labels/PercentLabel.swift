//
//  PercentLabel.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import SwiftUI

public struct PercentLabel: View {
    let value: Double
    var ifZero: String?
    var leadingPlus: Bool

    public init(value: Double?, ifZero: String? = nil, leadingPlus: Bool = false) {
        self.value = value ?? 0
        self.ifZero = ifZero
        self.leadingPlus = leadingPlus
    }

    public var body: some View {
        HStack {
            Spacer(minLength: 0)
            Text(formattedValue)
        }
        .lineLimit(1)
    }
    
    private var formattedValue: String {
        if ifZero != nil && value == 0 {
            return ifZero!
        } else {
            return value.toPercent1(leadingPlus: leadingPlus, ifZero: ifZero)
        }
    }
}
