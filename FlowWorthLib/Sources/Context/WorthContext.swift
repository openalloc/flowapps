//
//  WorthContext.swift
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
import SimpleTree

public class WorthContext: BaseContext {
    public private(set) var settings: ModelSettings

    public init(_ model: BaseModel,
                _ settings: ModelSettings = ModelSettings(),
                strategyKey: StrategyKey = MStrategy.emptyKey,
                timestamp: Date = Date(),
                timeZone: TimeZone = TimeZone.current)
    {
        self.settings = settings

        super.init(model, strategyKey: strategyKey, timestamp: timestamp, timeZone: timeZone)
    }
    
    public lazy var orderedSnapshots: [MValuationSnapshot] = {
        model.orderedSnapshots
    }()
    
    public lazy var orderedSnapshotKeys: [SnapshotKey] = {
        orderedSnapshots.map(\.primaryKey)
    }()
    
    public lazy var snapshotIndexes: [SnapshotKey: Int] = {
        orderedSnapshots.map(\.primaryKey).enumerated().reduce(into: [:]) { map, entry in
            let (n, snapshotKey) = entry
            map[snapshotKey] = n
        }
    }()
    
    /// earliest transaction date, if any
    public lazy var firstTransactedAt: Date? = {
        orderedTxns.first?.transactedAt
    }()
    
    public lazy var firstSnapshot: MValuationSnapshot? = {
        orderedSnapshots.first
    }()

    public lazy var lastSnapshot: MValuationSnapshot? = {
        orderedSnapshots.last
    }()

    /// most ancient snapshot capturedAt
    public lazy var firstSnapshotCapturedAt: Date? = {
        firstSnapshot?.capturedAt
    }()
    
    /// most recent snapshot capturedAt
    public lazy var lastSnapshotCapturedAt: Date? = {
        lastSnapshot?.capturedAt
    }()

    public lazy var firstSnapshotKey: SnapshotKey? = {
        firstSnapshot?.primaryKey
    }()

    public lazy var lastSnapshotKey: SnapshotKey? = {
        lastSnapshot?.primaryKey
    }()
    
    /// all but the first snapshot will have an entry
    public lazy var prevSnapshotKeyMap: [SnapshotKey: SnapshotKey] = {
        var prev: SnapshotKey? = nil
        return orderedSnapshotKeys.reduce(into: [:]) { map, snapshotKey in
            if let _prev = prev { map[snapshotKey] = _prev }
            prev = snapshotKey
        }
    }()
    
    /// ORDERED using default position sort
    public lazy var lastSnapshotPositions: [MValuationPosition] = {
        guard let snapshotKey = lastSnapshotKey else { return [] }
        let positions = snapshotPositionsMap[snapshotKey] ?? []
        return positions.sorted()
    }()
    
    /// obtain the starting point for a new snapshot
    public lazy var begCapturedAt: Date? = {
        if let lsca = lastSnapshotCapturedAt {
            return lsca + 1         // one second beyond it
        }
        // if no snapshots, try to get an early date from history
        return firstTransactedAt
    }()
    
    // MARK: - Transactions
    
    /// NOTE: excludes undated history items (transactedAt == nil)
    public lazy var orderedTxns: [MTransaction] = {
        model.orderedTxns
    }()
    
    // MARK: - Valuation Cashflow
    
    public lazy var orderedCashflow: [MValuationCashflow] = {
        model.orderedCashflowItems
    }()
    
    public lazy var snapshotCashflowsMap: SnapshotCashflowsMap = {
        MValuationCashflow.getSnapshotCashflowsMap(orderedSnapshots: orderedSnapshots[...],
                                                   orderedCashflows: orderedCashflow[...],
                                                   snapshotDateIntervalMap: snapshotDateIntervalMap)
    }()
    
    public lazy var lastSnapshotCashflows: [MValuationCashflow] = {
        guard let key = lastSnapshotKey else { return [] }
        return snapshotCashflowsMap[key] ?? []
    }()
    
    // MARK: - Valuation Positions

    public lazy var snapshotPositionsMap: SnapshotPositionsMap = {
        Dictionary(grouping: model.valuationPositions, by: { $0.snapshotKey })
    }()
    
    // MARK: - Snapshot intervals
    
    public lazy var snapshotDateIntervals: [SnapshotKeyDateIntervalTuple] = {
        MValuationSnapshot.getSnapshotDateIntervals(orderedSnapshots: orderedSnapshots[...])
    }()
    
    /// look up dateInterval given a snapshotKey
    public lazy var snapshotDateIntervalMap: SnapshotDateIntervalMap = {
        snapshotDateIntervals.reduce(into: [:]) { map, tuple in
            map[tuple.snapshotKey] = tuple.dateInterval
        }
    }()
    
    // NOTE: will return nil if only one snapshot (where there is no interval yet)
    public lazy var lastSnapshotInterval: DateInterval? = {
        guard let key = lastSnapshotKey else { return nil }
        return snapshotDateIntervalMap[key]
    }()
    
    // MARK: - Warning for missing data support
    
    // NOTE not using recent transactions here, because updatedAt is today
    public lazy var missingSharePriceTxns: [MTransaction] = {
        orderedTxns.filter { $0.sharePrice == nil }
    }()
}
