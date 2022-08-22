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

import FlowBase
import AllocData

public enum ReturnsExtent: Int, CaseIterable, Codable {
    case positiveOnly
    case all
    case negativeOnly
    
    public static let _default: ReturnsExtent = .all
}

public enum ReturnsGrouping: Int, CaseIterable, Codable {
    case assets
    case accounts
    case strategies
    
    public static let _default: ReturnsGrouping = .assets
}

public enum ReturnsColor: Int, CaseIterable, Codable {
    case color
    case mono
    
    public static let _default: ReturnsColor = .color
}


public enum PeriodSummarySelection: Int, CaseIterable, Codable {
    case deltaMarketValue
    case deltaTotalBasis
    case modifiedDietz
    
    public var isDelta: Bool { self == .deltaMarketValue || self == .deltaTotalBasis }
    public var isDietz: Bool { self == .modifiedDietz }
    
    public static let _default: PeriodSummarySelection = .deltaMarketValue
}

public enum TabsPrimaryReturns: Int, CaseIterable, Codable {
    case chart
    case assets
    case accounts
    case strategies
    case forecast
    
    public static let defaultTab = TabsPrimaryReturns.chart
    public static let storageKey = "PrimaryReturnsTab"
}

public enum TabsSecondaryReturns: Int, CaseIterable, Codable {
    case assets
    case accounts
    case delta
    case dietz
    case forecast

    public static let defaultTab = TabsSecondaryReturns.assets
    public static let storageKey = "SecondaryReturnsTab"
}

public enum TabsPositionsBuilder: Int, CaseIterable, Codable {
    case holdings
    case positions
    case previousPositions

    public static let defaultTab = TabsPositionsBuilder.positions
    public static let storageKey = "PositionsBuilderTab"
}

public enum TabsCashflowBuilder: Int, CaseIterable, Codable {
    case transactions
    case nuCashflow
    case prevCashflow

    public static let defaultTab = TabsCashflowBuilder.nuCashflow
    public static let storageKey = "CashflowBuilderTab"
}

public enum TabsSummaryBuilder: Int, CaseIterable, Codable {
    case assets
    case accounts
    case strategies

    public static let defaultTab = TabsSummaryBuilder.assets
    public static let storageKey = "SummaryBuilderTab"
}

// settings not requiring a context-reset
public struct DisplaySettings: Equatable, Codable {
    public var activeSidebarMenuKey: String?
    public var returnsExpandBottom: Bool
    public var showSecondary: Bool
    public var showChartLegend: Bool
    public var excludedAssetMap: [AssetKey: Bool]
    public var excludedAccountMap: [AccountKey: Bool]
    public var begSnapshotKey: SnapshotKey
    public var endSnapshotKey: SnapshotKey
    public var orderedAssetKeys: [AssetKey]
    public var returnsGrouping: ReturnsGrouping
    public var returnsColor: ReturnsColor
    public var returnsExtent: ReturnsExtent
    public var periodSummarySelection: PeriodSummarySelection
    public var builderCapturedAt: Date
    public var pendingExcludedTxnMap: [TransactionKey: Bool]
    public var snapshotSummaryKey: SnapshotKey
    public var primaryReturnsTab: TabsPrimaryReturns
    public var secondaryReturnsTab: TabsSecondaryReturns
    public var builderPositionsTab: TabsPositionsBuilder
    public var builderCashflowTab: TabsCashflowBuilder
    public var builderSummaryTab: TabsSummaryBuilder
    
    public enum CodingKeys: String, CodingKey, CaseIterable {
        case activeSidebarMenuKey
        case returnsExpandBottom
        case showSecondary
        case showChartLegend
        case excludedAssetMap
        case excludedAccountMap
        case begSnapshotKey
        case endSnapshotKey
        case orderedAssetKeys
        case returnsGrouping
        case returnsColor
        case returnsExtent
        case periodSummarySelection
        case builderCapturedAt
        case pendingExcludedTxnMap
        case snapshotSummaryKey
        case primaryReturnsTab
        case secondaryReturnsTab
        case builderPositionsTab
        case builderCashflowTab
        case builderSummaryTab
    }
    
