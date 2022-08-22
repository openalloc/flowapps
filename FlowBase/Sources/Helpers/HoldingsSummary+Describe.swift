//
//  HoldingsSummary+Describe.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

extension HoldingsSummary: CustomStringConvertible {
    public var description: String {
        "presentValue: \(presentValue.currency0()) costBasis: \(costBasis.currency0()) count=\(count)"
    }
}

public extension HoldingsSummary {
    static func describe(_ holdingsSummary: HoldingsSummary, prefix: String? = nil) -> String {
        if let prefix_ = prefix {
            return "\(prefix_): \(holdingsSummary)"
        }
        return holdingsSummary.description
    }
}
