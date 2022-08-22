//
//  MTracker+Validate.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

import AllocData

extension MTracker.Key {
    /// return true if the required components of the key are non-blank
    public var isValid: Bool {
        self.trackerNormID != ""
    }
}

extension BaseModel {
    public func validate(for key: TrackerKey) throws {
        guard key.isValid
        else {
            throw FlowBaseError.validationFailure("'\(key.trackerNormID)' is not a valid tracker key.")
        }
        guard containsKey(key, keyPath: \.trackers)
        else {
            throw FlowBaseError.validationFailure("'\(key.trackerNormID)' cannot be found in index trackers.")
        }
    }
}

extension MTracker: BaseValidator {
    public func validate(epsilon: Double = 0.0001) throws {
        guard primaryKey.isValid else {
            throw FlowBaseError.validationFailure("Invalid primary key for index tracker: [\(primaryKey)].")
        }
    }

    public func validate(against model: BaseModel, isNew: Bool) throws {
        // enforce alt-key uniqueness
        if isNew {
            guard !model.containsKey(primaryKey, keyPath: \.trackers)
            else {
                throw FlowBaseError.validationFailure("Conflicting index tracker '\(trackerID)'.")
            }
        }

        guard !model.hasConflictingTitle(self, keyPath: \.trackers)
        else {
            throw FlowBaseError.validationFailure("Conflicting titles '\(title ?? "")'.")
        }
    }
}
