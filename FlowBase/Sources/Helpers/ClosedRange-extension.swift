//
//  ClosedRange-extension.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

public extension ClosedRange {
    func clamp(_ value: Bound) -> Bound {
        lowerBound > value
            ? lowerBound
            : (upperBound < value ? upperBound : value)
    }
}
