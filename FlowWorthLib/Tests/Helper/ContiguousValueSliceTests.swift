//
//  ContiguousValueSliceTests.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

@testable import FlowWorthLib
import XCTest

class ContiguousValueSliceTests: XCTestCase {

    func testEmpty() {
        let ar: [Int] = []
        let actual: ArraySlice<Int>? = ar.contiguousValueSlice(startValue: 0, endValue: 0)
        let expected: ArraySlice<Int>? = nil
        XCTAssertEqual(expected, actual)
    }
    
    func testOneNotFound() {
        let ar: [Int] = [1]
        let actual: ArraySlice<Int>? = ar.contiguousValueSlice(startValue: 0, endValue: 0)
        let expected: ArraySlice<Int>? = nil
        XCTAssertEqual(expected, actual)
    }

    func testOneFound() {
        let ar: [Int] = [1]
        let actual: ArraySlice<Int>? = ar.contiguousValueSlice(startValue: 1, endValue: 1)
        let expected: ArraySlice<Int>? = [1]
        XCTAssertEqual(expected, actual)
    }
    
    func testTwoFirstNotFound() {
        let ar: [Int] = [1,2]
        let actual: ArraySlice<Int>? = ar.contiguousValueSlice(startValue: 0, endValue: 2)
        let expected: ArraySlice<Int>? = nil
        XCTAssertEqual(expected, actual)
    }

    func testTwoSecondNotFound() {
        let ar: [Int] = [1,2]
        let actual: ArraySlice<Int>? = ar.contiguousValueSlice(startValue: 1, endValue: 3)
        let expected: ArraySlice<Int>? = nil
        XCTAssertEqual(expected, actual)
    }

    func testTwoFound() {
        let ar: [Int] = [1,2]
        let actual: ArraySlice<Int>? = ar.contiguousValueSlice(startValue: 1, endValue: 2)
        let expected: ArraySlice<Int>? = [1,2]
        XCTAssertEqual(expected, actual)
    }
    
    func testTwoFoundIgnoringSecondDupe() {
        let ar: [Int] = [1,2,2]
        let actual: ArraySlice<Int>? = ar.contiguousValueSlice(startValue: 1, endValue: 2)
        let expected: ArraySlice<Int>? = [1,2]
        XCTAssertEqual(expected, actual)
    }
    
    func testTwoFoundWithPadding() {
        let ar: [Int] = [0,1,2,3]
        let actual: ArraySlice<Int>? = ar.contiguousValueSlice(startValue: 1, endValue: 2)
        let expected: ArraySlice<Int>? = [1,2]
        XCTAssertEqual(expected, actual)
    }

    func testTwoFoundWithIntervening() {
        let ar: [Int] = [1,2,3]
        let actual: ArraySlice<Int>? = ar.contiguousValueSlice(startValue: 1, endValue: 3)
        let expected: ArraySlice<Int>? = [1,2,3]
        XCTAssertEqual(expected, actual)
    }

    func testTwoFoundWithDupeIntervening() {
        let ar: [Int] = [1,1,3]
        let actual: ArraySlice<Int>? = ar.contiguousValueSlice(startValue: 1, endValue: 3)
        let expected: ArraySlice<Int>? = [1,1,3]
        XCTAssertEqual(expected, actual)
    }


}
