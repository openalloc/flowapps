//
//  FloatingPointTests.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
//

import XCTest

@testable import FlowBase

class FloatingPointTests: XCTestCase {
    func testNinetyNinePointNine() {
        let sum: Double = 0.999 // 99.9%

        // starting from least accurate to greater accuracy
        XCTAssertTrue(sum.isEqual(to: 1.000, accuracy: 0.0100)) // 1.00%
        XCTAssertTrue(sum.isEqual(to: 1.000, accuracy: 0.0090)) // 0.90%
        XCTAssertTrue(sum.isEqual(to: 1.000, accuracy: 0.0020)) // 0.20%
        XCTAssertTrue(sum.isEqual(to: 1.000, accuracy: 0.0015)) // 0.15%
        XCTAssertTrue(sum.isEqual(to: 1.000, accuracy: 0.0011)) // 0.11%
        XCTAssertTrue(sum.isEqual(to: 1.000, accuracy: 0.00101)) // 0.101%

        XCTAssertFalse(sum.isEqual(to: 1.000, accuracy: 0.0010)) // 0.10%
        XCTAssertFalse(sum.isEqual(to: 1.000, accuracy: 0.0009)) // 0.09%
    }

    func testEpsilonOneThousandth() {
        let epsilon = 0.001 // 0.01% accuracy (99.91% .. 100.10% valid)

        XCTAssertFalse(1.0000.isEqual(to: 1.0012, accuracy: epsilon)) // 100.12%
        XCTAssertFalse(1.0000.isEqual(to: 1.0011, accuracy: epsilon)) // 100.11%

        XCTAssertTrue(1.0000.isEqual(to: 1.0010, accuracy: epsilon)) // 100.10%
        XCTAssertTrue(1.0000.isEqual(to: 1.0009, accuracy: epsilon)) // 100.09%
        XCTAssertTrue(1.0000.isEqual(to: 1.0008, accuracy: epsilon)) // 100.08%
        XCTAssertTrue(1.0000.isEqual(to: 1.0000, accuracy: epsilon)) // 100.00%
        XCTAssertTrue(1.0000.isEqual(to: 0.9992, accuracy: epsilon)) //  99.92%
        XCTAssertTrue(1.0000.isEqual(to: 0.9991, accuracy: epsilon)) //  99.91%

        XCTAssertFalse(1.0000.isEqual(to: 0.9990, accuracy: epsilon)) //  99.90%
        XCTAssertFalse(1.0000.isEqual(to: 0.9989, accuracy: epsilon)) //  99.89%
    }

    func testLessThan() {
        let epsilon = 0.001 // 0.01% accuracy (99.91% .. 100.10% valid)

        XCTAssertFalse(1.0000.isLess(than: 1.0001, accuracy: epsilon))
        XCTAssertFalse(1.0000.isLess(than: 1.0010, accuracy: epsilon))

        XCTAssertTrue(1.0000.isLess(than: 1.0020, accuracy: epsilon))
        XCTAssertTrue(1.0000.isLess(than: 1.0090, accuracy: epsilon))
        XCTAssertTrue(1.0000.isLess(than: 1.0100, accuracy: epsilon))
    }

    func testLessThanZero() {
        let epsilon = 0.001 // 0.01% accuracy (99.91% .. 100.10% valid)

        XCTAssertFalse(0.0001.isLess(than: 0, accuracy: epsilon))
        XCTAssertFalse(0.0009.isLess(than: 0, accuracy: epsilon))
        XCTAssertFalse(0.0010.isLess(than: 0, accuracy: epsilon))
    }

    func testLessThanOrEqual() {
        let epsilon = 0.001 // 0.01% accuracy (99.91% .. 100.10% valid)

        XCTAssertFalse(1.0000.isLessThanOrEqual(to: 0.9989, accuracy: epsilon))
        XCTAssertFalse(1.0000.isLessThanOrEqual(to: 0.9990, accuracy: epsilon))

        XCTAssertTrue(1.0000.isLessThanOrEqual(to: 0.9991, accuracy: epsilon))
        XCTAssertTrue(1.0000.isLessThanOrEqual(to: 0.9992, accuracy: epsilon))
        XCTAssertTrue(1.0000.isLessThanOrEqual(to: 0.9998, accuracy: epsilon))
        XCTAssertTrue(1.0000.isLessThanOrEqual(to: 0.9999, accuracy: epsilon))
        XCTAssertTrue(1.0000.isLessThanOrEqual(to: 1.0000, accuracy: epsilon))
        XCTAssertTrue(1.0000.isLessThanOrEqual(to: 1.0001, accuracy: epsilon))
        XCTAssertTrue(1.0000.isLessThanOrEqual(to: 1.0010, accuracy: epsilon))
        XCTAssertTrue(1.0000.isLessThanOrEqual(to: 1.0020, accuracy: epsilon))
        XCTAssertTrue(1.0000.isLessThanOrEqual(to: 1.0090, accuracy: epsilon))
        XCTAssertTrue(1.0000.isLessThanOrEqual(to: 1.0100, accuracy: epsilon))
    }

    func testLessThanOrEqualToZero() {
        let epsilon = 0.001 // 0.01% accuracy (99.91% .. 100.10% valid)

        XCTAssertTrue(0.0001.isLessThanOrEqual(to: 0, accuracy: epsilon))
        XCTAssertTrue(0.0009.isLessThanOrEqual(to: 0, accuracy: epsilon))

        XCTAssertFalse(0.0010.isLessThanOrEqual(to: 0, accuracy: epsilon))
    }

