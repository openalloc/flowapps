//
//  MValuationSnapshot+Validate.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

import AllocData

extension MValuationSnapshot.Key {
    /// return true if the required components of the key are non-blank
    public var isValid: Bool {
        self.snapshotNormID != ""
    }
}

extension BaseModel {
    public func validate(for key: SnapshotKey) throws {
        guard key.isValid
        else {
            throw FlowBaseError.validationFailure("'\(key.snapshotNormID)' is not a valid snapshot key.")
        }
        guard containsKey(key, keyPath: \.valuationSnapshots)
        else {
            throw FlowBaseError.validationFailure("'\(key.snapshotNormID)' cannot be found in snapshots.")
        }
    }
}

extension MValuationSnapshot: BaseValidator {
    public func validate(epsilon: Double = 0.0001) throws {
        guard primaryKey.isValid else {
            throw FlowBaseError.validationFailure("Invalid primary key for snapshot: [\(primaryKey)].")
        }
    }

    public func validate(against model: BaseModel, isNew: Bool) throws {
        
        if isNew {
            guard !model.containsKey(primaryKey, keyPath: \.valuationSnapshots)
            else {
                throw FlowBaseError.validationFailure("Conflicting snapshot '\(snapshotID)'.")
            }
        }
    }
}
