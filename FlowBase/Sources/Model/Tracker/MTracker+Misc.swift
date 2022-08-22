//
//  MTracker+Misc.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

import AllocData

extension MTracker.Key: CustomStringConvertible {
    public var description: String {
        "TrackerID: '\(trackerNormID)'"
    }
}

extension MTracker: Titled {
    public var titleID: String {
        guard let title_ = title else { return trackerID }
        return title_ == trackerID ? title_ : "\(title_) (\(trackerID))"
    }
}

public extension MTracker {
    static func getTitleID(_ trackerKey: TrackerKey?, _ trackerMap: TrackerMap, withID: Bool) -> String? {
        guard let tracker = getTracker(trackerKey, trackerMap)
        else { return nil }
        return withID ? tracker.titleID : tracker.title
    }

    private static func getTracker(_ trackerKey: TrackerKey?, _ trackerMap: TrackerMap) -> MTracker? {
        guard let trackerKey_ = trackerKey,
              let tracker = trackerMap[trackerKey_] else { return nil }
        return tracker
    }
}
