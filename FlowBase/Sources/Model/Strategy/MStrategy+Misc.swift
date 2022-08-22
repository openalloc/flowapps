//
//  MStrategy+Misc.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

import AllocData

extension MStrategy.Key: CustomStringConvertible {
    public var description: String {
        "StrategyID: '\(strategyNormID)'"
    }
}

extension MStrategy: Titled {
    public var titleID: String {
        guard let title_ = title else { return strategyID }
        return title_ == strategyID ? title_ : "\(title_) (\(strategyID))"
    }
}

public extension MStrategy {
    static func getStrategyTitleID(_ strategyKey: StrategyKey?, _ strategyMap: StrategyMap, withID: Bool) -> String? {
        guard let strategy = getStrategy(strategyKey, strategyMap)
        else { return nil }
        return withID ? strategy.titleID : strategy.title
    }

    private static func getStrategy(_ strategyKey: StrategyKey?, _ strategyMap: StrategyMap) -> MStrategy? {
        guard let strategyKey_ = strategyKey,
              strategyKey_.isValid,
              let strategy = strategyMap[strategyKey_] else { return nil }
        return strategy
    }
}
