//
//  HoldingsSummary.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

import AllocData

// can be a summary of any group of holdings, such as for an account, an asset class, or across the entire portfolio

public struct HoldingsSummary: Hashable, Equatable {
    public var presentValue: Double
    public var costBasis: Double
    public var count: Int
    public var tickerShareMap: TickerShareMap

    public init(presentValue: Double = 0, costBasis: Double = 0, count: Int = 0, tickerShareMap: TickerShareMap = [:]) {
        self.presentValue = presentValue
        self.costBasis = costBasis
        self.count = count
        self.tickerShareMap = tickerShareMap
    }

    public var gainLoss: Double {
        presentValue - costBasis
    }

    public var gainLossPercent: Double? {
        guard presentValue != 0 else { return nil }
        return gainLoss / presentValue
    }

    public var unrealizedGain: Double {
        max(0, gainLoss)
    }
}
