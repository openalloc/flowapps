//
//  MatrixResultCache.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

import AllocData

import FlowBase

public final class MatrixResultCache {

    public var mrAccountMap: [AccountKey: MatrixResult] = [:]
    public var mrStrategyMap: [StrategyKey: MatrixResult] = [:]
    public var mrStrategyTradingMap: [StrategyKey: MatrixResult] = [:]
    public var mrStrategyNonTradingMap: [StrategyKey: MatrixResult] = [:]

    let ax: WorthContext
    let begSnapshotKey: SnapshotKey
    let endSnapshotKey: SnapshotKey
    let excludedAccountMap: [AccountKey: Bool]
    let orderedAssetKeys: [AssetKey]
    let trackPerformance: Bool
    let timeZone: TimeZone

    public init(ax: WorthContext,
                begSnapshotKey: SnapshotKey = MValuationSnapshot.Key.empty,
                endSnapshotKey: SnapshotKey = MValuationSnapshot.Key.empty,
                excludedAccountMap: [AccountKey: Bool] = [:],
                orderedAssetKeys: [AssetKey] = [],
                trackPerformance: Bool = false,
                timeZone: TimeZone = TimeZone.current) {
        self.ax = ax
        self.begSnapshotKey = begSnapshotKey
        self.endSnapshotKey = endSnapshotKey
        self.excludedAccountMap = excludedAccountMap
        self.orderedAssetKeys = orderedAssetKeys
        self.trackPerformance = trackPerformance
        self.timeZone = timeZone
    }
    
    // MARK: - Lazy Properties
    
    lazy var begSnapshot: MValuationSnapshot? = {
        ax.snapshotMap[begSnapshotKey]
    }()

    lazy var endSnapshot: MValuationSnapshot? = {
        ax.snapshotMap[endSnapshotKey]
    }()

    lazy var orderedSnapshots: ArraySlice<MValuationSnapshot> = {
        guard let _begSnapshot = begSnapshot,
              let _endSnapshot = endSnapshot,
              let snapshots = ax.orderedSnapshots.contiguousValueSlice(startValue: _begSnapshot,
                                                                       endValue: _endSnapshot)
        else { return [] }
        return snapshots
    }()
    
    lazy var snapshotKeys: [SnapshotKey] = {
        orderedSnapshots.map(\.primaryKey)
    }()
    
    lazy var snapshotDateInterval: DateInterval? = {
        guard let _begSnapshot = begSnapshot,
              let _endSnapshot = endSnapshot
        else { return nil }
        return DateInterval(start: _begSnapshot.capturedAt, end: _endSnapshot.capturedAt)
    }()
    
    /// positions filtered down to relevant snapshots (but not by account)
    lazy var positions: [MValuationPosition] = {
        snapshotKeys.reduce(into: []) { array, snapshotKey in
            guard let positions = ax.snapshotPositionsMap[snapshotKey] else { return }
            array.append(contentsOf: positions)
        }
    }()
    
    /// cashflows filtered down to relevant snapshots (but not by account)
    lazy var orderedCashflows: [MValuationCashflow] = {
        snapshotKeys.reduce(into: []) { array, snapshotKey in
            guard let cashflows = ax.snapshotCashflowsMap[snapshotKey] else { return }
            array.append(contentsOf: cashflows)
        }
    }()
    
    // MARK: - Factory
    
    private func generate(accountKeyFilter: @escaping AccountKeyFilter,
                          accountKey: AccountKey = MAccount.emptyKey) -> MatrixResult {
        
        func combinedFilter(_ accountKey: AccountKey) -> Bool {
            accountKeyFilter(accountKey) &&
                !excludedAccountMap[accountKey, default: false]
        }
        
        return MatrixResult(orderedSnapshots: orderedSnapshots,
                            rawOrderedCashflow: orderedCashflows,
                            valuationPositions: positions,
                            accountKeyFilter: combinedFilter,
                            preferredAssetOrder: orderedAssetKeys,
                            timeZone: timeZone,
                            accountMap: ax.accountMap)
    }
    
    // MARK: - Single-Fetchers
    
    public lazy var mrBirdsEye: MatrixResult = {
        generate(accountKeyFilter: { _ in true })
    }()
    
    // MARK: - Filtered Fetchers
    
    // get MR for a single account
    public func getAccountMR(_ accountKey: AccountKey) -> MatrixResult {
        if let mr = mrAccountMap[accountKey] { return mr }
        let nuMR = generate(accountKeyFilter: { accountKey == $0 }, accountKey: accountKey)
        mrAccountMap[accountKey] = nuMR
        return nuMR
    }

    // get MR for a single strategy
    public func getStrategyMR(_ strategyKey: StrategyKey) -> MatrixResult {
        if let mr = mrStrategyMap[strategyKey] { return mr }
        let strategyAccountKeySet: AccountKeySet = ax.strategyAccountKeySetMap[strategyKey] ?? Set()
        let nuMR = generate(accountKeyFilter: { strategyAccountKeySet.contains($0) })
        mrStrategyMap[strategyKey] = nuMR
        return nuMR
    }

    public func getStrategyTradingMR(_ strategyKey: StrategyKey) -> MatrixResult {
        if let mr = mrStrategyTradingMap[strategyKey] { return mr }
        let accounts = ax.strategyVariableAccountsMap[strategyKey] ?? []
        let set = Set(accounts.map(\.primaryKey))
        let nuMR = generate(accountKeyFilter: { set.contains($0) })
        mrStrategyTradingMap[strategyKey] = nuMR
        return nuMR
    }
    
    public func getStrategyNonTradingMR(_ strategyKey: StrategyKey) -> MatrixResult {
        if let mr = mrStrategyNonTradingMap[strategyKey] { return mr }
        let accounts = ax.strategyFixedAccountsMap[strategyKey] ?? []
        let set = Set(accounts.map(\.primaryKey))
        let nuMR = generate(accountKeyFilter: { set.contains($0) })
        mrStrategyNonTradingMap[strategyKey] = nuMR
        return nuMR
    }
}
