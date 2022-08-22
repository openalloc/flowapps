//
//  DeepRelationsTests.swift
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

class DeepRelationsTests: XCTestCase {
    var bond: AssetKey!
    var sc: AssetKey!
    var scv: AssetKey!
    var mc: AssetKey!
    var tm: AssetKey!

    var root: SimpleTree<AssetKey>!

    override func setUp() {
        bond = MAsset.Key(assetID: "Bond")
        sc = MAsset.Key(assetID: "sc")
        scv = MAsset.Key(assetID: "scv")
        mc = MAsset.Key(assetID: "mc")
        tm = MAsset.Key(assetID: "tm")

        root = SimpleTree<AssetKey>(value: Relations.rootAssetKey)
        _ = root.addChild(value: bond)
        let tm_ = root.addChild(value: tm)
        let sc_ = tm_.addChild(value: sc)
        _ = sc_.addChild(value: scv)
        _ = sc_.addChild(value: mc)
    }

    func testUnfilteredAll() throws {
        let filterACs = AssetKeySet([sc, scv, mc, tm, bond])

        let expected = [sc: [sc, tm, scv, mc],
                        scv: [scv, sc, tm],
                        tm: [tm, sc, scv, mc],
                        mc: [mc, sc, tm],
                        bond: [bond]]

        let actual = Relations.getRawRankedTargetsMap(heldAssetKeySet: filterACs, targetAssetKeySet: filterACs, relatedTree: root)

        XCTAssertEqual(expected, actual)
    }

    func testBondsOnly() throws {
        let filterACs = AssetKeySet([bond])

        let expected = [bond: [bond]]

        let actual = Relations.getRawRankedTargetsMap(heldAssetKeySet: filterACs, targetAssetKeySet: filterACs, relatedTree: root)

        XCTAssertEqual(expected, actual)
    }

    func testNoSCV() throws {
        let filterACs = AssetKeySet([sc, mc, tm])

        let expected = [sc: [sc, tm, mc],
                        tm: [tm, sc, mc],
                        mc: [mc, sc, tm]]

        let actual = Relations.getRawRankedTargetsMap(heldAssetKeySet: filterACs, targetAssetKeySet: filterACs, relatedTree: root)

        XCTAssertEqual(expected, actual)
    }

    func testOnlyTM() throws {
        let filterACs = AssetKeySet([tm])

        let expected = [tm: [tm]]
        
        let actual = Relations.getRawRankedTargetsMap(heldAssetKeySet: filterACs, targetAssetKeySet: filterACs, relatedTree: root)
        
        XCTAssertEqual(expected, actual)
    }

    func testOnlySCandTM() throws {
        let filterACs = AssetKeySet([sc, tm])

        let expected = [
            sc: [sc, tm],
            tm: [tm, sc],
        ]

        let actual = Relations.getRawRankedTargetsMap(heldAssetKeySet: filterACs, targetAssetKeySet: filterACs, relatedTree: root)
        
        XCTAssertEqual(expected, actual)
    }

    func testOnlySCVandTM() throws {
        let filterACs = AssetKeySet([scv, tm])

        let expected = [scv: [scv, tm],
                        tm: [tm, scv]]

        let actual = Relations.getRawRankedTargetsMap(heldAssetKeySet: filterACs, targetAssetKeySet: filterACs, relatedTree: root)
        
        XCTAssertEqual(expected, actual)
    }

    func testMCandSCVandSC() throws {
        let filterACs = AssetKeySet([mc, scv, sc])

        let expected = [sc: [sc, scv, mc],
                        mc: [mc, sc],
                        scv: [scv, sc]]

        let actual = Relations.getRawRankedTargetsMap(heldAssetKeySet: filterACs, targetAssetKeySet: filterACs, relatedTree: root)
        
        XCTAssertEqual(expected, actual)
    }

    func testFilterSCVandMCSiblings() throws {
        let filterACs = AssetKeySet([scv, mc])

        let expected = [scv: [scv],
                        mc: [mc]]
        
        let actual = Relations.getRawRankedTargetsMap(heldAssetKeySet: filterACs, targetAssetKeySet: filterACs, relatedTree: root)
        
        XCTAssertEqual(expected, actual)
    }
}
