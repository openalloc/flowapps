//
//  DateTime-helpers.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

public func getDaysBackMidnight(daysBack: Int,
                                timestamp: Date,
                                timeZone: TimeZone = TimeZone.current) -> Date?
{
    var cal = Calendar(identifier: .gregorian)
    cal.timeZone = timeZone

    guard let daysAgoExact = cal.date(byAdding: .day, value: -daysBack, to: timestamp)
    else { return nil }

    return cal.startOfDay(for: daysAgoExact)
}
