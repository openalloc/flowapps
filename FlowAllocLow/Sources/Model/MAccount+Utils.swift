//
//  MAccount+Utils.swift
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

public extension MAccount {
    func getCaps(_ model: BaseModel) -> [MCap] {
        model.caps.filter { self.primaryKey == $0.accountKey }
    }
}

public extension BaseModel {
    // obtain a map of Caps, grouped by account
    var capsMap: AccountCapsMap {
        Dictionary(grouping: caps, by: { $0.accountKey })
    }
}

public extension MAccount {
    static func getPresentValue(_ accountKey: AccountKey, _ accountHoldingsMap: AccountHoldingsMap, _ securityMap: SecurityMap) -> Double {
        guard let holdings = accountHoldingsMap[accountKey] else { return 0 }
        return holdings.reduce(0) { $0 + ($1.getPresentValue(securityMap) ?? 0) }
    }

    static func getAccountPresentValueMap(_ accountKeys: [AccountKey], _ accountHoldingsMap: AccountHoldingsMap, _ securityMap: SecurityMap) -> AccountPresentValueMap {
        let presentValues: [Double] = accountKeys.map {
            getPresentValue($0, accountHoldingsMap, securityMap)
        }
        return Dictionary(uniqueKeysWithValues: zip(accountKeys, presentValues))
    }
}
