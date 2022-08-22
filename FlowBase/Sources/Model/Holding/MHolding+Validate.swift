//
//  MHolding+Validate.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

import AllocData


extension MHolding.Key {
    /// return true if the required components of the key are non-blank
    public var isValid: Bool {
        // ignore lotID, which can be blank
        self.accountNormID != "" && self.securityNormID != ""
    }
}

extension MHolding: BaseValidator {
    
    public var isShareBasisValid: Bool {
        guard let _shareBasis = shareBasis,
              _shareBasis >= 0
        else { return false }
        return true
    }
    
    public func validate(epsilon: Double = 0.0001) throws {
        guard primaryKey.isValid else {
            throw FlowBaseError.validationFailure("Invalid primary key for holding: [\(primaryKey)].")
        }

        guard isShareBasisValid else {
            throw FlowBaseError.validationFailure("'\(shareBasis?.format2() ?? "")' is not a valid share basis for holding.")
        }

        // NOTE ignoring acquiredAt
    }

    public func validate(against model: BaseModel, isNew: Bool) throws {
        
        if isNew {
            guard !model.containsKey(primaryKey, keyPath: \.holdings)
            else {
                throw FlowBaseError.validationFailure("Conflicting holding '\(accountID)' and '\(securityID)'.")
            }
        }
        
        // Foreign Key validation
        
        try model.validate(for: securityKey)
        try model.validate(for: accountKey)
    }
}
