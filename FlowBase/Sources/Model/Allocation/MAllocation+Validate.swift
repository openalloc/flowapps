//
//  MAllocation+Validate.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

import AllocData

extension MAllocation.Key {
    /// return true if the required components of the key are non-blank
    public var isValid: Bool {
        self.strategyNormID != "" && self.assetNormID != ""
    }
}

extension MAllocation: BaseValidator {
    
    public var isTargetPctValid: Bool {
        (0.0 ... 1.0).contains(targetPct)
    }
    
    public func validate(epsilon: Double = 0.0001) throws {
        guard primaryKey.isValid else {
            throw FlowBaseError.validationFailure("Invalid primary key for allocation: [\(primaryKey)].")
        }

        guard isTargetPctValid else {
            throw FlowBaseError.validationFailure("'\(targetPct.format3())' is not a valid target percent for allocation.")
        }
    }
    
    public func validate(against model: BaseModel, isNew: Bool) throws {
        if isNew {
            guard !model.containsKey(primaryKey, keyPath: \.allocations)
            else {
                throw FlowBaseError.validationFailure("Conflicting allocation '\(strategyID)' and '\(assetID)'.")
            }
        }
        
        // Foreign Key validation
        
        try model.validate(for: strategyKey)
        try model.validate(for: assetKey)
    }
}
