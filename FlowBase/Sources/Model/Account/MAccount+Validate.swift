//
//  MAccount+Validate.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

import AllocData

extension MAccount.Key {
    /// return true if the required components of the key are non-blank
    public var isValid: Bool {
        self.accountNormID != ""
    }
}

extension BaseModel {
    public func validate(for key: AccountKey) throws {
        guard key.isValid
        else {
            throw FlowBaseError.validationFailure("'\(key.accountNormID)' is not a valid account key.")
        }
        guard containsKey(key, keyPath: \.accounts)
        else {
            throw FlowBaseError.validationFailure("'\(key.accountNormID)' cannot be found in accounts.")
        }
    }
}

extension MAccount: BaseValidator {
    
    public func validate(epsilon: Double = 0.0001) throws {
        guard primaryKey.isValid else {
            throw FlowBaseError.validationFailure("Invalid primary key for account: [\(primaryKey)].")
        }
    }

    public func validate(against model: BaseModel, isNew: Bool) throws {
        if isNew {
            guard !model.containsKey(primaryKey, keyPath: \.accounts)
            else {
                throw FlowBaseError.validationFailure("Conflicting account numbers '\(accountID)'.")
            }
        }

        guard !model.hasConflictingTitle(self, keyPath: \.accounts)
        else {
            throw FlowBaseError.validationFailure("Conflicting titles '\(title ?? "")'.")
        }
    }
}
