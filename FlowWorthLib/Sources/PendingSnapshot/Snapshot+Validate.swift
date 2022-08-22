//
//  Snapshot+Validate.swift
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
    
    /// check whether a new snapshot can be created; returns previous snapshot, if any
    static func validateSnapshot(previousSnapshotCapturedAt: Date?,
                                 timestamp: Date = Date()) throws {
        
        guard let _previousSnapshotCapturedAt = previousSnapshotCapturedAt else { return }
        
        // there's at least one other snapshot
        
        if timestamp <= _previousSnapshotCapturedAt {
            throw WorthError.cannotCreateSnapshot("Must be newer than existing snapshots.")
        }
        
        let interval = _previousSnapshotCapturedAt.distance(to: timestamp)
        if interval < 86400 {
            throw WorthError.cannotCreateSnapshot("Only one snapshot per 24 hour period.")
        }
    }
}

extension BaseModel {
    func validateSnapshot(snapshot: MValuationSnapshot) throws {
        let snapshotKey = snapshot.primaryKey
        if self.valuationSnapshots.first(where: { $0.primaryKey == snapshotKey }) != nil {
            throw WorthError.cannotCreateSnapshot("A snapshot already exists with that ID.")
        }
    }
}
