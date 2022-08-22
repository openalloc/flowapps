//
//  CashflowConsolidate.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

import ModifiedDietz
import AllocData

import FlowBase

public typealias SnapshotAccountAssetBaselineMap = [SnapshotKey: AccountAssetBaselineMap]


public extension MValuationCashflow {
    
    static func getSnapshotBaselineMap(snapshotKeys: [SnapshotKey],
                                       snapshotDateIntervalMap: SnapshotDateIntervalMap,
                                       snapshotPositionsMap: SnapshotPositionsMap,
                                       snapshotCashflowsMap: SnapshotCashflowsMap) -> SnapshotAccountAssetBaselineMap {
        
        let previousKeyMap = MValuationSnapshot.getPreviousSnapshotKeyMap(snapshotDateIntervalMap: snapshotDateIntervalMap)
        
        return snapshotKeys.reduce(into: [:]) { map, snapshotKey in
            
            guard let previousSnapshotKey = previousKeyMap[snapshotKey],   // first snapshot will have an 'empty' value
                  previousSnapshotKey != SnapshotKey.empty,                 // ...which we'll skip
                  let positionsBeg = snapshotPositionsMap[previousSnapshotKey],
                  let positionsEnd = snapshotPositionsMap[snapshotKey],
                  let snapshotCashflows = snapshotCashflowsMap[snapshotKey],
                  let period = snapshotDateIntervalMap[snapshotKey]
            else { return }
            
            // at start (or end) of snapshot, there should only be one position for a given account/asset, but we'll allow for more
            let accountAssetPositionsBeg = Dictionary(grouping: positionsBeg, by: { $0.accountAssetKey })
            let accountAssetPositionsEnd = Dictionary(grouping: positionsEnd, by: { $0.accountAssetKey })
            let accountAssetCashflows = Dictionary(grouping: snapshotCashflows, by: { $0.accountAssetKey })
            
            let baselineMap: AccountAssetBaselineMap = getBaselineMap(period: period,
                                                                      accountAssetPositionsBeg: accountAssetPositionsBeg,
                                                                      accountAssetPositionsEnd: accountAssetPositionsEnd,
                                                                      accountAssetCashflows: accountAssetCashflows)
            guard baselineMap.count > 0 else { return }
            map[snapshotKey] = baselineMap
        }
    }
    
    // get the baseline map for a snapshot, determining a new date for a single consolidated cashflow
    internal static func getBaselineMap(period: DateInterval,
                                        accountAssetPositionsBeg: AccountAssetPositionsMap,
                                        accountAssetPositionsEnd: AccountAssetPositionsMap,
                                        accountAssetCashflows: AccountAssetCashflowsMap) -> AccountAssetBaselineMap {
        
        typealias MD = ModifiedDietz<Double>
        
        let accountAssetKeys = Set(accountAssetPositionsBeg.keys).intersection(accountAssetPositionsEnd.keys)
        
        return accountAssetKeys.reduce(into: [:]) { amap, accountAssetKey in
            
            guard let positionsBeg = accountAssetPositionsBeg[accountAssetKey]
            else {
                print("no beg positions")
                return
            }

            guard let positionsEnd = accountAssetPositionsEnd[accountAssetKey]
            else {
                print("no end positions")
                return
            }

            guard let cashflows = accountAssetCashflows[accountAssetKey]
            else {
                print("no cashflows")
                return
            }

            // at start (or end) of snapshot, there should only be one position for a given account/asset, but we'll sum them if more
            let startValue = MValuationPosition.getTotalMarketValue(positionsBeg)
            let endValue = MValuationPosition.getTotalMarketValue(positionsEnd)
            
            let cashflowMap = getCashflowMap(cashflows)
            
            // ignore if cashflows sum to 0, or if performance is nonsensical
            guard let md = MD.init(period: period,
                                   startValue: startValue,
                                   endValue: endValue,
                                   cashflowMap: cashflowMap),
                  md.netCashflowTotal.isNotEqualToZero(accuracy: 0.001),
                  md.performance.isFinite
            else {
                print("failure to determine target performance")
                return
            }
            
            amap[accountAssetKey] = MyBaseline(period: period,
                                               performance: md.performance,
                                               startValue: startValue,
                                               endValue: endValue,
                                               netCashflow: md.netCashflowTotal)
        }
    }
}

public extension BaseModel {
    
    // Replace ALL existing cash flow records in model.
    // NOTE if user function changes model, you should rebuild context upon return so that snapshotCashflowsMap will be rebuilt
    mutating func consolidateCashflow(snapshotBaselineMap: SnapshotAccountAssetBaselineMap,
                                      accountMap: AccountMap,
                                      assetMap: AssetMap) {
        
        self.valuationCashflows = snapshotBaselineMap.values.reduce(into: []) { array, baselineMap in
            
            baselineMap.forEach { accountAssetKey, myBaseline in
                
                let accountKey = accountAssetKey.accountKey
                let assetKey = accountAssetKey.assetKey
                let accountID = accountMap[accountKey]?.accountID ?? accountKey.accountNormID
                let assetID = assetMap[assetKey]?.assetID ?? assetKey.assetNormID
                
                let nuCashflow = MValuationCashflow(transactedAt: myBaseline.netDate,
                                                    accountID: accountID,
                                                    assetID: assetID,
                                                    amount: myBaseline.netCashflow)
                
                array.append(nuCashflow)
            }
        }
    }
}
