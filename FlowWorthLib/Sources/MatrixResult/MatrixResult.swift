//
//  MatrixResult.swift
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
import ModifiedDietz
import FlowStats

/// return matrix of market values of asset market values
///
/// For example, with 4 snapshots and 3 assets, where a is beginning snapshot and d is ending snapshot
///
/// [ MAsset.Key(assetID: "Bond"): [a, b, c, d], MAsset.Key(assetID: "Gold"): [a, b, c, d], MAsset.Key(assetID: "LC"): [a, b, c, d] ]
///
/// NOTE none of the members here could go into WorthContext, because they're all
/// dependent on the input parameters.
public final class MatrixResult {
    
    public typealias AllocKeyStatsMap<M: AllocKeyed> = [M.Key: Stats<Double>]
    public typealias AssetMarketValueStatsMap = AllocKeyStatsMap<MAsset>
    public typealias AccountMarketValueStatsMap = AllocKeyStatsMap<MAccount>
    public typealias StrategyMarketValueStatsMap = AllocKeyStatsMap<MStrategy>
    
    public let orderedSnapshots: ArraySlice<MValuationSnapshot>
    public let rawOrderedCashflow: [MValuationCashflow]
    public let valuationPositions: [MValuationPosition]
    public let accountKeyFilter: AccountKeyFilter // used to filter positions by account
    public let preferredAssetOrder: [AssetKey]
    public let timeZone: TimeZone
    public let accountMap: AccountMap
    
    public init(orderedSnapshots: ArraySlice<MValuationSnapshot> = [],
                rawOrderedCashflow: [MValuationCashflow] = [],
                valuationPositions: [MValuationPosition] = [],
                accountKeyFilter: @escaping AccountKeyFilter = { _ in true },
                preferredAssetOrder: [AssetKey] = [],
                timeZone: TimeZone = TimeZone.current,
                accountMap: AccountMap = [:]) {
        
        self.orderedSnapshots = orderedSnapshots
        self.rawOrderedCashflow = rawOrderedCashflow
        self.valuationPositions = valuationPositions
        self.accountKeyFilter = accountKeyFilter
        self.preferredAssetOrder = preferredAssetOrder
        self.timeZone = timeZone
        self.accountMap = accountMap
    }
    
    // MARK: - Snapshots
    
    public lazy var snapshotDateIntervals: [SnapshotKeyDateIntervalTuple] = {
        MValuationSnapshot.getSnapshotDateIntervals(orderedSnapshots: orderedSnapshots)
    }()
    
    public lazy var snapshotDateIntervalMap: SnapshotDateIntervalMap = {
        snapshotDateIntervals.reduce(into: [:]) { map, tuple in
            map[tuple.snapshotKey] = tuple.dateInterval
        }
    }()
    
    public lazy var orderedSnapshotKeys: [SnapshotKey] = {
        orderedSnapshots.map(\.primaryKey)
    }()
    
    public lazy var snapshotKeySet: Set<SnapshotKey> = {
        Set(orderedSnapshotKeys)
    }()
    
    public lazy var begSnapshot: MValuationSnapshot? = {
        orderedSnapshots.first
    }()
    
    public lazy var endSnapshot: MValuationSnapshot? = {
        orderedSnapshots.last
    }()
    
    public lazy var begSnapshotKey: SnapshotKey = {
        begSnapshot?.primaryKey ?? MValuationSnapshot.Key.empty
    }()
    
    public lazy var endSnapshotKey: SnapshotKey = {
        endSnapshot?.primaryKey ?? MValuationSnapshot.Key.empty
    }()
    
    public lazy var begCapturedAt: Date = {
        begSnapshot?.capturedAt ?? Date.init(timeIntervalSinceReferenceDate: 0)
    }()
    
    public lazy var endCapturedAt: Date = {
        endSnapshot?.capturedAt ?? Date.init(timeIntervalSinceReferenceDate: 0)
    }()
    
    public lazy var capturedAts: [Date] = {
        orderedSnapshots.map(\.capturedAt)
    }()
    
    public lazy var distances: [TimeInterval] = {
        guard let originalStart = capturedAts.first
        else { return [] }
        return originalStart.distances(to: capturedAts)
    }()
    
