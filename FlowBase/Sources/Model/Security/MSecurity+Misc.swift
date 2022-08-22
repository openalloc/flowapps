//
//  MSecurity+Misc.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

import AllocData

extension MSecurity.Key: CustomStringConvertible {
    public var description: String {
        "SecurityID: '\(securityNormID)'"
    }
}

public extension MSecurity {

    var isCashAsset: Bool {
        assetKey == MAsset.cashAssetKey
    }
    
    func getTitleID(_ assetMap: AssetMap) -> String {
        let suffix: String = {
            let assetKey = self.assetKey
            if assetKey.isValid,
               let assetID = getAssetClass(assetKey, assetMap)
            {
                return " (\(assetID))"
            }
            return ""
        }()
        return "\(securityID)\(suffix)"
    }

    private func getAssetClass(_ assetKey: AssetKey?, _ assetMap: AssetMap) -> AssetID? {
        guard let assetKey_ = assetKey else { return nil }
        return assetMap[assetKey_]?.assetID
    }

    static func getTitleID(_ securityKey: SecurityKey?, _ securityMap: SecurityMap, _ assetMap: AssetMap, withAssetID: Bool) -> String? {
        guard let security = getSecurity(securityKey, securityMap)
        else { return nil }
        return withAssetID ? security.getTitleID(assetMap) : security.securityID
    }

    private static func getSecurity(_ securityKey: SecurityKey?, _ securityMap: SecurityMap) -> MSecurity? {
        guard let securityKey_ = securityKey,
              let security = securityMap[securityKey_] else { return nil }
        return security
    }
    
    static func getTickerKeys(for accounts: [MAccount], accountHoldingsMap: AccountHoldingsMap) -> [SecurityKey] {
        MHolding.getHoldings(for: accounts, accountHoldingsMap: accountHoldingsMap).compactMap { $0.securityKey }
    }
}
