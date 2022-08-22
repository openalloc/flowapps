//
//  Date-Helpers.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

fileprivate var df: ISO8601DateFormatter = ISO8601DateFormatter()

extension Calendar {
    func numberOfDaysBetween(_ from: Date, and to: Date) -> Int {
        let fromDate = startOfDay(for: from) // <1>
        let toDate = startOfDay(for: to) // <2>
        let numberOfDays = dateComponents([.day], from: fromDate, to: toDate) // <3>
        
        return numberOfDays.day!
    }

    func startOfNextDay(for date: Date) -> Date {
        let _startOfDay = self.startOfDay(for: date)
        return self.date(byAdding: .day, value: 1, to: _startOfDay)!
    }
    
    func startOfMonth(for date: Date) -> Date {
        self.date(from: self.dateComponents([.year, .month],
                                            from: self.startOfDay(for: date)))!
    }
    
    func startOfNextMonth(for date: Date) -> Date {
        let _startOfMonth = self.startOfMonth(for: date)
        return self.date(byAdding: .month, value: 1, to: _startOfMonth)!
    }

    func endOfMonth(for date: Date) -> Date {
        self.date(byAdding: DateComponents(month: 1, second: -1),
                  to: self.startOfMonth(for: date))!
    }
    
    func startOfYear(for date: Date) -> Date {
        let year = self.component(.year, from: date)
        return self.date(from: DateComponents(year: year, month: 1, day: 1, hour: 0, minute: 0, second: 0, nanosecond: 0))!
    }
    
    func startOfNextYear(for date: Date) -> Date {
        let _startOfYear = self.startOfYear(for: date)
        return self.date(byAdding: .year, value: 1, to: _startOfYear)!
    }
}

/// for a given timestamp, return the timestamp for the start of the day (aka midnight)
public func getStartOfDay(for date: Date, timeZone: TimeZone = Calendar.current.timeZone) -> Date {
    var cal = Calendar.current
    cal.timeZone = timeZone
    return cal.startOfDay(for: date)
}

// get a window Date range around which a rough date could potentially encompass
public func getWindow(_ base: Date, widthSeconds: Int = 86400 * 2) -> DateInterval? {
    let halfWidth = widthSeconds / 2
    guard let start = Calendar.current.date(byAdding: .second, value: -halfWidth, to: base),
          let end = Calendar.current.date(byAdding: .second, value: halfWidth, to: base)
    else { return nil }
    return DateInterval(start: start, end: end)
}

public extension Date {
    func distances(to timestamps: [Date]) -> [TimeInterval] {
        timestamps.map { self.distance(to: $0) }
    }
    func distances(to timeIntervals: [TimeInterval]) -> [TimeInterval] {
        let start = self.timeIntervalSinceReferenceDate
        return timeIntervals.map { $0 - start }
    }
}

extension DateInterval {
    func clamp(_ date: Date) -> Date {
        if date < start {
            return start
        } else if end < date {
            return end
        } else {
            return date
        }
    }
}

public extension DateInterval {
    
    // Return the date relative to the interval, where 0 is the start of the interval, and 1 its end (or length also).
    // To select inside interval, use unit value 0...1
    // To select prior to interval, use negative
    // To select after interval, use 1+
    func at(_ unitVal: Double) -> Date {
        self.start + (unitVal * self.duration)
    }
    
    var midway: Date {
        at(0.5)
    }
}
