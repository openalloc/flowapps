//
//  Double-extension.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

public extension Double {
    func format0() -> String {
        String(format: "%.0f", self)
    }

    func format1() -> String {
        String(format: "%.1f", self)
    }

    func format2() -> String {
        String(format: "%.2f", self)
    }

    func format3() -> String {
        String(format: "%.3f", self)
    }

    func percent0() -> String {
        String(format: "%.0f%%", self * 100.0)
    }

    func percent1() -> String {
        String(format: "%.1f%%", self * 100.0)
    }

    func percent2() -> String {
        String(format: "%.2f%%", self * 100.0)
    }

    func percent3() -> String {
        String(format: "%.3f%%", self * 100.0)
    }

    func percent4() -> String {
        String(format: "%.4f%%", self * 100.0)
    }

    func currency0() -> String {
        String(format: "$%.0f", self)
    }

    func currency2() -> String {
        String(format: "$%.2f", self)
    }
}

