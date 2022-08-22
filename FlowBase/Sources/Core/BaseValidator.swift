//
//  BaseValidator.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

public protocol BaseValidator {
    // independent of model
    func validate(epsilon: Double) throws

    // dependent of other data in model
    func validate(against model: BaseModel, isNew: Bool) throws
}
