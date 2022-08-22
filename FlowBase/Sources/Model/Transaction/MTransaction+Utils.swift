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

public extension MTransaction {
    
    var isSell: Bool {
        action == .buysell && shareCount < 0
    }
    
    var isBuy: Bool {
        action == .buysell && shareCount > 0
    }
    
    // used to highlight cells in table
    func needsRealizedGain(_ thirtyDaysBack: Date?,
                           _ securityMap: SecurityMap,
                           _ accountMap: AccountMap) -> Bool
    {
        guard isSell,
              let thirtyDaysBack_ = thirtyDaysBack,
              securityKey.isValid,
              let security = securityMap[securityKey],
              !security.isCashAsset,
              accountKey.isValid,
              let account = accountMap[accountKey],
              account.isTaxable,
              account.isActive,
              transactedAt > thirtyDaysBack_
        else { return false }
        return realizedGainShort == nil && realizedGainLong == nil
    }
}
