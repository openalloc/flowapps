//
//  MAsset+Validate.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

import AllocData


extension MAsset.Key {
    /// return true if the required components of the key are non-blank
    public var isValid: Bool {
        self.assetNormID != ""
    }
}

extension BaseModel {
    public func validate(for key: AssetKey) throws {
        guard key.isValid
        else {
            throw FlowBaseError.validationFailure("'\(key.assetNormID)' is not a valid asset key.")
        }
        guard containsKey(key, keyPath: \.assets)
        else {
            throw FlowBaseError.validationFailure("'\(key.assetNormID)' cannot be found in assets.")
        }
    }
}

extension MAsset: BaseValidator {
    public func validate(epsilon: Double = 0.0001) throws {
        guard primaryKey.isValid else {
            throw FlowBaseError.validationFailure("Invalid primary key for asset: [\(primaryKey)].")
        }

        guard isTitleValid else {
            throw FlowBaseError.validationFailure("'\(normTitle)' is not a valid title for asset.")
        }
    }

    public func validate(against model: BaseModel, isNew: Bool) throws {
        let _primaryKey = primaryKey

        if isNew {
            guard !model.containsKey(_primaryKey, keyPath: \.assets)
            else {
                throw FlowBaseError.validationFailure("Conflicting asset classes '\(assetID)'.")
            }
        }

        guard !model.hasConflictingTitle(self, keyPath: \.assets)
        else {
            throw FlowBaseError.validationFailure("Conflicting titles '\(title ?? "")'.")
        }

        // Foreign Key validation
        
        // ensure parent "foreign key" is valid
        let map = model.makeAssetMap()
        if parentAssetKey.isValid,
           map[parentAssetKey] == nil
        {
            throw FlowBaseError.validationFailure("'\(parentAssetID)' is not a valid parent asset class for '\(assetID)'.")
        }
        
        let assetKey = primaryKey
        var asset = self
        while asset.parentAssetKey.isValid,
              let parent = map[asset.parentAssetKey]
        {
            if parent.primaryKey == assetKey {
                throw FlowBaseError.validationFailure("Circular reference not allowed.")
            }
            asset = parent
        }
    }
}
