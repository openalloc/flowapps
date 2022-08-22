//
//  DietzSnapshotInfo.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

import AllocData
import ModifiedDietz

// simple struct needed with ForEach
public struct DietzSnapshotInfo: Hashable, Identifiable {

    public typealias MDietz = ModifiedDietz<Double>

    public var id: Double
    public var capturedAt: Date
    public var netCashflow: Double
    public var r: Double
    public var rToDate: Double
    public var marketValue: Double

    internal init(capturedAt: Date, netCashflow: Double, r: Double, rToDate: Double, marketValue: Double) {
        self.id = capturedAt.timeIntervalSinceReferenceDate
        self.capturedAt = capturedAt
        self.netCashflow = netCashflow
        self.r = r
        self.rToDate = rToDate
        self.marketValue = marketValue
    }
    
    public static func getDietzSnapshots(_ mr: MatrixResult) -> [DietzSnapshotInfo] {
        var lastMarketValue: Double = mr.periodSummary?.begMarketValue ?? 0
        var cumulTxns: MDietz.CashflowMap = [:]
        let array: [DietzSnapshotInfo] = mr.orderedSnapshots.reduce(into: []) { array, snapshot in
            let snapshotKey = snapshot.primaryKey
            guard let snapshotPeriod = mr.snapshotDateIntervalMap[snapshotKey],
                  let endMarketValue = mr.snapshotMarketValueMap[snapshotKey]
            else { return }

            // snapshot performance
            let cashflowItems = mr.snapshotCashflowsMap[snapshotKey] ?? []
            let cashflowMap = MValuationCashflow.getCashflowMap(cashflowItems)
            guard let snapshotMD = MDietz.init(period: snapshotPeriod, startValue: lastMarketValue, endValue: endMarketValue, cashflowMap: cashflowMap)
            else { return }
            
            // cumulative (period-to-date) performance
            cashflowItems.forEach {
                cumulTxns[$0.transactedAt, default: 0] += $0.amount
            }            
            let cumulPeriod = DateInterval(start: mr.begCapturedAt, end: snapshotPeriod.end)
            let begMarketValue = mr.periodSummary?.begMarketValue ?? 0
            let cumulMV = MDietz.MarketValueDelta(start: begMarketValue, end: endMarketValue)
            guard let cumulMD = MDietz(cumulPeriod, cumulMV, cumulTxns) else { return }

            let netCashflow = MValuationCashflow.getNetCashflow(cashflowItems)

            array.append(DietzSnapshotInfo(capturedAt: snapshot.capturedAt,
                                           netCashflow: netCashflow,
                                           r: snapshotMD.performance,
                                           rToDate: cumulMD.performance,
                                           marketValue: endMarketValue))
            
            lastMarketValue = endMarketValue
        }
        
        return array
    }
}
