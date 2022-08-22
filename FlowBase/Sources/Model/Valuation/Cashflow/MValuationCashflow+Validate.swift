//
//  MValuationCashflow+Validate.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

import AllocData


extension MValuationCashflow.Key {
    /// return true if the required components of the key are non-blank
    public var isValid: Bool {
        self.accountNormID != "" && self.assetNormID != ""
    }
}

extension MValuationCashflow: BaseValidator {
    public func validate(epsilon: Double = 0.0001) throws {
        
        guard primaryKey.isValid else {
            throw FlowBaseError.validationFailure("Invalid primary key for cash flow: [\(primaryKey)].")
        }
    }

    public func validate(against model: BaseModel, isNew: Bool) throws {
        
        if isNew {
            guard !model.containsKey(primaryKey, keyPath: \.valuationCashflows)
            else {
                throw FlowBaseError.validationFailure("Conflicting cash flow '\(accountID)' and '\(assetID)'.")
            }
        }
        
        try model.validate(for: accountKey)
        try model.validate(for: assetKey)
    }
}
