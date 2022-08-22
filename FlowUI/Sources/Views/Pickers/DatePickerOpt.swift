//
//  DatePickerOpt.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import SwiftUI

public struct DatePickerOpt: View {
    
    private let title: String
    @Binding private var selection: Date?
    private let inRange: ClosedRange<Date>
    private let defaultDate: Date
    private let displayedComponents: DatePickerComponents

    public init(_ title: String,
                selection: Binding<Date?>,
                in inRange: ClosedRange<Date> = Date.distantPast...Date.distantFuture,
                defaultDate: Date = Date(),
                displayedComponents: DatePickerComponents = [.date]) {
        self.title = title
        _selection = selection
        self.inRange = inRange
        self.defaultDate = defaultDate
        self.displayedComponents = displayedComponents
    }
    
    public var body: some View {
        if selection == nil {
            TextField(title, text: .constant(""))
                .disabled(true)
                .contentShape(Rectangle())
                .onTapGesture {
                    self.selection = defaultDate
                }
        } else {
            HStack {
                DatePicker(title, selection: dateBinding, in: inRange, displayedComponents: displayedComponents)
                
                Button(action: { self.selection = nil }) {
                    //Text("clear")
                    Image(systemName: "xmark.circle")
                }
                .buttonStyle(BorderlessButtonStyle())
            }
        }
    }
    
    private var dateBinding: Binding<Date> {
        Binding(get: { self.selection ?? defaultDate },
                set: { self.selection = $0 })
    }
}
