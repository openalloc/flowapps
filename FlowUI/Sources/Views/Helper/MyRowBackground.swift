//
//  MyRowBackground.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import SwiftUI

public struct MyRowBackground<Element>: View
where Element: Identifiable {
    private let element: Element
    private let hovered: Element.ID?
    private let selected: Element.ID?
    
    public init(_ element: Element, hovered: Element.ID?, selected: Element.ID?) {
        self.element = element
        self.hovered = hovered
        self.selected = selected
    }
    
    public var body: some View {
        RoundedRectangle(cornerRadius: 5)
            .fill(Color.accentColor.opacity(selected == element.id
                                            ? 0.8
                                            : (hovered == element.id ? 0.2 : 0.0)))
    }
}
