//
//  DateTimeHelperTests.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import XCTest

@testable import FlowBase

class DateTimeHelperTests: XCTestCase {
    func test5DaysBackMidnight() {
        let df = ISO8601DateFormatter()

        let timestamp = df.date(from: "2020-11-16T22:43:59Z")!
        let expected = df.date(from: "2020-11-11T05:00:00Z")!

        let timeZone = TimeZone(abbreviation: "EST")!

        let actual = getDaysBackMidnight(daysBack: 5, timestamp: timestamp, timeZone: timeZone)

        XCTAssertEqual(expected, actual)
    }

    // no offset
    func test30DaysBackMidnightGMT() {
        let df = ISO8601DateFormatter()

        let expected = df.date(from: "2020-06-01T00:00:00Z")!

        let timeZone = TimeZone(abbreviation: "GMT")!

        // INSIDE WINDOW
        for timestampStr in ["2020-07-01T00:00:00Z", "2020-07-01T23:59:59Z"] {
            let timestamp = df.date(from: timestampStr)!
            let actual = getDaysBackMidnight(daysBack: 30, timestamp: timestamp, timeZone: timeZone)

            XCTAssertEqual(expected, actual)
        }

        // OUTSIDE WINDOW
        for timestampStr in ["2020-06-30T23:59:59Z", "2020-07-02T00:00:00Z"] {
            let timestamp = df.date(from: timestampStr)!
            let actual = getDaysBackMidnight(daysBack: 30, timestamp: timestamp, timeZone: timeZone)

            XCTAssertNotEqual(expected, actual)
        }
    }

    // EST is four hours ahead of GMT
    func test30DaysBackMidnightEST1() {
        let df = ISO8601DateFormatter()

        let expected = df.date(from: "2020-06-01T00:00:00-04:00")!

        let timeZone = TimeZone(abbreviation: "EST")!

        // INSIDE WINDOW
        for timestampStr in ["2020-07-01T00:00:00-04:00", "2020-07-01T23:59:59-04:00"] {
            let timestamp = df.date(from: timestampStr)!
            let actual = getDaysBackMidnight(daysBack: 30, timestamp: timestamp, timeZone: timeZone)

            XCTAssertEqual(expected, actual)
        }

        // OUTSIDE WINDOW
        for timestampStr in ["2020-06-30T23:59:59-04:00", "2020-07-02T00:00:00-04:00"] {
            let timestamp = df.date(from: timestampStr)!
            let actual = getDaysBackMidnight(daysBack: 30, timestamp: timestamp, timeZone: timeZone)

            XCTAssertNotEqual(expected, actual)
        }
    }

    // EST is four hours ahead of GMT
    func test30DaysBackMidnightEST2() {
        let df = ISO8601DateFormatter()

        let expected = df.date(from: "2020-06-01T04:00:00Z")!

        let timeZone = TimeZone(abbreviation: "EST")!

        // INSIDE WINDOW
        for timestampStr in ["2020-07-01T04:00:00Z", "2020-07-02T03:59:59Z"] {
            let timestamp = df.date(from: timestampStr)!
            let actual = getDaysBackMidnight(daysBack: 30, timestamp: timestamp, timeZone: timeZone)

            XCTAssertEqual(expected, actual)
        }

        // OUTSIDE WINDOW
        for timestampStr in ["2020-07-01T03:59:59Z", "2020-07-02T04:00:00Z"] {
            let timestamp = df.date(from: timestampStr)!
            let actual = getDaysBackMidnight(daysBack: 30, timestamp: timestamp, timeZone: timeZone)

            XCTAssertNotEqual(expected, actual)
        }
    }
}
