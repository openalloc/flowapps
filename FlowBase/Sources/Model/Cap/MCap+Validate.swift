//
//  MCap+Validate.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

import AllocData

extension MCap.Key {
    /// return true if the required components of the key are non-blank
    public var isValid: Bool {
        self.accountNormID != "" && self.assetNormID != ""
    }
}

extension MCap: BaseValidator {
    
    public var isLimitPctValid: Bool {
        (0.0 ... 1.0).contains(limitPct)
    }
    
    public func validate(epsilon: Double = 0.0001) throws {
        guard primaryKey.isValid else {
            throw FlowBaseError.validationFailure("Invalid primary key for cap: [\(primaryKey)].")
        }

        guard isLimitPctValid else {
            throw FlowBaseError.validationFailure("'\(limitPct.format3())' is not a valid limit percent for account cap.")
        }
    }

    public func validate(against model: BaseModel, isNew: Bool) throws {
        if isNew {
            guard !model.containsKey(primaryKey, keyPath: \.caps)
            else {
                throw FlowBaseError.validationFailure("Conflicting cap '\(accountID)' and '\(assetID)'.")
            }
        }

        // Foreign Key validation

        try model.validate(for: accountKey)
        try model.validate(for: assetKey)
    }
}
