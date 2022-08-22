//
//  SharesField.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//


import SwiftUI

public struct SharesField: View {
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

    private func plainFormatAction(val: Double) -> String {
        let formatter = sharesRegularFormatter
        let preserved = formatter.usesGroupingSeparator

        formatter.usesGroupingSeparator = false

        let result = formatter.string(from: NSNumber(value: val)) ?? ""

        formatter.usesGroupingSeparator = preserved

        return result
    }

    private func fancyFormatAction(val: Double) -> String {
        return sharesRegularFormatter.string(from: NSNumber(value: val)) ?? ""
    }

    private func fancyParseAction(_ newProxy: String) -> Double? {
        sharesRegularFormatter.number(from: newProxy)?.doubleValue
    }
}