    // MARK: - Period Summary (just beg and end positions, and cashflow)
    
    public lazy var period: DateInterval? = {
        guard let start = begSnapshot?.capturedAt,
              let end = endSnapshot?.capturedAt,
              start < end
        else { return nil }
        return DateInterval(start: start, end: end)
    }()
    
    public lazy var periodDuration: TimeInterval = {
        period?.duration ?? 0
        //distances.last ?? 0
    }()
    
    public lazy var periodSummary: PeriodSummary? = {
        guard let _period = period else { return nil }
        return PeriodSummary(period: _period,
                             begPositions: begPositions,
                             endPositions: endPositions,
                             cashflows: orderedCashflow,
                             accountMap: accountMap)
    }()
    
    // MARK: - Matrix (may be more than two valuations!)
    
    /// snapshot NET market values, grouped by asset class [MAsset.Key: [Double]]
    public lazy var matrixValuesByAsset: AssetValuesMap = {
        let filter: PositionKeyFilter<MAsset> = { $0.assetKey }
        return MatrixResult.getMatrixData(MAsset.self,
                                          snapshotKeys: orderedSnapshotKeys,
                                          snapshotPositionsMap: positionsMap,
                                          allocKeys: orderedAssetKeys,
                                          positionKeyFilter: filter)
    }()
    
    /// snapshot NET market values, grouped by account [MAccount.Key: [Double]]
    public lazy var matrixValuesByAccount: AccountValuesMap = {
        let filter: PositionKeyFilter<MAccount> = { $0.accountKey }
        return MatrixResult.getMatrixData(MAccount.self,
                                          snapshotKeys: orderedSnapshotKeys,
                                          snapshotPositionsMap: positionsMap,
                                          allocKeys: orderedAccountKeys,
                                          positionKeyFilter: filter)
    }()
    
    /// snapshot NET market values, grouped by strategy [MStrategy.Key: [Double]]
    public lazy var matrixValuesByStrategy: StrategyValuesMap = {
        let filter: PositionKeyFilter<MStrategy> = { self.accountMap[$0.accountKey]?.strategyKey ?? MStrategy.emptyKey }
        return MatrixResult.getMatrixData(MStrategy.self,
                                          snapshotKeys: orderedSnapshotKeys,
                                          snapshotPositionsMap: positionsMap,
                                          allocKeys: orderedStrategyKeys,
                                          positionKeyFilter: filter)
    }()
    
    // MARK: - Cashflow
    
    // scan through cashflow just ONCE
    public lazy var orderedCashflow: [MValuationCashflow] = {
        guard let sdi = period else { return [] }
        return rawOrderedCashflow.filter {
            accountKeySet.contains($0.accountKey) &&
            sdi.start < $0.transactedAt &&
            $0.transactedAt <= sdi.end
        }
        .sorted()
    }()
    
    public lazy var cashflowItemCount: Int = {
        orderedCashflow.count
    }()
    
    public lazy var hasCashflow: Bool = {
        orderedCashflow.first != nil
    }()
    
    public lazy var snapshotCashflowsMap: SnapshotCashflowsMap = {
        MValuationCashflow.getSnapshotCashflowsMap(orderedSnapshots: orderedSnapshots,
                                                   orderedCashflows: orderedCashflow[...],
                                                   snapshotDateIntervalMap: snapshotDateIntervalMap)
    }()
    
    // MARK: - Assets
    
    public lazy var assetKeySet: Set<AssetKey> = {
        Set(positions.map(\.assetKey))
    }()
    
    public lazy var orderedAssetKeys: [AssetKey] = {
        let defSort = assetKeySet.sorted()
        if preferredAssetOrder.count == 0 { return defSort }
        return defSort.reorder(by: preferredAssetOrder)
    }()
    
    private lazy var assetBegPositionsMap: AssetPositionsMap = {
        Dictionary(grouping: begPositions, by: { $0.assetKey })
    }()
    
    private lazy var assetEndPositionsMap: AssetPositionsMap = {
        Dictionary(grouping: endPositions, by: { $0.assetKey })
    }()
    
