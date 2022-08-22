//
//  View-extensions.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import SwiftUI

// Copyright (c) Vatsal Manot
public extension View {
    // Returns a type-erased version of `self`.
    @inlinable
    func eraseToAnyView() -> AnyView {
        return .init(self)
    }
}

public extension View {
    /**
    Modify the view in a closure. This can be useful when you need to conditionally apply a modifier that is unavailable on certain platforms.

    For example, imagine this code needing to run on macOS too where `View#actionSheet()` is not available:

    ```
    struct ContentView: View {
        var body: some View {
            Text("Unicorn")
                .modify {
                    #if os(iOS)
                    $0.actionSheet(…)
                    #else
                    $0
                    #endif
                }
        }
    }
    ```
    */
    func modify<T: View>(@ViewBuilder modifier: (Self) -> T) -> T {
        modifier(self)
    }
}

/// standard padding
public extension View {
    
    func mpadding() -> some View {
        self
            .padding(.horizontal, 5)
    }
}
