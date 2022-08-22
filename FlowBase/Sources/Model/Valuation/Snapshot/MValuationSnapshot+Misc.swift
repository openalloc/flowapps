//
//  MValuationSnapshot+Misc.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

import AllocData

extension MValuationSnapshot.Key: CustomStringConvertible {
    public var description: String {
        "SnapshotID: '\(snapshotNormID)'"
    }
}

extension MValuationSnapshot.Key {
    public static var empty: MValuationSnapshot.Key = MValuationSnapshot.Key(snapshotID: "")
}

extension MValuationSnapshot: Titled {
    static let df: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .medium
        df.timeStyle = .short
        return df
    }()

    public var titleID: String {
        title ?? "Unknown Snapshot"
    }
    
    public var title: String? {
        MValuationSnapshot.df.string(from: capturedAt)
    }
}