    private lazy var assetPositionsMap: AssetPositionsMap = {
        Dictionary(grouping: positions, by: { $0.assetKey })
    }()
    
    private lazy var assetCashflowsMap: AssetCashflowsMap = {
        Dictionary(grouping: orderedCashflow, by: { $0.assetKey })
    }()
    
    // MARK: - Accounts
    
    /// the results of applying the account filter to the available positions for the snapshot
    /// true=retained, false=discarded
    public lazy var accountFilteredMap: AccountFilteredMap = {
        positionsPair.1
    }()
    
    /// participating accounts in the results
    public lazy var orderedAccountKeys: [AccountKey] = {
        accountFilteredMap.filter({ $0.value }).map(\.key).sorted()
    }()
    public lazy var accountKeySet: Set<AccountKey> = {
        Set(orderedAccountKeys)
    }()
    
    private lazy var accountBegPositionsMap: AccountPositionsMap = {
        Dictionary(grouping: begPositions, by: { $0.accountKey })
    }()
    
    private lazy var accountEndPositionsMap: AccountPositionsMap = {
        Dictionary(grouping: endPositions, by: { $0.accountKey })
    }()
    
    private lazy var accountPositionsMap: AccountPositionsMap = {
        Dictionary(grouping: positions, by: { $0.accountKey })
    }()
    
    private lazy var accountCashflowsMap: AccountCashflowsMap = {
        Dictionary(grouping: orderedCashflow, by: { $0.accountKey })
    }()
    
    // MARK: - Strategies
    
    /// participating strategies in the results
    public lazy var orderedStrategyKeys: [StrategyKey] = {
        strategyKeySet.sorted()
    }()
    public lazy var strategyKeySet: Set<StrategyKey> = {
        orderedAccountKeys.reduce(into: Set()) { keySet, accountKey in
            let strategyKey = getStrategyKey(accountKey)
            guard strategyKey.isValid else { return }
            keySet.insert(strategyKey)
        }
    }()
    
    private lazy var strategyPositionsMap: StrategyPositionsMap = {
        Dictionary(grouping: positions, by: { getStrategyKey($0.accountKey) })
    }()
    
    private lazy var strategyCashflowsMap: StrategyCashflowsMap = {
        Dictionary(grouping: orderedCashflow, by: { getStrategyKey($0.accountKey) })
    }()
    
    internal func getStrategyKey(_ accountKey: AccountKey) -> StrategyKey {
        self.accountMap[accountKey]?.strategyKey ?? MStrategy.emptyKey
    }
    
    // MARK: - Positions
    
    // positions used to build the matrix values, and the modified dietz
    public lazy var positions: [MValuationPosition] = {
        positionsPair.0
    }()
    
    public lazy var positionsCount: Int = {
        positions.count
    }()
    
    public lazy var positionsMap: SnapshotPositionsMap = {
        Dictionary(grouping: positions, by: { $0.snapshotKey })
    }()
    
    public lazy var begPositions: [MValuationPosition] = {
        positionsMap[begSnapshotKey] ?? []
    }()
    
    public lazy var endPositions: [MValuationPosition] = {
        positionsMap[endSnapshotKey] ?? []
    }()
    
    // scan through positions just ONCE
    private lazy var positionsPair: ([MValuationPosition], AccountFilteredMap) = {
        var accountFilteredMap = AccountFilteredMap()
        let positions = MValuationPosition.getPositions(rawPositions: valuationPositions,
                                                        snapshotKeySet: snapshotKeySet,
                                                        accountKeyFilter: accountKeyFilter,
                                                        accountFilteredMap: &accountFilteredMap)
        return (positions, accountFilteredMap)
    }()
    
    // MARK: - Asset Values (for viz)
    
    // full market values
    // NOTE: unordered
    public lazy var endAssetValues: [AssetValue] = {
        guard let psum = periodSummary else { return [] }
        return psum.endAssetMV.reduce(into: []) { array, entry in
            let (assetKey, mv) = entry
            array.append(AssetValue(assetKey, mv))
        }
    }()
    
    // market values normalized to 0...1
    // NOTE: unordered
    public lazy var endAssetValuesUnit: [AssetValue] = {
        (try? AssetValue.normalize(endAssetValues)) ?? []
    }()
    
