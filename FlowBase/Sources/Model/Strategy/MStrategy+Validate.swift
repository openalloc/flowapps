//
//  MStrategy+Validate.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

import AllocData


extension MStrategy.Key {
    /// return true if the required components of the key are non-blank
    public var isValid: Bool {
        self.strategyNormID != ""
    }
}

extension BaseModel {
    public func validate(for key: StrategyKey) throws {
        guard key.isValid
        else {
            throw FlowBaseError.validationFailure("'\(key.strategyNormID)' is not a valid strategy key.")
        }
        guard containsKey(key, keyPath: \.strategies)
        else {
            throw FlowBaseError.validationFailure("'\(key.strategyNormID)' cannot be found in strategies.")
        }
    }
}

extension MStrategy: BaseValidator {
    public func validate(epsilon: Double = 0.0001) throws {

        guard primaryKey.isValid else {
            throw FlowBaseError.validationFailure("Invalid primary key for strategy: [\(primaryKey)].")
        }
    }

    public func validate(against model: BaseModel, isNew: Bool) throws {
        if isNew {
            guard !model.containsKey(primaryKey, keyPath: \.strategies)
            else {
                throw FlowBaseError.validationFailure("Conflicting strategy '\(strategyID)'.")
            }
        }

        guard !model.hasConflictingTitle(self, keyPath: \.strategies)
        else {
            throw FlowBaseError.validationFailure("Conflicting titles '\(title ?? "")'.")
        }
    }
}

extension MStrategy {
    
    // validation of allocations and holdings of a strategy
    public func validateDeep(against ax: BaseContext) throws {
        
        let strategyKey = self.primaryKey
        let allocations = ax.model.allocations.filter { $0.strategyKey == strategyKey }
        let assetMap = ax.assetMap
        for allocation in allocations {
            guard case let assetKey = allocation.assetKey,
                  assetMap[assetKey] != nil
            else {
                throw FlowBaseError.validationFailure("'\(allocation.assetID)' is not a valid asset class. Check your allocations for strategy.")
            }
        }
        
        // in case the allocations don't add up to 100%
        let allocs = AssetValue.getAssetValues(allocations: allocations)
        try AssetValue.validateAllocs(allocs)
    }
}
