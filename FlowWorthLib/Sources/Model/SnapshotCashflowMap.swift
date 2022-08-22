//
//  SnapshotCashflowMap.swift
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

extension MValuationCashflow {
    
   
    public static func getSnapshotCashflowsMap(orderedSnapshots: ArraySlice<MValuationSnapshot>,
                                               orderedCashflows: ArraySlice<MValuationCashflow>,
                                               snapshotDateIntervalMap: SnapshotDateIntervalMap) -> SnapshotCashflowsMap {
        // NOTE there could be literally thousands of cashflow items, so scan through those only once (using iterator)
        
        var cashflowIterator = orderedCashflows.makeIterator()
        
        var nextCashflow: MValuationCashflow? = nil
        let epoch = Date.init(timeIntervalSinceReferenceDate: 0)
        
        return orderedSnapshots.reduce(into: [:]) { map, snapshot in

            let snapshotKey = snapshot.primaryKey

            // NOTE first snapshot
            // ... will have a date interval of (epoch...capturedAt)
            // ... but will NOT be allowed any cash flows
            guard let dateInterval = snapshotDateIntervalMap[snapshotKey],
                  epoch < dateInterval.start else {
                map[snapshotKey] = []
                return
            }
            
            while true {
                // If unused cashflow (from previous snapshot), then we'll try to use it.
                // Otherwise get next available cashflow from iterator, if any.
                // If iterator is exhausted, then bail.
                if nextCashflow == nil {
                    nextCashflow = cashflowIterator.next()
                }
                
                guard let transactedAt = nextCashflow?.transactedAt else {
                    break
                }
                
                // if cashflow is prior to date range, skip
                // Note that comparison is exclusive of start, which belongs to previous snapshot.
                if transactedAt <= dateInterval.start {
                    nextCashflow = cashflowIterator.next()
                    if nextCashflow == nil { break }
                    continue
                }
                
                // If cashflow not in snapshot date range, then advance to next snapshot, if any.
                guard transactedAt <= dateInterval.end else {
                    break
                }
                
                map[snapshotKey, default: []].append(nextCashflow!)
                nextCashflow = nil
            }
        }
    }
}
