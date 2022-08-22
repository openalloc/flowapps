//
//  Math.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

public func factorial(_ a: Int) -> Int {
    precondition(a > 0)
    return a == 1 ? a : a * factorial(a - 1)
}

public func fibonacci(_ n: Int) -> Int {
    if n == 0 {
        return 0
    } else if n == 1 {
        return 1
    } else {
        return fibonacci(n - 1) + fibonacci(n - 2)
    }
}
