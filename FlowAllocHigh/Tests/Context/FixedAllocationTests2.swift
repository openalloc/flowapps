//
//  FixedAllocationTests2.swift
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
import FlowXCT

@testable import FlowAllocHigh

class FixedAllocationTests2: XCTestCase {
    var sBNDX: MSecurity!
    var sCASH: MSecurity!
    var sCORE: MSecurity!
    var sDBC: MSecurity!
    var sFBIQC: MSecurity!
    var sFFIQC: MSecurity!
    var sFTMJC: MSecurity!
    var sFZDXX: MSecurity!
    var sIAU: MSecurity!
    var sIEF: MSecurity!
    var sSCZ: MSecurity!
    var sSPAXX: MSecurity!
    var sSPY: MSecurity!
    var sTLT: MSecurity!
    var sVEA: MSecurity!
    var sVGK: MSecurity!
    var sVPL: MSecurity!
    var sVTI: MSecurity!
    var sVWO: MSecurity!

    var acBondIntl: AssetKey!
    var acBonds: AssetKey!
    var acCASH: AssetKey!
    var acCommodities: AssetKey!
    var acEM: AssetKey!
    var acEur: AssetKey!
    var acGold: AssetKey!
    var acIntl: AssetKey!
    var acIntlSC: AssetKey!
    var acLC: AssetKey!
    var acPac: AssetKey!
    var acTIT: AssetKey!
    var acTLT: AssetKey!
    var acTM: AssetKey!

    var relatedTree: AssetKeyTree!

    var targetAlloc: [AssetKey: Double]!
    var fixedHoldingsRaw: [MHolding]!
    var otherHoldings: [MHolding]!
    var otherACs: [AssetKey]!
    var securityMap: SecurityMap!
    var allHoldings: [MHolding]!

