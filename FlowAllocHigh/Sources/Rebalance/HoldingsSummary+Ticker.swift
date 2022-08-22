//
//  HoldingsSummary+Ticker.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

import AllocData

import FlowAllocLow
import FlowBase


public extension HoldingsSummary {
    // recent purchases in this account for this asset class
    static func getCurrentlyHolding(_ ax: HighContext, accountKey: AccountKey, assetKey: AssetKey) -> TickerHoldingsSummaryMap {
        guard let ahm = ax.mergedAccountAssetHoldingsMap[accountKey],
              let holdings = ahm[assetKey]
        else { return [:] }

        let securityMap = ax.securityMap

        return HoldingsSummary.getTickerSummaryMap(holdings, securityMap)
    }
}
