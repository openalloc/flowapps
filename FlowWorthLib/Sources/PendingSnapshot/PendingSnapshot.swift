//
//  PendingSnapshot.swift
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

// NOTE needs to be rebuilt whenever context is rebuilt
public final class PendingSnapshot {
    internal let snapshotID: SnapshotID
    internal let timestamp: Date
    internal let holdings: [MHolding]
    internal let transactions: [MTransaction]
    internal let previousSnapshot: MValuationSnapshot?
    public var previousPositions: [MValuationPosition] // var to support sorting
    public var previousCashflows: [MValuationCashflow] // var to support sorting
    internal let userExcludedTxnKeys: [TransactionKey]
    internal let accountMap: AccountMap
    internal let assetMap: AssetMap
    internal let securityMap: SecurityMap
    internal let timeZone: TimeZone
    
    public init(snapshotID: SnapshotID = UUID().uuidString,
                timestamp: Date = Date(),
                holdings: [MHolding] = [],
                transactions: [MTransaction] = [],
                previousSnapshot: MValuationSnapshot? = nil,
                previousPositions: [MValuationPosition] = [],
                previousCashflows: [MValuationCashflow] = [],
                userExcludedTxnKeys: [TransactionKey] = [],
                accountMap: AccountMap = [:],
                assetMap: AssetMap = [:],
                securityMap: SecurityMap = [:],
                timeZone: TimeZone = TimeZone.current) {
        self.snapshotID = snapshotID
        self.timestamp = timestamp
        self.holdings = holdings
        self.transactions = transactions
        self.previousSnapshot = previousSnapshot
        self.previousPositions = previousPositions
        self.previousCashflows = previousCashflows
        self.userExcludedTxnKeys = userExcludedTxnKeys
        self.accountMap = accountMap
        self.assetMap = assetMap
        self.securityMap = securityMap
        self.timeZone = timeZone
    }
    
    // MARK: - The snapshot that is not yet in the model
    
    public lazy var snapshot: MValuationSnapshot = {
        MValuationSnapshot(snapshotID: snapshotID, capturedAt: timestamp)
    }()
    
    // MARK: - Accounts
    
    internal lazy var accountKeys: [AccountKey] = {
        nuPositions.map(\.accountKey)
    }()
    
    // MARK: - Holdings
    
    internal lazy var netHoldings: [MHolding] = {
        let sortFn: (MHolding, MHolding) -> Bool = {
            $0.accountKey < $1.accountKey ||
            ($0.accountKey == $1.accountKey && $0.securityKey < $1.securityKey) ||
            ($0.accountKey == $1.accountKey && $0.securityKey == $1.securityKey && $0.lotID < $1.lotID)
        }
        return holdings
            .sorted(by: sortFn)
    }()
    
    
    // MARK: - Positions
    
    /// ORDERED using default position sort
    public lazy var nuPositions: [MValuationPosition] = {
        MValuationPosition.createPositions(holdings: netHoldings,
                                           snapshotID: snapshotID,
                                           securityMap: securityMap,
                                           assetMap: assetMap)
            .sorted()
    }()
    
    public lazy var nuMarketValue: Double = {
        nuPositions.reduce(0) { $0 + $1.marketValue }
    }()

    // MARK: - Transactions
    
    /// unfiltered array of transaction keys
    public lazy var transactionKeys: [TransactionKey] = {
        transactions.map(\.primaryKey)
    }()
    
    /// NOTE this is filtered exclusively through userExcluded map from all available transactions; previous snapshot is not considered
    public lazy var netTransactions: [MTransaction] = {
        MTransaction.cashflowFilter(transactions: transactions,
                                    userExcludedTxnKeys: userExcludedTxnKeys)
    }()
    
    // MARK: - Cashflow
    
    /// The cashflow period starts one second after the start of the snapshot period, if there's any previous snapshot. It ends at the same time as the snapshot period.
    public lazy var cashflowPeriod: DateInterval? = {
        MValuationCashflow.getCashflowPeriod(begCapturedAt: previousSnapshot?.capturedAt,
                                             endCapturedAt: timestamp)
    }()
    
    /// Translate qualifying MTransactions to cashflow.
    /// NOTE that the (approximate) transaction dates are clamped to cashflowPeriod.
    public lazy var nuCashflows: [MValuationCashflow] = {
        guard let _period = cashflowPeriod else { return [] }
        let rawCashflows = MValuationCashflow.generateCashflow(from: netTransactions,
                                                               period: _period,
                                                               securityMap: securityMap)
        let epsilon = 0.0001 // used to filter zero net cashflows
        let cashflowMap = MValuationCashflow.consolidateCashflows(rawCashflows, epsilon: epsilon)
        return cashflowMap.values.sorted()
    }()
    
    public lazy var netCashflowTotal: Double = {
        nuCashflows.reduce(0) { $0 + $1.amount }
    }()
    
    internal lazy var netCashflowMap: AccountAssetValueMap = {
        MValuationCashflow.getAccountAssetValueMap(nuCashflows)
    }()
    
    // MARK: - Period
    
    public lazy var period: DateInterval? = {
        guard let prev = previousSnapshot,
              prev.capturedAt < timestamp
        else { return nil }
        return DateInterval(start: prev.capturedAt, end: timestamp)
    }()
    
    public lazy var periodSummary: PeriodSummary? = {
        guard let _period = period else { return nil }
        return PeriodSummary(period: _period,
                             begPositions: previousPositions,
                             endPositions: nuPositions,
                             cashflows: nuCashflows,
                             accountMap: accountMap)
    }()
}
