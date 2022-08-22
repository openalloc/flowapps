//
//  OptimizePriority.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

public enum OptimizePriority: Int, Codable, CaseIterable {
    case high
    case medium
    case low
    case adaptive

    public static let default_: OptimizePriority = .adaptive
}
