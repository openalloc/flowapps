//
//  CurrencyField.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//


import SwiftUI

public struct CurrencyField: View {
    private var placeholder: String
    @Binding private var value: Double
    private let onEditingChanged: OnEditingChanged?
    private let onCommit: OnCommit?

    public init(_ placeholder: String = "",
                value: Binding<Double>,
                onEditingChanged: OnEditingChanged? = nil,
                onCommit: OnCommit? = nil) {
        self.placeholder = placeholder
        _value = value
        self.onEditingChanged = onEditingChanged
        self.onCommit = onCommit
    }
    
    public var body: some View {
        BaseField(placeholder,
                  value: $value,
                  plainFormatter: plainFormatAction,
                  fancyFormatter: fancyFormatAction,
                  fancyParser: fancyParseAction,
                  onEditingChanged: onEditingChanged,
                  onCommit: onCommit)
            .multilineTextAlignment(.trailing)
    }

    private func plainFormatAction(_ val: Double) -> String {
        let f = currencyRegularFormatter.maximumFractionDigits
        return String(format: "%.\(f)f", val)
    }

    private func fancyFormatAction(_ val: Double) -> String {
        currencyRegularFormatter.string(from: NSNumber(value: val)) ?? ""
    }

    private func fancyParseAction(_ newProxy: String) -> Double? {
        currencyRegularFormatter.number(from: newProxy)?.doubleValue
    }
}
