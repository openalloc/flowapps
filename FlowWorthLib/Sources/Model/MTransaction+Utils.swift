//
//  MTransaction+Utils.swift
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

extension MTransaction: HPositionKeyed {
    // the key, but without snapshotID (used in validation)
    public var positionKey: HPositionKey {
        HPositionKey(accountID: accountID, securityID: securityID, lotID: lotID)
    }
}

extension MTransaction {    
    var marketValue: Double? {
        guard let _sharePrice = sharePrice else { return nil }
        return shareCount * _sharePrice
    }
    
    static func getMarketValue(_ txns: [MTransaction]) -> Double? {
        let mvs = txns.map(\.marketValue)
        guard mvs.allSatisfy({ $0 != nil }) else { return nil }
        return mvs.reduce(0) { $0 + $1! }
    }
}