    override func setUp() {
        super.setUp()

        acBondIntl = MAsset.Key(assetID: "international bonds")
        acBonds = MAsset.Key(assetID: "aggregate bonds")
        acCASH = MAsset.Key(assetID: "Cash")
        acCommodities = MAsset.Key(assetID: "commodities")
        acEM = MAsset.Key(assetID: "emerging markets")
        acEur = MAsset.Key(assetID: "europe")
        acGold = MAsset.Key(assetID: "Gold")
        acIntl = MAsset.Key(assetID: "intl equities")
        acIntlSC = MAsset.Key(assetID: "intl small cap")
        acLC = MAsset.Key(assetID: "s&p 500")
        acPac = MAsset.Key(assetID: "pacific")
        acTIT = MAsset.Key(assetID: "it treasuries")
        acTLT = MAsset.Key(assetID: "lt treasuries")
        acTM = MAsset.Key(assetID: "us total market")

        relatedTree = AssetKeyTree(value: Relations.rootAssetKey)

        _ = relatedTree.addChild(value: acBondIntl)
        _ = relatedTree.addChild(value: acTLT)

        let b = relatedTree.addChild(value: acBonds)
        _ = b.addChild(value: acTIT)

        let c = relatedTree.addChild(value: acCASH)
        _ = c.addChild(value: acCommodities)

        let intl = relatedTree.addChild(value: acIntl)
        _ = intl.addChild(value: acEM)
        _ = intl.addChild(value: acEur)
        _ = intl.addChild(value: acIntlSC)
        _ = intl.addChild(value: acPac)

        let tm = relatedTree.addChild(value: acTM)
        _ = tm.addChild(value: acLC)

        targetAlloc = [
            acCASH!: 0.149,
            acTIT!: 0.150,
            acIntl!: 0.119,
            acLC!: 0.202,
            acTLT!: 0.048,
            acCommodities!: 0.121,
            acIntlSC!: 0.182,
            acGold!: 0.029,
        ]

        sBNDX = MSecurity(securityID: "BNDX", assetID: acBondIntl.assetNormID, sharePrice: 1)
        sCASH = MSecurity(securityID: "CASH", assetID: acCASH.assetNormID, sharePrice: 1)
        sCORE = MSecurity(securityID: "CORE", assetID: acCASH.assetNormID, sharePrice: 1)
        sDBC = MSecurity(securityID: "DBC", assetID: acCommodities.assetNormID, sharePrice: 1)
        sFBIQC = MSecurity(securityID: "FBIQC", assetID: acBonds.assetNormID, sharePrice: 1)
        sFFIQC = MSecurity(securityID: "FFIQC", assetID: acIntl.assetNormID, sharePrice: 1)
        sFTMJC = MSecurity(securityID: "FTMJC", assetID: acTM.assetNormID, sharePrice: 1)
        sFZDXX = MSecurity(securityID: "FZDXX", assetID: acCASH.assetNormID, sharePrice: 1)
        sIAU = MSecurity(securityID: "IAU", assetID: acGold.assetNormID, sharePrice: 1)
        sIEF = MSecurity(securityID: "IEF", assetID: acTIT.assetNormID, sharePrice: 1)
        sSCZ = MSecurity(securityID: "SCZ", assetID: acIntlSC.assetNormID, sharePrice: 1)
        sSPAXX = MSecurity(securityID: "SPAX", assetID: acCASH.assetNormID, sharePrice: 1)
        sSPY = MSecurity(securityID: "SPY", assetID: acLC.assetNormID, sharePrice: 1)
        sTLT = MSecurity(securityID: "TLT", assetID: acTLT.assetNormID, sharePrice: 1)
        sVEA = MSecurity(securityID: "VEA", assetID: acIntl.assetNormID, sharePrice: 1)
        sVGK = MSecurity(securityID: "VGK", assetID: acEur.assetNormID, sharePrice: 1)
        sVPL = MSecurity(securityID: "VPL", assetID: acPac.assetNormID, sharePrice: 1)
        sVTI = MSecurity(securityID: "VTI", assetID: acTM.assetNormID, sharePrice: 1)
        sVWO = MSecurity(securityID: "VWO", assetID: acEM.assetNormID, sharePrice: 1)

        let securities = [
            sBNDX!,
            sCASH!,
            sCORE!,
            sDBC!,
            sFBIQC!,
            sFFIQC!,
            sFTMJC!,
            sFZDXX!,
            sIAU!,
            sIEF!,
            sSCZ!,
            sSPAXX!,
            sSPY!,
            sTLT!,
            sVEA!,
            sVGK!,
            sVPL!,
            sVTI!,
            sVWO!,
        ]

        securityMap = MSecurity.makeAllocMap(securities)

        fixedHoldingsRaw = [
            MHolding(accountID: "1", securityID: sBNDX.securityID, lotID: "", shareCount: 55611.90, shareBasis: 1),
            MHolding(accountID: "1", securityID: sCORE.securityID, lotID: "", shareCount: 115_199.99, shareBasis: 1),
            MHolding(accountID: "1", securityID: sFBIQC.securityID, lotID: "", shareCount: 66446.41, shareBasis: 1),
            MHolding(accountID: "1", securityID: sFFIQC.securityID, lotID: "", shareCount: 66960.51, shareBasis: 1),
            MHolding(accountID: "1", securityID: sFTMJC.securityID, lotID: "", shareCount: 66960.51, shareBasis: 1),
            MHolding(accountID: "1", securityID: sFZDXX.securityID, lotID: "", shareCount: 124_137.18, shareBasis: 1),
            MHolding(accountID: "1", securityID: sSPAXX.securityID, lotID: "", shareCount: 43.61, shareBasis: 1),
            MHolding(accountID: "1", securityID: sVGK.securityID, lotID: "", shareCount: 46840.95, shareBasis: 1),
            MHolding(accountID: "1", securityID: sVPL.securityID, lotID: "", shareCount: 49029.58, shareBasis: 1),
            MHolding(accountID: "1", securityID: sVTI.securityID, lotID: "", shareCount: 133_757.23, shareBasis: 1),
            MHolding(accountID: "1", securityID: sVWO.securityID, lotID: "", shareCount: 49231.00, shareBasis: 1),
        ]

        otherHoldings = [
            MHolding(accountID: "1", securityID: sDBC.securityID, lotID: "", shareCount: 204_000, shareBasis: 1),
            MHolding(accountID: "1", securityID: sIAU.securityID, lotID: "", shareCount: 49000, shareBasis: 1),
            MHolding(accountID: "1", securityID: sSCZ.securityID, lotID: "", shareCount: 307_000, shareBasis: 1),
            MHolding(accountID: "1", securityID: sTLT.securityID, lotID: "", shareCount: 81000, shareBasis: 1),
        ]

        otherACs = [] // otherHoldings.map(\<#Root#>.security.assetID)

        allHoldings = fixedHoldingsRaw + otherHoldings
    }

