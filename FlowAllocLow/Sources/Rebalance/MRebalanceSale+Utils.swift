//
//  MRebalanceSale+Utils.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

import AllocData

import FlowBase


public extension MRebalanceSale {
    
    static func getSales(_ accountSalesMap: AccountSalesMap) -> [MRebalanceSale] {
        accountSalesMap.reduce(into: []) { array, entry in
            let (_, sales) = entry // [AccountKey: [Sale]]
            sales.forEach { sale in
                sale.liquidateHoldings.forEach { lh in
                    guard let amount = lh.fractionalValue else { return }
                    let msale = MRebalanceSale(accountID: lh.holding.accountID,
                                               securityID: lh.holding.securityID,
                                               lotID: lh.holding.lotID,
                                               amount: amount,
                                               shareCount: lh.fractionalShareCount,
                                               liquidateAll: lh.fraction.isEqual(to: 1.0, accuracy: 0.001))
                    array.append(msale)
                }
            }
        }
    }
    
}
