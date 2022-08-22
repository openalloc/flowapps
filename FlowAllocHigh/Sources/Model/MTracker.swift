//
//  MTracker.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//


import Foundation

import AllocData

import FlowAllocLow
import FlowBase


public extension MTracker {
    static func getTrackerSecuritiesMap(_ securities: [MSecurity]) -> TrackerSecuritiesMap {
        securities.reduce(into: [:]) { map, security in
            let trackerKey = security.trackerKey
            if trackerKey.isValid {
                map[trackerKey, default: []].append(security)
            }
        }
    }

    func getEquivalentTickerKeys(_ securities: [MSecurity]) -> [SecurityKey] {
        securities.compactMap {
            guard primaryKey == $0.trackerKey else { return nil }
            return $0.primaryKey
        }
    }
}
