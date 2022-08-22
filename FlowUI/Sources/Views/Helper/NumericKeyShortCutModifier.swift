//
//  NumericKeyShortCutModifier.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import SwiftUI

public struct NumericKeyShortCutModifier: ViewModifier {
    public var n: Int
    public var modifiers: EventModifiers // = .command

    public init(n: Int, modifiers: EventModifiers) {
        self.n = n
        self.modifiers = modifiers
    }
    
    public func body(content: Content) -> some View {
        if (1 ... 9).contains(n) {
            content
                .keyboardShortcut(keyEquivalent, modifiers: modifiers)
        } else {
            content
        }
    }

    private var keyEquivalent: KeyEquivalent {
        switch n {
        case 1:
            return "1"
        case 2:
            return "2"
        case 3:
            return "3"
        case 4:
            return "4"
        case 5:
            return "5"
        case 6:
            return "6"
        case 7:
            return "7"
        case 8:
            return "8"
        default:
            return "9"
        }
    }
}
