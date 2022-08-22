//
//  MHolding+Misc.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

import AllocData

extension MHolding.Key: CustomStringConvertible {
    public var description: String {
        "AccountID: '\(accountNormID)', SecurityID: '\(securityNormID)', LotID: '\(lotNormID)'"
    }
}

public extension MHolding {
    func getPresentValue(_ securityMap: SecurityMap) -> Double? {
        guard securityKey.isValid,
              let sharePrice = securityMap[securityKey]?.sharePrice,
              let shareCount_ = shareCount
        else { return nil }
        return sharePrice * shareCount_
    }

    func getGainLoss(_ securityMap: SecurityMap) -> Double? {
        guard let pv = getPresentValue(securityMap),
              let costBasis_ = costBasis else { return nil }
        return pv - costBasis_
    }

    func getGainLossPercent(_ securityMap: SecurityMap) -> Double? {
        guard let presentValue = getPresentValue(securityMap),
              presentValue != 0,
              let gainLoss = getGainLoss(securityMap)
        else { return nil }
        return gainLoss / presentValue
    }

    var costBasis: Double? {
        guard let shareBasis_ = shareBasis,
              let shareCount_ = shareCount
        else { return nil }
        return shareCount_ * shareBasis_
    }

    static func getHoldings(for accounts: [MAccount], accountHoldingsMap: AccountHoldingsMap) -> [MHolding] {
        let accountKeys = accounts.map(\.primaryKey)
        return accountKeys.compactMap { accountHoldingsMap[$0] }.flatMap { $0 }.sorted()
    }
}

extension MHolding: HPositionKeyed {
    // the key, but without snapshotID (used in validation)
    public var positionKey: HPositionKey {
        HPositionKey(accountID: accountID, securityID: securityID, lotID: lotID)
    }
}

