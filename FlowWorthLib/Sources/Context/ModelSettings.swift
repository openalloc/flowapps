//
//  ModelSettings.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

import FlowBase
import AllocData

// settings usually requiring a results/context reset
// shouldn't include navigation-oriented settings, such as tab selection or navigation state
// okay to include infrequently-changed formatting details, such as locale
public struct ModelSettings: Equatable, Codable {
    public var activeStrategyKey: StrategyKey

    public static let defaultActiveStrategyKey = MStrategy.emptyKey

    public enum CodingKeys: String, CodingKey, CaseIterable {
        case activeStrategyKey
    }

    public init() {
        activeStrategyKey = ModelSettings.defaultActiveStrategyKey
    }

    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        activeStrategyKey = try c.decodeIfPresent(MStrategy.Key.self, forKey: .activeStrategyKey) ?? ModelSettings.defaultActiveStrategyKey
    }
}