    func testGetRelatedMap() throws {
        let fixedACs = MHolding.getAssetKeys(fixedHoldingsRaw, securityMap: securityMap)
        let targetACs = Set(targetAlloc.keys)

        let rankedTargetsMap = Relations.getRawRankedTargetsMap(heldAssetKeySet: Set(fixedACs), targetAssetKeySet: targetACs, relatedTree: relatedTree)
        
        let actual = Relations.getTopRankedTargetMap(rankedTargetsMap: rankedTargetsMap)
        
        let expected: [AssetKey: AssetKey] = [
            acBonds: acTIT,
            acEM: acIntl,
            acEur: acIntl,
            acPac: acIntl,
            acTM: acLC,
            acIntl: acIntl,
            acCASH: acCASH,
        ]

        XCTAssertEqual(expected, actual)
    }

    func testGetDistilledAssets() throws {
        let targetACs = Set(targetAlloc.keys)
        let fixedACs = MHolding.getAssetKeys(fixedHoldingsRaw, securityMap: securityMap)
        let rankedTargetsMap = Relations.getRawRankedTargetsMap(heldAssetKeySet: Set(fixedACs), targetAssetKeySet: targetACs, relatedTree: relatedTree)
        let topRankedMap = Relations.getTopRankedTargetMap(rankedTargetsMap: rankedTargetsMap)
        let result = Relations.getDistilledMap(fixedHoldingsRaw, topRankedTargetMap: topRankedMap, securityMap: securityMap)
        
        let actual = Set(result.accepted.map(\.key))

        let expected = Set([
            acCASH,
            acTIT,
            acIntl,
            acLC,
        ])

        XCTAssertEqual(expected, actual)
        XCTAssertEqual(1, result.rejected.count)
        XCTAssertEqual("BNDX", result.rejected[acBondIntl]?.first?.securityID)
    }

    func testGetDistilledHoldings() throws {
        let targetACs = Set(targetAlloc.keys)
        let fixedACs = MHolding.getAssetKeys(fixedHoldingsRaw, securityMap: securityMap)
        let rankedTargetsMap = Relations.getRawRankedTargetsMap(heldAssetKeySet: Set(fixedACs), targetAssetKeySet: targetACs, relatedTree: relatedTree)
        let topRankedMap = Relations.getTopRankedTargetMap(rankedTargetsMap: rankedTargetsMap)
        let result = Relations.getDistilledMap(fixedHoldingsRaw, topRankedTargetMap: topRankedMap, securityMap: securityMap)

        let expected: AssetHoldingsMap = [
            acCASH: [
                MHolding(accountID: "1", securityID: sCORE.securityID, lotID: "", shareCount: 115_199.99, shareBasis: 1),
                MHolding(accountID: "1", securityID: sFZDXX.securityID, lotID: "", shareCount: 124_137.18, shareBasis: 1),
                MHolding(accountID: "1", securityID: sSPAXX.securityID, lotID: "", shareCount: 43.61, shareBasis: 1),
            ],
            acTIT: [
                MHolding(accountID: "1", securityID: sFBIQC.securityID, lotID: "", shareCount: 66446.41, shareBasis: 1),
            ],
            acIntl: [
                MHolding(accountID: "1", securityID: sFFIQC.securityID, lotID: "", shareCount: 66960.51, shareBasis: 1),
                MHolding(accountID: "1", securityID: sVGK.securityID, lotID: "", shareCount: 46840.95, shareBasis: 1),
                MHolding(accountID: "1", securityID: sVPL.securityID, lotID: "", shareCount: 49029.58, shareBasis: 1),
                MHolding(accountID: "1", securityID: sVWO.securityID, lotID: "", shareCount: 49231.00, shareBasis: 1),
            ],
            acLC: [
                MHolding(accountID: "1", securityID: sFTMJC.securityID, lotID: "", shareCount: 66960.51, shareBasis: 1),
                MHolding(accountID: "1", securityID: sVTI.securityID, lotID: "", shareCount: 133_757.23, shareBasis: 1),
            ],
        ]

        XCTAssertEqual(expected, result.accepted)
        XCTAssertEqual(1, result.rejected.count)
        XCTAssertEqual("BNDX", result.rejected[acBondIntl]?.first?.securityID)
    }

    func testRawFixedSum() throws {
        let summary = HoldingsSummary.getSummary(fixedHoldingsRaw, securityMap)
        let actual = summary.presentValue
        let expected = 774_218.87
        XCTAssertEqual(expected, actual, accuracy: 0.001)
    }

