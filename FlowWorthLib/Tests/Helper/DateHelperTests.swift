//
//  DateHelperTests.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

@testable import FlowWorthLib
import XCTest

import AllocData

import FlowBase

fileprivate var df: ISO8601DateFormatter = ISO8601DateFormatter()

class DateHelperTests: XCTestCase {

    func testDistances() throws {
        let base = df.date(from: "2020-06-01T06:00:00Z")!
        let targets = [
            df.date(from: "2020-06-01T12:00:0Z")!,
            df.date(from: "2020-06-02T12:00:00Z")!,
        ]
        let actual = base.distances(to: targets)
        let expected: [TimeInterval] = [21600, 108000]
        XCTAssertEqual(expected, actual)
    }
    
    func testGetStartOfDayGMT() throws {
        let rawDay = df.date(from: "2020-06-01T19:00:00Z")!
        let actual = getStartOfDay(for: rawDay, timeZone: TimeZone.init(identifier: "GMT")!)
        let expected = df.date(from: "2020-06-01T00:00:00Z")!
        XCTAssertEqual(expected, actual)
    }
    
    func testGetStartOfDayEST() throws {
        let rawDay = df.date(from: "2020-06-01T19:00:00Z")!
        let actual = getStartOfDay(for: rawDay, timeZone: TimeZone.init(identifier: "EST")!)
        let expected = df.date(from: "2020-06-01T05:00:00Z")!
        XCTAssertEqual(expected, actual)
    }

    func testGetStartOfDayMST1() throws {
        let rawDay = df.date(from: "2020-06-02T06:59:59Z")!
        let actual = getStartOfDay(for: rawDay, timeZone: TimeZone.init(identifier: "MST")!)
        let expected = df.date(from: "2020-06-01T07:00:00Z")!
        XCTAssertEqual(expected, actual)
    }
    
    func testGetStartOfDayMST2() throws {
        let rawDay = df.date(from: "2020-06-02T07:00:00Z")!
        let actual = getStartOfDay(for: rawDay, timeZone: TimeZone.init(identifier: "MST")!)
        let expected = df.date(from: "2020-06-02T07:00:00Z")!
        XCTAssertEqual(expected, actual)
    }

    func testGetWindow() throws {
        let rawDay = df.date(from: "2020-06-01T19:00:00Z")!
        let expectedBeg = df.date(from: "2020-05-31T19:00:00Z")!
        let expectedEnd = df.date(from: "2020-06-02T19:00:00Z")!
        let expected = DateInterval(start: expectedBeg, end: expectedEnd)
        let actual = getWindow(rawDay)
        XCTAssertEqual(expected, actual)
    }

    func testInBegZone02Midnight() throws {
        let prevCapturedAt = df.date(from: "2020-06-02T00:00:00Z")!
        XCTAssertFalse(getWindow(df.date(from: "2020-05-31T23:59:59Z")!)!.contains(prevCapturedAt))
        XCTAssertTrue( getWindow(df.date(from: "2020-06-01T00:00:00Z")!)!.contains(prevCapturedAt))
        XCTAssertTrue( getWindow(df.date(from: "2020-06-03T00:00:00Z")!)!.contains(prevCapturedAt))
        XCTAssertFalse(getWindow(df.date(from: "2020-06-03T00:00:01Z")!)!.contains(prevCapturedAt))
    }

    func testInBegZone02JustPastMidnight() throws {
        let prevCapturedAt = df.date(from: "2020-06-02T00:00:01Z")!
        XCTAssertFalse(getWindow(df.date(from: "2020-06-01T00:00:00Z")!)!.contains(prevCapturedAt))
        XCTAssertTrue( getWindow(df.date(from: "2020-06-01T00:00:01Z")!)!.contains(prevCapturedAt))
        XCTAssertTrue( getWindow(df.date(from: "2020-06-03T00:00:01Z")!)!.contains(prevCapturedAt))
        XCTAssertFalse(getWindow(df.date(from: "2020-06-03T00:00:02Z")!)!.contains(prevCapturedAt))
    }
    
    func testIntervalZero() throws {
        let start = df.date(from: "2020-06-01T00:00:00Z")!
        let end = df.date(from: "2020-06-30T00:00:00Z")!
        let di = DateInterval(start: start, end: end)
        
        let actual = di.at(0)
        XCTAssertEqual(start, actual)
    }
    
    func testIntervalOne() throws {
        let start = df.date(from: "2020-06-01T00:00:00Z")!
        let end = df.date(from: "2020-06-30T00:00:00Z")!
        let di = DateInterval(start: start, end: end)
        
        let actual = di.at(1)
        XCTAssertEqual(end, actual)
    }
    
    func testIntervalMidway() throws {
        let start = df.date(from: "2020-06-01T00:00:00Z")!
        let end = df.date(from: "2020-06-30T00:00:00Z")!
        let di = DateInterval(start: start, end: end)
        
        let actual = di.midway
        let expected = df.date(from: "2020-06-15T12:00:00Z")!
        XCTAssertEqual(expected, actual)
    }
    
    func testIntervalNegative1() throws {
        let start = df.date(from: "2020-06-01T00:00:00Z")!
        let end = df.date(from: "2020-06-30T00:00:00Z")!
        let di = DateInterval(start: start, end: end)
        
        let actual = di.at(-1)
        let expected = df.date(from: "2020-05-03T00:00:00Z")!
        XCTAssertEqual(expected, actual)
    }
    
    func testIntervalPositive2() throws {
        let start = df.date(from: "2020-06-01T00:00:00Z")!
        let end = df.date(from: "2020-06-30T00:00:00Z")!
        let di = DateInterval(start: start, end: end)
        
        let actual = di.at(2)
        let expected = df.date(from: "2020-07-29T00:00:00Z")!
        XCTAssertEqual(expected, actual)
    }
}
