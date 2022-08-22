//
//  RollupTests.swift
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

class RollupTests: XCTestCase {
    let acFoo = MAsset.Key(assetID: "foo")
    let acBar = MAsset.Key(assetID: "bar")
    let acBaz = MAsset.Key(assetID: "baz")
    let acBlah = MAsset.Key(assetID: "blah")
    let acLCBlend  = MAsset.Key(assetID: "LC Blend")
    let acLCValue  = MAsset.Key(assetID: "LC Value")
    let acLCGrowth = MAsset.Key(assetID: "LC Growth")
    let acSmallCap = MAsset.Key(assetID: "Small Cap")
    let acSCGrowth = MAsset.Key(assetID: "SC Growth")
    let acSCValue  = MAsset.Key(assetID: "SC Value")
    let acMicrocap = MAsset.Key(assetID: "Microcap")
    let acGold     = MAsset.Key(assetID: "Gold")
    let acROOT     = MAsset.Key(assetID: "ROOT")
    let acBond     = MAsset.Key(assetID: "Bond")
    let acIntl     = MAsset.Key(assetID: "Intl")
    let acLC     = MAsset.Key(assetID: "LC")
    let acLCVal     = MAsset.Key(assetID: "LCVal")
    let acSC     = MAsset.Key(assetID: "SC")
    let acSCVal     = MAsset.Key(assetID: "SCVal")
    let acRE     = MAsset.Key(assetID: "RE")
    
    func testScrubSlices() throws {
        let slices = [acFoo: 1.0001000002]

        let nuSlices = try AssetValue.normalize(slices)

        XCTAssertEqual(nuSlices[acFoo]!, 1.0, accuracy: 0.0001)
    }

    func testValidateSum() throws {
        let slices = [acFoo: 0.999]
        XCTAssertThrowsError(try AssetValue.validateAllocMap(slices)) { error in
            XCTAssertEqual(error as! FlowBaseError, FlowBaseError.validationFailure("Sum of slices must be 1."))
        }
    }

    func testMissingAssetClass() throws {
        let foo = SimpleTree<AssetKey>(value: acFoo)
        let bar = foo.addChild(value: acBar)
        _ = bar.addChild(value: acBaz)

        let slices1 = [acFoo: 1.0]
        XCTAssertNoThrow(try rollup(foo, slices1))
        let slices2 = [acBar: 1.0]
        XCTAssertNoThrow(try rollup(foo, slices2))
        let slices3 = [acBaz: 1.0]
        XCTAssertNoThrow(try rollup(foo, slices3))

        let slices4 = [acBaz: 0.5,
                       acBlah: 0.5]
        XCTAssertThrowsError(try rollup(foo, slices4)) { error in
            XCTAssertEqual(error as! FlowBaseError, FlowBaseError.validationFailure("Asset class not found (rollup)."))
        }
    }

    func testDuplicateAssetClass() throws {
        let foo = SimpleTree<AssetKey>(value: acFoo)
        let bar = foo.addChild(value: acBar)
        _ = bar.addChild(value: acFoo)

        let slices = [acBar: 1.0]
        XCTAssertThrowsError(try rollup(foo, slices)) { error in
            XCTAssertEqual(error as! FlowBaseError, FlowBaseError.validationFailure("Duplicate asset class found."))
        }
    }

    func testRollupOne() throws {
        let lc = SimpleTree<AssetKey>(value: acLCBlend)
        _ = lc.addChild(value: acLCValue)
        let sc = lc.addChild(value: acSmallCap)
        _ = sc.addChild(value: acSCGrowth)

        let slices = [
            acSmallCap: 0.2, // does NOT increase above threshold
            acLCBlend: 0.5,
            acSCGrowth: 0.3,
        ]

        let (nuSlices, rollupMap) = try rollup(lc, slices, threshold: 0.25)

        XCTAssertEqual(nuSlices, [acLCBlend: 0.7, acSCGrowth: 0.3])
        XCTAssertEqual(rollupMap, [acLCBlend: [acSmallCap]])
    }

    func testRollupWithIncreaseAboveThreshold() throws {
        let lc = SimpleTree<AssetKey>(value: acLCBlend)
        _ = lc.addChild(value: acLCValue)
        _ = lc.addChild(value: acLCGrowth)
        let sc = lc.addChild(value: acSmallCap)
        _ = sc.addChild(value: acSCGrowth)
        _ = sc.addChild(value: acSCValue)
        _ = sc.addChild(value: acMicrocap)

        let slices = [
            acSmallCap: 0.2, // increases above threshold
            acSCValue: 0.05, // goes into Small Cap
            acLCBlend: 0.5,
            acSCGrowth: 0.1, // goes into Small Cap
            acMicrocap: 0.05, // goes into Small Cap
            acLCGrowth: 0.1, // goes into LC Blend
        ]

        let (nuSlices, rollupMap) = try rollup(lc, slices, threshold: 0.19) // 0.01 less than small cap to prevent it rolling into lc

        XCTAssertEqual(nuSlices, [acLCBlend: 0.6, acSmallCap: 0.4])
        XCTAssertEqual(rollupMap, [acLCBlend: [acLCGrowth], acSmallCap: [acMicrocap, acSCValue, acSCGrowth]])
    }

    func testRollupWithoutIncreaseAboveThreshold() throws {
        let root = SimpleTree<AssetKey>(value: acROOT)
        _ = root.addChild(value: acLCBlend)
        _ = root.addChild(value: acGold)

        let slices = [
            acLCBlend: 0.9,
            acGold: 0.1,
        ]

        let (nuSlices, rollupMap) = try rollup(root, slices, threshold: 0.25)

        XCTAssertEqual(nuSlices, [acLCBlend: 0.9, acGold: 0.1])
        XCTAssertEqual(rollupMap, [:])
    }

    func testExcludeRoot() throws {
        let root = SimpleTree<AssetKey>(value: acROOT)
        _ = root.addChild(value: acFoo)
        _ = root.addChild(value: acBar)
        _ = root.addChild(value: acBaz)

        let slices = [
            acFoo: 0.334,
            acBar: 0.333,
            acBaz: 0.333,
        ]

        let (nuSlices, rollupMap) = try rollup(root, slices, threshold: 0.4)

        XCTAssertEqual(nuSlices, [acFoo: 0.334, acBar: 0.333, acBaz: 0.333])
        XCTAssertEqual(rollupMap, [:])
    }

    func testCoffee() throws {
        let root = SimpleTree<AssetKey>(value: acROOT)
        let lc = root.addChild(value: acLC)
        _ = lc.addChild(value: acLCVal)
        _ = lc.addChild(value: acRE)
        let sc = lc.addChild(value: acSC)
        _ = sc.addChild(value: acSCVal)
        _ = root.addChild(value: acIntl)
        _ = root.addChild(value: acBond)

        let slices = [
            acBond: 0.40,
            acIntl: 0.10,
            acLC: 0.10,
            acLCVal: 0.10,
            acSC: 0.10,
            acSCVal: 0.10,
            acRE: 0.10,
        ]

        for _ in 0 ..< 100 {
            let (nuSlices, rollupMap) = try rollup(root, slices, threshold: 0.09999)
            let expectedSlices: AssetValueMap = [acBond: 0.4, acIntl: 0.1, acLC: 0.5]
            let expectedRollup: RollupMap = [acLC: [acLCVal, acRE, acSC, acSCVal]]
            XCTAssertEqual(expectedSlices, nuSlices)
            XCTAssertEqual(expectedRollup, rollupMap)
        }
    }
}
