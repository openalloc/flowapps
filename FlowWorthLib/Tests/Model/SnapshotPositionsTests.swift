//
//  SnapshotPositionsTests.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

@testable import FlowWorthLib
import XCTest

import AllocData

class SnapshotPositionsTests: XCTestCase {
    var df: ISO8601DateFormatter!
    var timestamp1: Date!
    var timestamp2: Date!

    override func setUpWithError() throws {
        df = ISO8601DateFormatter()
        timestamp1 = df.date(from: "2020-06-01T12:00:00Z")!
        timestamp2 = df.date(from: "2020-06-01T13:00:00Z")! // one hour later
    }
    
    func testRollUpPositions() throws {
        
        let security1 = MSecurity(securityID: "BND", assetID: "Bond", sharePrice: 20)
        let asset1 = MAsset(assetID: "Bond")
        let holding1 = MHolding(accountID: "1", securityID: "BND", lotID: "", shareCount: 3, shareBasis: 11)
        let holding2 = MHolding(accountID: "1", securityID: "BND", lotID: "", shareCount: 5, shareBasis: 13)
        let holding3 = MHolding(accountID: "1", securityID: "BND", lotID: "", shareCount: 7, shareBasis: 17)

        let securityMap = [MSecurity.Key(securityID: "BND"): security1]
        let assetMap = [MAsset.Key(assetID: "Bond"): asset1]
        let holdings = [holding1, holding2, holding3]

        let actual = MValuationPosition.createPositions(holdings: holdings,
                                                        snapshotID: "X",
                                                        securityMap: securityMap,
                                                        assetMap: assetMap)
        
        let totalShareCount: Double = 3 + 5 + 7
        let totalBasis = (3 * 11) + (5 * 13) + (7 * 17)
        //let netShareBasis = Double(totalBasis) / totalShareCount
        let marketValue = security1.sharePrice! * totalShareCount
        
        let expected = [
            MValuationPosition(snapshotID: "X", accountID: "1", assetID: "Bond", totalBasis: Double(totalBasis), marketValue: marketValue)
        ]
        
        XCTAssertEqual(expected, actual)
    }
    
    func testCreateCashPosition() throws {
        let security1 = MSecurity(securityID: "CORE", assetID: "Cash", sharePrice: 1)
        let asset1 = MAsset(assetID: "Cash")
        let holding1 = MHolding(accountID: "1", securityID: "CORE", lotID: "", shareCount: 30, shareBasis: 1)

        let securityMap = [MSecurity.Key(securityID: "CORE"): security1]
        let assetMap = [MAsset.Key(assetID: "Cash"): asset1]
        
        let actual = MValuationPosition.createPositions(holdings: [holding1],
                                                        snapshotID: "X",
                                                        securityMap: securityMap,
                                                        assetMap: assetMap)

        let expected = [
            MValuationPosition(snapshotID: "X", accountID: "1", assetID: "Cash", totalBasis: 30, marketValue: 30)
        ]
        
        XCTAssertEqual(expected, actual)
    }
}
