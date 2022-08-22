//
//  ForwardSum.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

public extension Array where Element: BinaryFloatingPoint {
    
    @inlinable
    func forwardSum(start: Int = 0) -> Element {
        self.suffix(from: start).reduce(0, +)
    }
}

public extension Dictionary where Key: Hashable, Value: BinaryFloatingPoint {
    
    @inlinable
    func forwardSum(order: [Key], start: Int = 0) -> Value {
        order.suffix(from: start).reduce(0) { $0 + (self[$1] ?? 0) }
    }
}
