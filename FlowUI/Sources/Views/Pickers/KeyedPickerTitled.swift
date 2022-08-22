//
//  KeyedPicker.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import SwiftUI

import FlowBase
import AllocData

public struct KeyedPickerTitled<T, Label>: View where T: Hashable & Comparable & AllocKeyed & Titled, Label: View {
    var elements: [T]
    @Binding var key: T.Key
    var label: () -> Label

    public init(elements: [T], key: Binding<T.Key>,
                @ViewBuilder label: @escaping () -> Label) {
        self.elements = elements
        _key = key
        self.label = label
    }
    
    public var body: some View {
        Picker(selection: $key, label: label()) {
            Text("None (Select One)")
                .tag(T.emptyKey)
            ForEach(elements, id: \.self) { element in
                Text(element.titleID)
                    .tag(element.primaryKey)
            }
        }
        .contrast(1.1) // otherwise not readable in dark mode
    }

    // may be needed on iOS
//    private var alignedTitle: some View {
//        HStack {
//            Text(label)
//                .lineLimit(1)
//                .multilineTextAlignment(.leading)
//            Spacer()
//        }
//    }
    
//    private var sortedElements: [T] {
//        elements.sorted()
//    }
}


public struct KeyedPicker<T, Label>: View where T: Hashable & Comparable & AllocKeyed, Label: View {
    var elements: [T]
    @Binding var key: T.Key
    var getTitle: (T) -> String
    var label: () -> Label

    public init(elements: [T], key: Binding<T.Key>,
                
                getTitle: @escaping (T) -> String,
                @ViewBuilder label: @escaping () -> Label) {
        self.elements = elements
        _key = key
        self.getTitle = getTitle
        self.label = label
    }
    
    public var body: some View {
        Picker(selection: $key, label: label()) {
            Text("None (Select One)")
                .tag(T.emptyKey)
            ForEach(elements, id: \.self) { element in
                Text(getTitle(element))
                    .tag(element.primaryKey)
            }
        }
        .contrast(1.1) // otherwise not readable in dark mode
    }

    // may be needed on iOS
//    private var alignedTitle: some View {
//        HStack {
//            Text(label)
//                .lineLimit(1)
//                .multilineTextAlignment(.leading)
//            Spacer()
//        }
//    }
//
//    private var elements: [T] {
//        elements.sorted()
//    }
}
