//
//  MValuationPositionMapTests.swift
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

import FlowBase

class MValuationPositionMapTests: XCTestCase {
    var df: ISO8601DateFormatter!
    var timestamp: Date!

    override func setUpWithError() throws {
        df = ISO8601DateFormatter()
        timestamp = df.date(from: "2020-01-31T12:00:00Z")!
    }
    
    func testGetPositionShareDiff() {
        let p1 = MValuationPosition(snapshotID: "X", accountID: "1", assetID: "Bond", totalBasis: 3, marketValue: 7 * 1)
        let p2 = MValuationPosition(snapshotID: "X", accountID: "1", assetID: "Bond", totalBasis: 5, marketValue: 13 * 1)
        let p3 = MValuationPosition(snapshotID: "X", accountID: "1", assetID: "Bond", totalBasis: 7, marketValue: 17 * 1)
        let p4 = MValuationPosition(snapshotID: "X", accountID: "1", assetID: "Bond", totalBasis: 9, marketValue: 19 * 1)

        let actual = MValuationPosition.getBasisMap(begPositions: [p1, p2], endPositions: [p3, p4])
        let expected: AccountAssetValueMap = [AccountAssetKey(accountID: "1", assetID: "Bond"): -1 * ((7) + (-13)) + ((-17) + (19))]
        
        XCTAssertEqual(expected, actual)
    }
}
