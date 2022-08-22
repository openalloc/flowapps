//
//  MTracker+Comparable.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

import AllocData

extension MTracker: Comparable {
    public static func < (lhs: MTracker, rhs: MTracker) -> Bool {
        lhs._title < rhs._title ||
            (lhs.title == rhs.title && lhs.trackerID < rhs.trackerID)
    }

    private var _title: String {
        title ?? ""
    }
}

extension MTracker.Key: Comparable {
    
    public static func < (lhs: MTracker.Key, rhs: MTracker.Key) -> Bool {
        if lhs.trackerNormID < rhs.trackerNormID { return true }
        if lhs.trackerNormID > rhs.trackerNormID { return false }
        return false
    }

}


//extension BaseModel {
//    
//    /// sort using the provided comparator, with option to use the comparator in reverse
//    public mutating func sortBy(_ forward: Bool = true, _ comparator: (MTracker, MTracker) -> Bool ) {
//        sortByField(forward, \.trackers, comparator)
//    }
//}
