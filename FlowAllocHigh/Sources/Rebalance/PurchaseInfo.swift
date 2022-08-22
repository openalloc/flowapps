//
//  PurchaseInfo.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

import FlowAllocLow
import FlowBase
import AllocData


public struct PurchaseInfo: Equatable {
    public let tickerKey: SecurityKey
    public let shareCount: Double
    public let shareBasis: Double

    public init(tickerKey: SecurityKey, shareCount: Double, shareBasis: Double) {
        self.tickerKey = tickerKey
        self.shareCount = shareCount
        self.shareBasis = shareBasis
    }

    public var basisValue: Double {
        shareCount * shareBasis
    }

    public static func getBasis(_ pies: [PurchaseInfo]) -> Double {
        pies.reduce(0) { $0 + $1.basisValue }
    }
}