    // MARK: - Market Values (may be more than two valuations!)
    
    // net market value for each snapshot
    public lazy var snapshotMarketValueMap: SnapshotValueMap = {
        MatrixResult.getSnapshotMarketValueMap(snapshotKeys: orderedSnapshotKeys,
                                               snapshotPositionsMap: positionsMap)
    }()
    
    // (negative market value sum ... positive market value sum), by asset and account
    public lazy var assetMarketValueExtentRange: ClosedRange<Double>? = {
        MatrixResult.getAssetMarketValueExtentRange(snapshotKeys: orderedSnapshotKeys,
                                                    snapshotPositionsMap: positionsMap)
        
    }()
    public lazy var accountMarketValueExtentRange: ClosedRange<Double>? = {
        MatrixResult.getAccountMarketValueExtentRange(snapshotKeys: orderedSnapshotKeys,
                                                      snapshotPositionsMap: positionsMap)
    }()
    public lazy var strategyMarketValueExtentRange: ClosedRange<Double>? = {
        getStrategyMarketValueExtentRange(snapshotKeys: orderedSnapshotKeys,
                                                      snapshotPositionsMap: positionsMap)
    }()
    
    public lazy var snapshotMarketValueStats: Stats<Double> = {
        let marketValues = snapshotMarketValueMap.map(\.value)
        return Stats<Double>(values: marketValues)
    }()
    
    /// the market values of all snapshots will fall within this range, inclusive (on y-axis)
    public lazy var marketValueRange: ClosedRange<Double>? = {
        snapshotMarketValueStats.range
    }()
    
    public lazy var assetMarketValueStatsMap: AssetMarketValueStatsMap = {
        guard let _begSnapshot = begSnapshot,
              let _endSnapshot = endSnapshot
        else { return [:] }
        return orderedAssetKeys.reduce(into: [:]) { map, assetKey in
            let assetPositions = assetPositionsMap[assetKey] ?? []
            let positionsMap = Dictionary(grouping: assetPositions, by: { $0.snapshotKey })
            let marketValueMap = MValuationSnapshot.getSnapshotMarketValueMap(positionsMap: positionsMap)
            let marketValues = marketValueMap.map(\.value)
            let stats = Stats<Double>(values: marketValues)
            map[assetKey] = stats
        }
    }()
    
    public lazy var accountMarketValueStatsMap: AccountMarketValueStatsMap = {
        guard let _begSnapshot = begSnapshot,
              let _endSnapshot = endSnapshot
        else { return [:] }
        return orderedAccountKeys.reduce(into: [:]) { map, accountKey in
            let accountPositions = accountPositionsMap[accountKey] ?? []
            let positionsMap = Dictionary(grouping: accountPositions, by: { $0.snapshotKey })
            let marketValueMap = MValuationSnapshot.getSnapshotMarketValueMap(positionsMap: positionsMap)
            let marketValues = marketValueMap.map(\.value)
            let stats = Stats<Double>(values: marketValues)
            map[accountKey] = stats
        }
    }()
    
    public lazy var strategyMarketValueStatsMap: StrategyMarketValueStatsMap = {
        guard let _begSnapshot = begSnapshot,
              let _endSnapshot = endSnapshot
        else { return [:] }
        return orderedStrategyKeys.reduce(into: [:]) { map, strategyKey in
            let strategyPositions = strategyPositionsMap[strategyKey] ?? []
            let positionsMap = Dictionary(grouping: strategyPositions, by: { $0.snapshotKey })
            let marketValueMap = MValuationSnapshot.getSnapshotMarketValueMap(positionsMap: positionsMap)
            let marketValues = marketValueMap.map(\.value)
            let stats = Stats<Double>(values: marketValues)
            map[strategyKey] = stats
        }
    }()
}

extension MatrixResult: CustomStringConvertible {
    public var description: String {
        "snapshots=\(orderedSnapshots.count) positions=\(positions.count) cashflows=\(orderedCashflow.count) accounts=\(orderedAccountKeys.count) assets=\(orderedAssetKeys.count) dietz=\(periodSummary?.dietz?.performance ?? -1.0)"
    }
}
