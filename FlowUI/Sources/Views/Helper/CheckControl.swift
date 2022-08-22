//
//  CheckControl.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//


import SwiftUI

public struct CheckControl<T: Hashable>: View {
    let element: T
    let onCheck: OnCheck<T>
    let isChecked: IsChecked<T>
    
    public init(element: T, onCheck: @escaping OnCheck<T>, isChecked: @escaping IsChecked<T>) {
        self.element = element
        self.onCheck = onCheck
        self.isChecked = isChecked
    }
    
    public var body: some View {
        Button(action: {
            let oldVal = isChecked(element)
            let newVal = !oldVal
            onCheck([element], newVal)
        }, label: {
            let checked = isChecked(element)
            Image(systemName: "checkmark").opacity(checked ? 0 : 1)
        })
    }
}