    func testGetDistilledHoldingsSum() throws {
        let targetACs = Set(targetAlloc.keys)
        let fixedACs = MHolding.getAssetKeys(fixedHoldingsRaw, securityMap: securityMap)
        let rankedTargetsMap = Relations.getRawRankedTargetsMap(heldAssetKeySet: Set(fixedACs), targetAssetKeySet: targetACs, relatedTree: relatedTree)
        let topRankedMap = Relations.getTopRankedTargetMap(rankedTargetsMap: rankedTargetsMap)
        let result = Relations.getDistilledMap(fixedHoldingsRaw, topRankedTargetMap: topRankedMap, securityMap: securityMap)
        let summary = HoldingsSummary.getSummary(result.accepted, securityMap)
        let actual = summary.presentValue
        let expected = 718_606.97
        XCTAssertEqual(expected, actual, accuracy: 0.001)
        XCTAssertEqual(1, result.rejected.count)
        XCTAssertEqual("BNDX", result.rejected[acBondIntl]?.first?.securityID)
    }

    // constrain contributions to match a target allocation
    //
    //  e.g., with a source of
    //                      $1000 of equities,
    //                      $1000 of bonds, and
    //                      $1000 of gold
    //
    //  A target allocation of 60% equities and 40% bonds
    //
    //  Return [ equities: $1000, bonds: $667 ]
    //
    func testGetFixedContrib() throws {
        let sourceAmountMap: AssetValueMap = [
            acCASH!: 239_380.79,
            acTIT!: 66466.41,
            acIntl!: 212_062.04,
            acLC!: 200_717.74,
        ]

        let expected: AssetValueMap = [
            acCASH!: 107_075.42,
            acTIT!: 66466.41,
            acIntl!: 85516.61,
            acLC!: 145_162.65,
        ]

        let actual = getFixedContribMap(combinedContribMap: sourceAmountMap, fixedValueMap: expected)
        XCTAssertEqual(expected, actual)
    }

    func testGetTacticalTotal() throws {
        let targetACs = Set(targetAlloc.keys)
        let fixedACs = MHolding.getAssetKeys(fixedHoldingsRaw, securityMap: securityMap)
        let fixedRawHoldingsMap = MHolding.getAssetHoldingsMap(fixedHoldingsRaw, securityMap)
        let fixedRawValueMap = MHolding.getPresentValueMap(holdingsMap: fixedRawHoldingsMap, securityMap: securityMap)

        let rankedTargetsMap = Relations.getRawRankedTargetsMap(heldAssetKeySet: Set(fixedACs), targetAssetKeySet: targetACs, relatedTree: relatedTree)
        let topRankedMap = Relations.getTopRankedTargetMap(rankedTargetsMap: rankedTargetsMap)
        let result = Relations.getDistilledMap(fixedHoldingsRaw, topRankedTargetMap: topRankedMap, securityMap: securityMap)
        XCTAssertEqual(1, result.rejected.count)
        XCTAssertEqual("BNDX", result.rejected[acBondIntl]?.first?.securityID)

        let distilledAmountsMap = MHolding.getPresentValueMap(holdingsMap: result.accepted, securityMap: securityMap)

        let netVariableTotal = HoldingsSummary.getSummary(otherHoldings, securityMap).presentValue
        XCTAssertEqual(641_000, netVariableTotal, accuracy: 0.01)

        // the most that can be contributed into each asset class from fixed and variable accounts
        let netTotal = getNetCombinedTotal(fixedValueMap: distilledAmountsMap,
                                           variableContribTotal: netVariableTotal,
                                           netAllocMap: targetAlloc)

        XCTAssertEqual(1_240_661.44, netTotal, accuracy: 0.01)

        let netAssetAmountMap = AssetValue.distribute(value: netTotal, allocationMap: targetAlloc)
        let norm = try AssetValue.normalize(netAssetAmountMap)
        XCTAssertEqual(targetAlloc, norm, accuracy: 0.001)

        let fixedContribMap = getFixedContribMap(combinedContribMap: netAssetAmountMap, fixedValueMap: fixedRawValueMap)

        let fixedContribTotal = AssetValue.sumOf(fixedContribMap)
        XCTAssertEqual(251_819.07, fixedContribTotal, accuracy: 0.01)

        let rawCombinedContribTotal = AssetValue.sumOf(netAssetAmountMap)
        XCTAssertEqual(1_240_661.44, rawCombinedContribTotal, accuracy: 0.01)

        let netCombinedContribTotal = netVariableTotal + fixedContribTotal
        XCTAssertEqual(892_819.07, netCombinedContribTotal, accuracy: 0.01)
    }
}
