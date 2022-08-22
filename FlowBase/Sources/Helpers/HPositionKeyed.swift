//
//  HPositionKeyed.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

import AllocData

public protocol HPositionKeyed {
    var positionKey: HPositionKey { get }
}

public struct HPositionKey: Hashable, Codable {
    let accountNormID: String
    let securityNormID: String
    let lotNormID: String
    
    public init(accountID: AccountID,
                securityID: SecurityID,
                lotID: LotID) {
        self.accountNormID = MHolding.normalizeID(accountID)
        self.securityNormID = MHolding.normalizeID(securityID)
        self.lotNormID = MHolding.normalizeID(lotID)
    }
}
