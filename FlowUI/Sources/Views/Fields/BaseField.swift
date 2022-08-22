//
//  BaseField.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Combine
import os.log
import SwiftUI

struct BaseField<T: Equatable>: View {
    private let placeHolder: String
    @Binding private var value: T
    private var onEditingChanged: OnEditingChanged?
    private var onCommit: OnCommit?
    private var plainFormatter: PlainFormatter<T>
    private var fancyFormatter: FancyFormatter<T>
    private var fancyParser: FancyParser<T>

    init(_ placeHolder: String = "",
         value: Binding<T>,
         plainFormatter: @escaping PlainFormatter<T>,
         fancyFormatter: @escaping FancyFormatter<T>,
         fancyParser: @escaping FancyParser<T>,
         onEditingChanged: OnEditingChanged? = nil,
         onCommit: OnCommit? = nil)
    {
        self.placeHolder = placeHolder
        _value = value
        self.onEditingChanged = onEditingChanged
        self.onCommit = onCommit
        self.plainFormatter = plainFormatter
        self.fancyFormatter = fancyFormatter
        self.fancyParser = fancyParser

        let initialProxy = fancyFormatter(value.wrappedValue)
        _proxy = State(initialValue: initialProxy)
    }

    // MARK: - Locals

    @State private var proxy: String = ""
    @State private var hasInitialTextValue = false
    @State private var focused = false

    // MARK: - Views

    var body: some View {
        TextField(placeHolder, text: $proxy, onEditingChanged: editingAction, onCommit: commitAction)
            .foregroundColor(focused ? Color.primary : Color.secondary)
            .onReceive(Just(proxy)) { newProxy in

                if newProxy == proxy, !focused {
                    updateProxy() // the value likely changed
                    return
                }

                updateValue(from: newProxy)
            }
    }

    // MARK: - Actions

    private func editingAction(_ isInFocus: Bool) {
        focused = isInFocus

        updateProxy()

        onEditingChanged?(isInFocus)
    }

    private func commitAction() {
        focused = false

        updateValue(from: proxy)

        onCommit?()
    }

    // MARK: - Helpers

    private func updateValue(from newProxy: String) {
        guard let newValue = fancyParser(newProxy) else { return }

        if value != newValue {
            value = newValue
        }
    }

    private func updateProxy() {
        var newProxy: String

        if focused {
            // plain, without currency formatting, suitable for user editing
            newProxy = plainFormatter(value)

        } else {
            newProxy = fancyFormatter(value)
        }

        if proxy != newProxy {
            proxy = newProxy
        }
    }

    private var valueString: String {
        plainFormatter(value)
    }
}
