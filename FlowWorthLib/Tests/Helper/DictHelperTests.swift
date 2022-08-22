//
//  DictHelperTests.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

@testable import FlowWorthLib
import XCTest

class DictHelperTests: XCTestCase {

    func testPlus() {
        let actual = ["a": 3, "b": 2, "d": 8].add(["a": 1, "c": 4, "d": 8])
        let expected = ["a": 4, "b": 2, "c": 4, "d": 16]
        XCTAssertEqual(expected, actual)
    }
    
    func testMinus() {
        let actual = ["a": 3, "b": 2, "d": 8].subtract(["a": 1, "c": 4, "d": 8])
        let expected = ["a": 2, "b": 2, "c": -4]
        XCTAssertEqual(expected, actual)
    }
}
