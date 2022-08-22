//
//  MValuationSnapshot+Comparable.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

import AllocData

extension MValuationSnapshot: Comparable {
    public static func < (lhs: MValuationSnapshot, rhs: MValuationSnapshot) -> Bool {
        lhs.capturedAt < rhs.capturedAt ||
            (lhs.capturedAt == rhs.capturedAt && lhs.snapshotID < rhs.snapshotID)
    }
}

extension MValuationSnapshot.Key: Comparable {
    
    public static func < (lhs: MValuationSnapshot.Key, rhs: MValuationSnapshot.Key) -> Bool {
        if lhs.snapshotNormID < rhs.snapshotNormID { return true }
        if lhs.snapshotNormID > rhs.snapshotNormID { return false }

        return false
    }

}
