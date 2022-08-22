//
//  Snapshot+GetContiguous.swift
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

extension MValuationSnapshot {
    
    static func getSnapshotDateIntervals(orderedSnapshots snapshots: ArraySlice<MValuationSnapshot>) -> [SnapshotKeyDateIntervalTuple] {
        var lastCapturedAt = Date.init(timeIntervalSinceReferenceDate: 0)
        return snapshots.reduce(into: []) { array, snapshot in
            let capturedAt = snapshot.capturedAt
            let tuple = (snapshot.primaryKey, DateInterval(start: lastCapturedAt, end: capturedAt))
            array.append(tuple)
            lastCapturedAt = capturedAt
        }
    }
    
    /// NOTE the first snapshot will have a map entry of (Date.init(timeIntervalSinceReferenceDate: 0)...capturedAt)
    /// The keyed snapshot interval will start with the capturedAt of previous snapshot and end with its own.
    static func getSnapshotDateIntervalMap(orderedSnapshots snapshots: ArraySlice<MValuationSnapshot>) -> SnapshotDateIntervalMap {
        let intervals = MValuationSnapshot.getSnapshotDateIntervals(orderedSnapshots: snapshots)
        return intervals.reduce(into: [:]) { map, tuple in
            map[tuple.snapshotKey] = tuple.dateInterval
        }
    }
}
