//
//  PercentField.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//


import SwiftUI

import FlowBase

public struct PercentField: View {
    private var placeholder: String
    @Binding private var value: Double
    private var onEditingChanged: OnEditingChanged?
    private var onCommit: OnCommit?

    public init(_ placeholder: String = "",
                value: Binding<Double>,
                onEditingChanged: OnEditingChanged? = nil,
                onCommit: OnCommit? = nil) {
        self.placeholder = placeholder
        _value = value
        self.onEditingChanged = onEditingChanged
        self.onCommit = onCommit
    }

    let range = 0.0 ... 1.0

    public var body: some View {
        BaseField(placeholder,
                  value: $value,
                  plainFormatter: plainFormatAction,
                  fancyFormatter: fancyFormatAction,
                  fancyParser: fancyParseAction,
                  onEditingChanged: onEditingChanged,
                  onCommit: onCommit)
    }

    private func plainFormatAction(_ val: Double) -> String {
        (val * 100).format1()
    }

    private func fancyFormatAction(_ val: Double) -> String {
        percentFormatter1.string(from: NSNumber(value: val)) ?? ""
    }

    private func fancyParseAction(_ newProxy: String) -> Double {
        if let newValue = percentFormatter1.number(from: newProxy)?.doubleValue {
            let newValue1 = range.clamp(newValue)

            // round value to three decimal places
            return (newValue1 * 1000).rounded() / 1000
        }

        return 0
    }
}
