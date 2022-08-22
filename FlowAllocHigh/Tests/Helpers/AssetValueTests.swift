//
//  AssetValueTests.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import XCTest

import FlowAllocLow
import FlowBase
import AllocData

@testable import FlowAllocHigh

class AssetValueTests: XCTestCase {
    
    let acfoo   = MAsset(assetID: "foo")
    let acbar   = MAsset(assetID: "bar")
    let acbaz   = MAsset(assetID: "baz")
    let acblah  = MAsset(assetID: "blah")
    let acbleep = MAsset(assetID: "bleep")
    let acblort = MAsset(assetID: "blort")
    let acblap  = MAsset(assetID: "blap")

    let account1 = MAccount.Key(accountID: "1")
    let account2 = MAccount.Key(accountID: "2")
    
    let foo   = MAsset.Key(assetID: "foo")
    let bar   = MAsset.Key(assetID: "bar")
    let baz   = MAsset.Key(assetID: "baz")
    let blah  = MAsset.Key(assetID: "blah")
    let bleep = MAsset.Key(assetID: "bleep")
    let blort = MAsset.Key(assetID: "blort")
    let blap  = MAsset.Key(assetID: "blap")

    func testNormalization() throws {
        let foo = acfoo.primaryKey
        let bar = acbar.primaryKey
        let baz = acbaz.primaryKey
        let blah = acblah.primaryKey
        
        let rawMap: [AssetKey: Double] = [
            foo : 100,
            bar : 300,
            baz : 400,
            blah: 0,
        ]

        let expected = [foo: 0.125, bar: 0.375, baz: 0.5, blah: 0]
        let actual = AssetValue.getNormalizedAssetValueMap(from: rawMap, includeZeros: true)
        XCTAssertEqual(expected, actual)
    }

    func testGetAccountAssetValueMap() throws {
        
        let aaMap: AccountAssetValueMap = [
            account1: [
                foo: 100,
                bar: 300,
                baz: 400,
                blah: 0,
            ],
            account2: [
                bleep: 500,
                blort: 100,
                blap: 400,
            ],
        ]

        let expected: AccountAssetValueMap = [account1: [foo: 0.125, bar: 0.375, baz: 0.5, blah: 0],
                                              account2: [bleep: 0.5, blort: 0.1, blap: 0.4]]
        let actual = AssetValue.getAccountAssetValueMap(aaMap)
        XCTAssertEqual(expected, actual)
    }

    func testDistributeWithZero() throws {
        let map: AssetValueMap = [foo: 0.125, bar: 0.375, baz: 0.5, blah: 0.0]
        let actual = AssetValue.distribute(value: 100, allocationMap: map, includeZero: true)
        let expected: AssetValueMap = [foo: 12.5, bar: 37.5, baz: 50.0, blah: 0.0]
        XCTAssertEqual(expected, actual)
    }

    func testDistributeWithoutZero() throws {
        let map: AssetValueMap = [foo: 0.125, bar: 0.375, baz: 0.5, blah: 0.0]
        let actual = AssetValue.distribute(value: 100, allocationMap: map, includeZero: false)
        let expected: AssetValueMap = [foo: 12.5, bar: 37.5, baz: 50.0]
        XCTAssertEqual(expected, actual)
    }

    func testDistributeEmpty() throws {
        let map: AssetValueMap = [:]
        let actual = AssetValue.distribute(value: 100, allocationMap: map, includeZero: true)
        let expected: AssetValueMap = [:]
        XCTAssertEqual(expected, actual)
    }

    func testDistributeNothingWithZero() throws {
        let map: AssetValueMap = [foo: 0.125, bar: 0.375, baz: 0.5, blah: 0.0]
        let actual = AssetValue.distribute(value: 0, allocationMap: map, includeZero: true)
        let expected: AssetValueMap = [foo: 0.0, bar: 0.0, baz: 0.0, blah: 0.0]
        XCTAssertEqual(expected, actual)
    }

    func testDistributeNothingWithoutZero() throws {
        let map: AssetValueMap = [foo: 0.125, bar: 0.375, baz: 0.5, blah: 0.0]
        let actual = AssetValue.distribute(value: 0, allocationMap: map, includeZero: false)
        let expected: AssetValueMap = [:]
        XCTAssertEqual(expected, actual)
    }

    func testDifferenceWithZero() throws {
        let mapA: AssetValueMap = [foo: 0.125, bar: 0.000, baz: 0.2, bleep: 0.5]
        let mapB: AssetValueMap = [foo: 0.000, bar: 0.100, baz: 0.2, blah: 0.2]
        let actual = AssetValue.difference(mapA, mapB, includeZero: true)
        let expected: AssetValueMap = [foo: 0.125, bleep: 0.5, bar: -0.1, baz: 0.0, blah: -0.2]
        XCTAssertEqual(expected, actual)
    }

    func testDifferenceWithoutZero() throws {
        let mapA: AssetValueMap = [foo: 0.125, bar: 0.000, baz: 0.2, bleep: 0.5]
        let mapB: AssetValueMap = [foo: 0.000, bar: 0.100, baz: 0.2, blah: 0.2]
        let actual = AssetValue.difference(mapA, mapB, includeZero: false)
        let expected: AssetValueMap = [foo: 0.125, bleep: 0.5, bar: -0.1, blah: -0.2]
        XCTAssertEqual(expected, actual)
    }
}
