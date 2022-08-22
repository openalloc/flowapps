//
//  Sale+Loss.swift
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

public extension Sale {
    // Summarize the gainLoss of the specified sales by securityID
    // NOTE: relevant for sales on taxable accounts only
    static func getNetGainLossMap(_ sales: [Sale]) -> TickerAmountMap {
        sales.reduce(into: [:]) { map, sale in
            for lh in sale.liquidateHoldings {
                let securityKey = lh.holding.securityKey
                guard let gainLoss = lh.fractionalGainLoss,
                      securityKey.isValid
                else { continue }
                map[securityKey, default: 0.0] += gainLoss
            }
        }
    }
}