    public init() {
        activeSidebarMenuKey = ""
        returnsExpandBottom = false
        showSecondary =  false
        showChartLegend =  false
        excludedAssetMap = [:]
        excludedAccountMap = [:]
        begSnapshotKey = MValuationSnapshot.Key.empty
        endSnapshotKey = MValuationSnapshot.Key.empty
        orderedAssetKeys = []
        returnsGrouping = ReturnsGrouping._default
        returnsColor = ReturnsColor._default
        returnsExtent = ReturnsExtent._default
        periodSummarySelection = PeriodSummarySelection._default
        builderCapturedAt = Date.init(timeIntervalSinceReferenceDate: 0)
        pendingExcludedTxnMap = [:]
        snapshotSummaryKey = MValuationSnapshot.Key.empty
        primaryReturnsTab = .defaultTab
        secondaryReturnsTab = .defaultTab
        builderPositionsTab  = .defaultTab
        builderCashflowTab  = .defaultTab
        builderSummaryTab  = .defaultTab
    }

    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        activeSidebarMenuKey = try c.decodeIfPresent(String.self, forKey: .activeSidebarMenuKey) ?? ""
        returnsExpandBottom = try c.decodeIfPresent(Bool.self, forKey: .returnsExpandBottom) ?? false
        showSecondary = try c.decodeIfPresent(Bool.self, forKey: .showSecondary) ?? false
        showChartLegend = try c.decodeIfPresent(Bool.self, forKey: .showChartLegend) ?? false
        excludedAssetMap = try c.decodeIfPresent([AssetKey: Bool].self, forKey: .excludedAssetMap) ?? [:]
        excludedAccountMap = try c.decodeIfPresent([AccountKey: Bool].self, forKey: .excludedAccountMap) ?? [:]
        
        begSnapshotKey = try c.decodeIfPresent(SnapshotKey.self, forKey: .begSnapshotKey) ?? MValuationSnapshot.Key.empty
        endSnapshotKey = try c.decodeIfPresent(SnapshotKey.self, forKey: .endSnapshotKey) ?? MValuationSnapshot.Key.empty
        
        orderedAssetKeys = try c.decodeIfPresent([AssetKey].self, forKey: .orderedAssetKeys) ?? []
        
        returnsGrouping = try c.decodeIfPresent(ReturnsGrouping.self, forKey: .returnsGrouping) ?? ReturnsGrouping._default
        returnsColor = try c.decodeIfPresent(ReturnsColor.self, forKey: .returnsColor) ?? ReturnsColor._default
        returnsExtent = try c.decodeIfPresent(ReturnsExtent.self, forKey: .returnsExtent) ?? ReturnsExtent._default
        periodSummarySelection = try c.decodeIfPresent(PeriodSummarySelection.self, forKey: .periodSummarySelection) ?? PeriodSummarySelection._default
        
        builderCapturedAt = try c.decodeIfPresent(Date.self, forKey: .builderCapturedAt) ?? Date.init(timeIntervalSinceReferenceDate: 0)
        
        pendingExcludedTxnMap = try c.decodeIfPresent([TransactionKey: Bool].self, forKey: .pendingExcludedTxnMap) ?? [:]
        
        snapshotSummaryKey = try c.decodeIfPresent(MValuationSnapshot.Key.self, forKey: .snapshotSummaryKey) ?? MValuationSnapshot.Key.empty
        
        primaryReturnsTab = try c.decodeIfPresent(TabsPrimaryReturns.self, forKey: .primaryReturnsTab) ?? .defaultTab
        secondaryReturnsTab = try c.decodeIfPresent(TabsSecondaryReturns.self, forKey: .secondaryReturnsTab) ?? .defaultTab

        builderPositionsTab = try c.decodeIfPresent(TabsPositionsBuilder.self, forKey: .builderPositionsTab) ?? .defaultTab
        builderCashflowTab = try c.decodeIfPresent(TabsCashflowBuilder.self, forKey: .builderCashflowTab) ?? .defaultTab
        builderSummaryTab = try c.decodeIfPresent(TabsSummaryBuilder.self, forKey: .builderSummaryTab) ?? .defaultTab
    }
}
