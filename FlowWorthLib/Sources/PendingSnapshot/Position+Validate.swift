//
//  Position+Validate.swift
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

extension MValuationPosition {
    
    internal static func validate(holding: MHolding, securityMap: SecurityMap) throws {
        let securityKey = MSecurity.Key(securityID: holding.securityID)
        
        guard holding.accountID != ""
        else { throw WorthError.invalidAccount("in holding") }

        guard let security = securityMap[securityKey]
        else { throw WorthError.invalidSecurity(holding.securityID) }

        guard let sharePrice = security.sharePrice,
              sharePrice > 0
        else { throw WorthError.invalidPosition("Share price must be greater than 0.") }

        guard security.assetID != ""
        else { throw WorthError.invalidAssetClass(holding.securityID) }

        guard let _ = holding.shareBasis
        else { throw WorthError.invalidShareBasis(holding.securityID) }

        guard let _ = holding.shareCount
        else { throw WorthError.invalidShareCount(holding.securityID) }
    }
}
