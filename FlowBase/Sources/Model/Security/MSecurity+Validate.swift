//
//  MSecurity+Validate.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

import AllocData

extension MSecurity.Key {
    /// return true if the required components of the key are non-blank
    public var isValid: Bool {
        self.securityNormID != ""
    }
}

extension BaseModel {
    public func validate(for key: SecurityKey) throws {
        guard key.isValid
        else {
            throw FlowBaseError.validationFailure("'\(key.securityNormID)' is not a valid security key.")
        }
        guard containsKey(key, keyPath: \.securities)
        else {
            throw FlowBaseError.validationFailure("'\(key.securityNormID)' cannot be found in securities.")
        }
    }
}

extension MSecurity: BaseValidator {
    
    public var isSharePriceValid: Bool {
        guard let _sharePrice = sharePrice,
              _sharePrice >= 0
        else { return false }
        return true
    }

    public func validate(epsilon: Double = 0.0001) throws {
        guard primaryKey.isValid else {
            throw FlowBaseError.validationFailure("Invalid primary key for security: [\(primaryKey)].")
        }
        
        if let _sharePrice = sharePrice {
            guard isSharePriceValid else {
                throw FlowBaseError.validationFailure("'\(_sharePrice.format2())' is not a valid share price for security.")
            }
        }
        
        // NOTE: ignoring updatedAt and trackerID
    }

    public func validate(against model: BaseModel, isNew: Bool) throws {
        
       let _primaryKey = primaryKey
        
        if isNew {
            guard !model.containsKey(_primaryKey, keyPath: \.securities)
            else {
                throw FlowBaseError.validationFailure("Conflicting security '\(securityID)'.")
            }
        }

        // Foreign Key validation
        
        if assetKey.isValid {
            try model.validate(for: assetKey)
        }
        if trackerKey.isValid {
            try model.validate(for: trackerKey)
        }
    }
}

extension MSecurity {
    
    public static func validateDeep(against ax: BaseContext) throws {
        
        // ensure that all securities held are priced and have asset class assignments
        let tickers = ax.activeTickersMissingSomething
        if tickers.count > 0 {
            let formattedTickers = tickers.map(\.securityNormID).map { $0.uppercased() }
            let str = ListFormatter.localizedString(byJoining: formattedTickers.sorted())
            throw FlowBaseError.validationFailure("The following securities require additional details: \(str).")
        }
    }
}
