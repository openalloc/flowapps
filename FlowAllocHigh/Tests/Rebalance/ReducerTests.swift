//
//  ReducerTests.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import XCTest

import SimpleTree

import FlowAllocLow
import FlowBase
import AllocData

@testable import FlowAllocHigh

class ReducerTests: XCTestCase {
    let a = MAsset.Key(assetID: "a")
    let b = MAsset.Key(assetID: "b")
    let c = MAsset.Key(assetID: "c")

    func testDifferentSwappedPairNotEqual() throws {
        let p1 = ReducerPair(a, b)
        let p2 = ReducerPair(b, a)
        XCTAssertNotEqual(p1, p2)
        XCTAssertNotEqual(p1.hashValue, p2.hashValue)
    }

    func testMirror() throws {
        let p1 = ReducerPair(a, b)
        let p2 = ReducerPair(b, a)
        XCTAssertEqual(p1.mirror, p2)
        XCTAssertEqual(p2.mirror, p1)
    }

    func testGenerateReducerMap2a() throws {
        let relations: DeepRelationsMap = [b: [a]]
        let rebalanceMap = [a: 1.0, b: -1.0]
        let expected = [ReducerPair(b, a): 1.0]
        let reducerMap = generateReducerMap(rebalanceMap, relations, orderBy: { $0 < $1 })
        XCTAssertEqual(expected, reducerMap)

        let expected2: AssetValueMap = [:]
        let actual2 = applyReducerMap(rebalanceMap, reducerMap, preserveZero: false)
        XCTAssertEqual(expected2, actual2)

        let expected3: AssetValueMap = [a: 0.0, b: 0.0]
        let actual3 = applyReducerMap(rebalanceMap, reducerMap, preserveZero: true)
        XCTAssertEqual(expected3, actual3)
    }

    func testGenerateReducerMap2b() throws {
        let relations: DeepRelationsMap = [a: [b]]
        let rebalanceMap = [a: -1.0, b: 1.0]
        let expected = [ReducerPair(a, b): 1.0]
        let reducerMap = generateReducerMap(rebalanceMap, relations, orderBy: { $0 < $1 })
        XCTAssertEqual(expected, reducerMap)

        let expected2: AssetValueMap = [:]
        let actual2 = applyReducerMap(rebalanceMap, reducerMap, preserveZero: false)
        XCTAssertEqual(expected2, actual2)

        let expected3: AssetValueMap = [a: 0.0, b: 0.0]
        let actual3 = applyReducerMap(rebalanceMap, reducerMap, preserveZero: true)
        XCTAssertEqual(expected3, actual3)
    }

    func testGenerateReducer2of3() throws {
        let relations: DeepRelationsMap = [b: [a]]
        let rebalanceMap = [a: 1.0, b: -1.0, c: 3.0]
        let expected = [ReducerPair(b, a): 1.0]
        let reducerMap = generateReducerMap(rebalanceMap, relations, orderBy: { $0 < $1 })
        XCTAssertEqual(expected, reducerMap)

        let expected2: AssetValueMap = [c: 3.0]
        let actual = applyReducerMap(rebalanceMap, reducerMap, preserveZero: false)
        XCTAssertEqual(expected2, actual)
    }

    func testReduceFromTwo() throws {
        let relations: DeepRelationsMap = [b: [a, c]]
        let rebalanceMap = [a: 1.0, b: -2.0, c: 3.0]
        let expected = [ReducerPair(b, a): 1.0, ReducerPair(b, c): 1.0]
        let reducerMap = generateReducerMap(rebalanceMap, relations, orderBy: { $0 < $1 })
        XCTAssertEqual(expected, reducerMap)

        let expected2: AssetValueMap = [c: 2.0]
        let actual2 = applyReducerMap(rebalanceMap, reducerMap, preserveZero: false)
        XCTAssertEqual(expected2, actual2)

        let expected3: AssetValueMap = [a: 0.0, b: 0.0, c: 2.0]
        let actual3 = applyReducerMap(rebalanceMap, reducerMap, preserveZero: true)
        XCTAssertEqual(expected3, actual3)
    }

    func testUseSort() throws {
        let relations: DeepRelationsMap = [b: [a], c: [a]]
        let rebalanceMap = [a: 1.0, b: -1.0, c: -1.0]
        let expected = [ReducerPair(c, a): 1.0]
        let reducerMap = generateReducerMap(rebalanceMap, relations, orderBy: { $1 < $0 }) // should favor c over b
        XCTAssertEqual(expected, reducerMap)

        let expected2: AssetValueMap = [b: -1.0]
        let actual = applyReducerMap(rebalanceMap, reducerMap, preserveZero: false)
        XCTAssertEqual(expected2, actual)
    }

    func testDualWithPositive() throws {
        let relations: DeepRelationsMap = [b: [a], c: [a]]
        let rebalanceMap = [a: 5.0, b: -3.0, c: -1.0]
        let expected = [ReducerPair(c, a): 1.0, ReducerPair(b, a): 3.0]
        let reducerMap = generateReducerMap(rebalanceMap, relations, orderBy: { $0 < $1 })
        XCTAssertEqual(expected, reducerMap)

        let expected2: AssetValueMap = [a: 1.0]
        let actual = applyReducerMap(rebalanceMap, reducerMap, preserveZero: false)
        XCTAssertEqual(expected2, actual)
    }

    func testApply() throws {
        let rebalanceMap = [a: 1.0, b: -1.0, c: 3.0]
        let reducerMap = [ReducerPair(a, b): -1.0]
        let expected = [c: 3.0]
        let actual = applyReducerMap(rebalanceMap, reducerMap, preserveZero: false)
        XCTAssertEqual(expected, actual)
    }
}
