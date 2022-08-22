//
//  Cashflow+Utils.swift
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

public extension MValuationCashflow {
    
    // net cashflows, total
    static func getNetCashflow(_ items: [MValuationCashflow]) -> Double {
        items.reduce(0) { $0 + $1.amount }
    }
    
    /// net cashflows, mapped by date
    static func getCashflowMap(_ items: [MValuationCashflow]) -> [Date: Double] {
        items.reduce(into: [:]) { map, cashflow in
            map[cashflow.transactedAt, default: 0] += cashflow.amount
        }
    }
}

extension MValuationCashflow {
    static func getAccountAssetValueMap(_ cashflows: [MValuationCashflow]) -> AccountAssetValueMap {
        cashflows.reduce(into: [:]) { map, cashflow in
            map[cashflow.accountAssetKey, default: 0] += cashflow.amount
        }
    }
}

extension MValuationCashflow: AccountAssetKeyed {
    public var accountAssetKey: AccountAssetKey {
        AccountAssetKey(accountID: accountID, assetID: assetID)
    }
}

extension MValuationCashflow: MVTransactionKeyed {
    public var mvTransactionKey: MVTransactionKey {
        MVTransactionKey(accountID: accountID, assetID: assetID, transactedAt: transactedAt)
    }
}
