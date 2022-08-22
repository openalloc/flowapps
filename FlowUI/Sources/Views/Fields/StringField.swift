//
//  StringField.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//


import SwiftUI

public struct StringField: View {
    private var placeholder: String
    @Binding private var value: String?
    private var onEditingChanged: OnEditingChanged?
    private var onCommit: OnCommit?

    public init(_ placeholder: String = "",
                text: Binding<String?>,
                onEditingChanged: OnEditingChanged? = nil,
                onCommit: OnCommit? = nil)
    {
        self.placeholder = placeholder
        _value = text
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
    }

    private func plainFormatAction(_ str: String?) -> String {
        str ?? ""
    }

    private func fancyFormatAction(_ str: String?) -> String {
        str ?? ""
    }

    private func fancyParseAction(_ newProxy: String) -> String? {
        newProxy
    }
}
