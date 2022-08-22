//
//  MTransaction+Validate.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

import AllocData

extension MTransaction.Key {
    /// return true if the required components of the key are non-blank
    public var isValid: Bool {
        // ignore security and lotID, which can be blank
        self.accountNormID != ""
    }
}

extension MTransaction: BaseValidator {
    
    public var isSharePriceValid: Bool {
        guard let _sharePrice = sharePrice,
              _sharePrice > 0
        else { return false }
        return true
    }

    // NOTE validation for import, but not for creating snapshots (where share price is needed)
    public func validate(epsilon: Double = 0.0001) throws {
        
        guard primaryKey.isValid else {
            throw FlowBaseError.validationFailure("Invalid primary key for transaction: [\(primaryKey)].")
        }

        // NOTE it's okay for sharePrice to be nil, as in the case of a security transfer where price at transfer isn't specified
        if let _sharePrice = sharePrice {
            guard isSharePriceValid
            else { throw FlowBaseError.validationFailure("'\(_sharePrice.format2())' is not a valid share price for transaction.") }
        }
    }

    public func validate(against model: BaseModel, isNew: Bool) throws {
        
        if isNew {
            guard !model.containsKey(primaryKey, keyPath: \.transactions)
            else {
                throw FlowBaseError.validationFailure("Conflicting transactions '\(accountID)' and '\(securityID)'.")
            }
        }
        
        // Foreign Key validation
        // ignoring, as it's okay to have invalid FKs in transactions (no cascade too)
    }
}
