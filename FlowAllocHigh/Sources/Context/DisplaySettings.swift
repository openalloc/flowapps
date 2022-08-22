//
//  DisplaySettings.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

import FlowAllocLow
import FlowBase
import AllocData

public enum MoneySelection: Int, CaseIterable, Codable {
    case percentOfAccount
    case percentOfStrategy
    case amountOfStrategy
    case presentValue
    case gainLossAmount
    case gainLossPercent
    case orphaned

    // used to decide whether to invert if limit exceeded
    public var isTargetValue: Bool {
        self == .percentOfAccount ||
            self == .percentOfStrategy ||
            self == .amountOfStrategy
    }
}

// settings not requiring a context-reset
public struct DisplaySettings: Codable, Equatable {
    public var params: BaseParams
    public var activeSidebarMenuKey: String?
    public var strategyShowVariable: Bool
    public var strategyShowFixed: Bool
    public var strategyExpandBottom: Bool
    public var showSecondary: Bool
    public var strategyMoneySelection: MoneySelection
    public var accountSummarySelection: SummarySelection

    static let defaultActiveSidebarMenuKey = ""
    static let defaultStrategyShowVariable = true
    static let defaultStrategyShowFixed = false
    static let defaultStrategyExpandBottom = false
    static let defaultShowSecondary = false
    static let defaultStrategyMoneySelection = MoneySelection.percentOfAccount
    static let defaultAccountSummarySelection = SummarySelection.presentValue

    public enum CodingKeys: String, CodingKey, CaseIterable {
        case params
        case activeSidebarMenuKey
        case strategyShowVariable
        case strategyShowFixed
        case strategyExpandBottom
        case showSecondary
        case strategyMoneySelection
        case accountSummarySelection
    }

    public init(params: BaseParams? = nil) {
        self.params = params ?? BaseParams()
        activeSidebarMenuKey = DisplaySettings.defaultActiveSidebarMenuKey
        strategyShowVariable = DisplaySettings.defaultStrategyShowVariable
        strategyShowFixed = DisplaySettings.defaultStrategyShowFixed
        strategyExpandBottom = DisplaySettings.defaultStrategyExpandBottom
        showSecondary = DisplaySettings.defaultShowSecondary
        strategyMoneySelection = DisplaySettings.defaultStrategyMoneySelection
        accountSummarySelection = DisplaySettings.defaultAccountSummarySelection
    }

    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        params = try c.decodeIfPresent(BaseParams.self, forKey: .params) ?? BaseParams()
        activeSidebarMenuKey = try c.decodeIfPresent(String.self, forKey: .activeSidebarMenuKey) ?? DisplaySettings.defaultActiveSidebarMenuKey
        strategyShowVariable = try c.decodeIfPresent(Bool.self, forKey: .strategyShowVariable) ?? DisplaySettings.defaultStrategyShowVariable
        strategyShowFixed = try c.decodeIfPresent(Bool.self, forKey: .strategyShowFixed) ?? DisplaySettings.defaultStrategyShowFixed
        strategyExpandBottom = try c.decodeIfPresent(Bool.self, forKey: .strategyExpandBottom) ?? DisplaySettings.defaultStrategyExpandBottom
        showSecondary = try c.decodeIfPresent(Bool.self, forKey: .showSecondary) ?? DisplaySettings.defaultShowSecondary
        strategyMoneySelection = try c.decodeIfPresent(MoneySelection.self, forKey: .strategyMoneySelection) ?? DisplaySettings.defaultStrategyMoneySelection
        accountSummarySelection = try c.decodeIfPresent(SummarySelection.self, forKey: .accountSummarySelection) ?? DisplaySettings.defaultAccountSummarySelection
    }
}
