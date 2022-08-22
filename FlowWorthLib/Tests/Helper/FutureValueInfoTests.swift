//
//  FutureValueInfoTests.swift
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

class FutureValueInfoTests: XCTestCase {

    typealias FLR = FutureValueInfo.LR
    typealias Point = FLR.Point
    
    var df: ISO8601DateFormatter!
    var timestamp1: Date!
    var timestamp2: Date!
    var timestamp3: Date!

    override func setUpWithError() throws {
        df = ISO8601DateFormatter()
        timestamp1 = df.date(from: "2020-06-01T06:00:00Z")!
        timestamp2 = df.date(from: "2020-07-01T06:00:00Z")!
        timestamp3 = df.date(from: "2020-07-31T06:00:00Z")!
    }

    func testEstimatedDate() {
        let points = [
            Point(x: timestamp1.timeIntervalSinceReferenceDate, y: 100),
            Point(x: timestamp2.timeIntervalSinceReferenceDate, y: 200),
        ]
        let lr = FLR(points: points)!
        let actual = FutureValueInfo.getEstimatedDate(begInterval: 0.0, lr: lr, futureValue: 300.0)
        let expected = timestamp3
        XCTAssertEqual(expected, actual)
    }
    
    func testGetFutureValuesEmpty() {
        XCTAssertNil(FLR(points: []))
    }
    
    func testGetFutureValuesOne() {
        let points = [
            Point(x: timestamp1.timeIntervalSinceReferenceDate, y: 100),
        ]
        let lr = FLR(points: points)!
        let expected: [FutureValueInfo] = []
        let actual = FutureValueInfo.getFutureValues([300.0], begInterval: 0.0, lr: lr)
        XCTAssertEqual(expected, actual)
    }
    
    func testGetFutureValuesTwo() {
        let points = [
            Point(x: timestamp1.timeIntervalSinceReferenceDate, y: 100),
            Point(x: timestamp2.timeIntervalSinceReferenceDate, y: 200),
        ]
        let lr = FLR(points: points)!
        let expected: [FutureValueInfo] = [
            FutureValueInfo(futureValue: 220, estimatedDate: df.date(from: "2020-07-07T06:00:00Z")!),
            FutureValueInfo(futureValue: 240, estimatedDate: df.date(from: "2020-07-13T06:00:00Z")!),
            FutureValueInfo(futureValue: 260, estimatedDate: df.date(from: "2020-07-19T06:00:00Z")!)
        ]
        let actual = FutureValueInfo.getFutureValues([220, 240, 260], begInterval: 0.0, lr: lr)
        XCTAssertEqual(expected, actual)
    }
    
    func testGetNiceScalePositive() {
        let points = [
            Point(x: timestamp1.timeIntervalSinceReferenceDate, y: 100),
            Point(x: timestamp2.timeIntervalSinceReferenceDate, y: 200),
        ]
        let lr = FLR(points: points)!
        let actual = FutureValueInfo.getNiceScale(lr: lr, desiredTicks: 3)!.tickValues
        let expected = [200.0, 220.0, 240.0, 260.0]
        XCTAssertEqual(expected, actual)
    }
    
    func testGetNiceScaleNegativeToPositive() {
        let points = [
            Point(x: timestamp1.timeIntervalSinceReferenceDate, y: -100),
            Point(x: timestamp2.timeIntervalSinceReferenceDate, y: -50),
        ]
        let lr = FLR(points: points)!
        let actual = FutureValueInfo.getNiceScale(lr: lr, multiplier: 3.0, desiredTicks: 12)!.tickValues
        let expected = [-50.0, -40.0, -30.0, -20.0, -10.0, 0.0, 10.0, 20.0, 30.0, 40.0, 50.0]
        XCTAssertEqual(expected, actual)
    }
}