    func testGreaterThan() {
        let epsilon = 0.001 // 0.01% accuracy (99.91% .. 100.10% valid)

        XCTAssertTrue(1.0000.isGreater(than: 0.9989, accuracy: epsilon))
        XCTAssertTrue(1.0000.isGreater(than: 0.9990, accuracy: epsilon))

        XCTAssertFalse(1.0000.isGreater(than: 0.9991, accuracy: epsilon))
        XCTAssertFalse(1.0000.isGreater(than: 0.9992, accuracy: epsilon))
        XCTAssertFalse(1.0000.isGreater(than: 0.9998, accuracy: epsilon))
        XCTAssertFalse(1.0000.isGreater(than: 0.9999, accuracy: epsilon))
        XCTAssertFalse(1.0000.isGreater(than: 1.0000, accuracy: epsilon))
        XCTAssertFalse(1.0000.isGreater(than: 1.0001, accuracy: epsilon))
        XCTAssertFalse(1.0000.isGreater(than: 1.0010, accuracy: epsilon))
        XCTAssertFalse(1.0000.isGreater(than: 1.0020, accuracy: epsilon))
        XCTAssertFalse(1.0000.isGreater(than: 1.0090, accuracy: epsilon))
        XCTAssertFalse(1.0000.isGreater(than: 1.0100, accuracy: epsilon))
    }

    func testGreaterThanZero() {
        let epsilon = 0.001 // 0.01% accuracy (99.91% .. 100.10% valid)

        XCTAssertFalse((-0.0001).isGreater(than: 0, accuracy: epsilon))
        XCTAssertFalse((-0.0009).isGreater(than: 0, accuracy: epsilon))

        XCTAssertFalse((-0.0010).isGreater(than: 0, accuracy: epsilon))
    }

    func testGreaterThanOrEqual() {
        let epsilon = 0.001 // 0.01% accuracy (99.91% .. 100.10% valid)

        XCTAssertTrue(1.0000.isGreaterThanOrEqual(to: 0.9989, accuracy: epsilon))
        XCTAssertTrue(1.0000.isGreaterThanOrEqual(to: 0.9990, accuracy: epsilon))
        XCTAssertTrue(1.0000.isGreaterThanOrEqual(to: 0.9999, accuracy: epsilon))
        XCTAssertTrue(1.0000.isGreaterThanOrEqual(to: 1.0000, accuracy: epsilon))
        XCTAssertTrue(1.0000.isGreaterThanOrEqual(to: 1.0001, accuracy: epsilon))
        XCTAssertTrue(1.0000.isGreaterThanOrEqual(to: 1.0010, accuracy: epsilon))

        XCTAssertFalse(1.0000.isGreaterThanOrEqual(to: 1.0020, accuracy: epsilon))
        XCTAssertFalse(1.0000.isGreaterThanOrEqual(to: 1.0090, accuracy: epsilon))
        XCTAssertFalse(1.0000.isGreaterThanOrEqual(to: 1.0100, accuracy: epsilon))
    }

    func testGreaterThanOrEqualToZero() {
        let epsilon = 0.001 // 0.01% accuracy (99.91% .. 100.10% valid)

        XCTAssertTrue((-0.0001).isGreaterThanOrEqual(to: 0, accuracy: epsilon))
        XCTAssertTrue((-0.0009).isGreaterThanOrEqual(to: 0, accuracy: epsilon))

        XCTAssertFalse((-0.0010).isGreaterThanOrEqual(to: 0, accuracy: epsilon))
    }

    func testCoerceIfEqual() {
        let epsilon = 0.001 // 0.01% accuracy (99.91% .. 100.10% valid)

        let testEpsilon = 0.00001 // XCT must be more stringent

        XCTAssertEqual(1.0012, 1.0012.coerceIfEqual(to: 1, accuracy: epsilon), accuracy: testEpsilon) // 100.12%
        XCTAssertEqual(1.0011, 1.0011.coerceIfEqual(to: 1, accuracy: epsilon), accuracy: testEpsilon) // 100.11%

        XCTAssertEqual(1, 1.0010.coerceIfEqual(to: 1, accuracy: epsilon), accuracy: testEpsilon) // 100.10%
        XCTAssertEqual(1, 1.0009.coerceIfEqual(to: 1, accuracy: epsilon), accuracy: testEpsilon) // 100.09%
        XCTAssertEqual(1, 1.0008.coerceIfEqual(to: 1, accuracy: epsilon), accuracy: testEpsilon) // 100.08%
        XCTAssertEqual(1, 1.0000.coerceIfEqual(to: 1, accuracy: epsilon), accuracy: testEpsilon) // 100.00%
        XCTAssertEqual(1, 0.9992.coerceIfEqual(to: 1, accuracy: epsilon), accuracy: testEpsilon) //  99.92%
        XCTAssertEqual(1, 0.9991.coerceIfEqual(to: 1, accuracy: epsilon), accuracy: testEpsilon) //  99.91%

        XCTAssertEqual(0.9990, 0.9990.coerceIfEqual(to: 1, accuracy: epsilon), accuracy: testEpsilon) //  99.90%
        XCTAssertEqual(0.9989, 0.9989.coerceIfEqual(to: 1, accuracy: epsilon), accuracy: testEpsilon) //  99.89%
    }
    
    func testIsEqualToZero() {
        let epsilon = 0.001 // 0.01% accuracy (99.91% .. 100.10% valid)

        XCTAssertTrue(0.0001.isEqualToZero(accuracy: epsilon))
        XCTAssertTrue(0.0009.isEqualToZero(accuracy: epsilon))
        XCTAssertFalse(0.0010.isEqualToZero(accuracy: epsilon))
        XCTAssertTrue((-0.0001).isEqualToZero(accuracy: epsilon))
        XCTAssertTrue((-0.0009).isEqualToZero(accuracy: epsilon))
        XCTAssertFalse((-0.0010).isEqualToZero(accuracy: epsilon))
    }

}
