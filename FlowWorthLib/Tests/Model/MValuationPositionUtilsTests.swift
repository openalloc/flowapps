//
//  MValuationPositionUtilsTests.swift
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

class MValuationPositionUtilsTests: XCTestCase {
    var df: ISO8601DateFormatter!
    var timestamp: Date!

    override func setUpWithError() throws {
        df = ISO8601DateFormatter()
        timestamp = df.date(from: "2020-01-31T12:00:00Z")!
    }
    
    func testAttributes() {
        let pos = MValuationPosition(snapshotID: "XYZ", accountID: "1", assetID: "Bond", totalBasis: 20000, marketValue: 100 * 210)

        XCTAssertEqual(20000, pos.totalBasis)
        XCTAssertEqual(21000, pos.marketValue)
        XCTAssertEqual(1000, pos.unrealizedGainLoss)
    }

    func testCreateFailInvalidAccount() {
        let holding = MHolding(accountID: "", securityID: "XXX", lotID: "")
        XCTAssertThrowsError(try MValuationPosition.validate(holding: holding, securityMap: [:])) { error in
            XCTAssertEqual(error as! WorthError, WorthError.invalidAccount("in holding"))
        }
    }

    func testCreateFailMissingSecurity() {
        let holding = MHolding(accountID: "1", securityID: "XXX", lotID: "")
        XCTAssertThrowsError(try MValuationPosition.validate(holding: holding, securityMap: [:])) { error in
            XCTAssertEqual(error as! WorthError, WorthError.invalidSecurity("XXX"))
        }
    }
    
    func testCreateFailInvalidSharePrice() {
        let holding = MHolding(accountID: "1", securityID: "XXX", lotID: "")
        let security = MSecurity(securityID: "XXX")
        let securityMap = [MSecurity.Key(securityID: "xxx"): security]
        XCTAssertThrowsError(try MValuationPosition.validate(holding: holding, securityMap: securityMap)) { error in
            XCTAssertEqual(error as! WorthError, WorthError.invalidPosition("Share price must be greater than 0."))
        }
    }
    
    func testCreateFailInvalidAssetClass() {
        let holding = MHolding(accountID: "1", securityID: "XXX", lotID: "")
        let security = MSecurity(securityID: "XXX", sharePrice: 1)
        let securityMap = [MSecurity.Key(securityID: "xxx"): security]
        XCTAssertThrowsError(try MValuationPosition.validate(holding: holding, securityMap: securityMap)) { error in
            XCTAssertEqual(error as! WorthError, WorthError.invalidAssetClass("XXX"))
        }
    }

    func testCreateFailInvalidHoldingBasis() {
        let holding = MHolding(accountID: "1", securityID: "XXX", lotID: "")
        let security = MSecurity(securityID: "XXX", assetID: "Bond", sharePrice: 1)
        let securityMap = [MSecurity.Key(securityID: "xxx"): security]
        XCTAssertThrowsError(try MValuationPosition.validate(holding: holding, securityMap: securityMap)) { error in
            XCTAssertEqual(error as! WorthError, WorthError.invalidShareBasis("XXX"))
        }
    }

    func testCreateFailIfMissingSharecount() {
        let holding = MHolding(accountID: "1", securityID: "XXX", lotID: "", shareBasis: 1)
        let security = MSecurity(securityID: "XXX", assetID: "Bond", sharePrice: 1)
        let securityMap = [MSecurity.Key(securityID: "xxx"): security]
        XCTAssertThrowsError(try MValuationPosition.validate(holding: holding, securityMap: securityMap)) { error in
            XCTAssertEqual(error as! WorthError, WorthError.invalidShareCount("XXX"))
        }
    }
    
    func testCreateTolerateAnyNonNilSharecount() {
        let security = MSecurity(securityID: "XXX", assetID: "Bond", sharePrice: 1)
        let securityMap = [MSecurity.Key(securityID: "xxx"): security]
        let assetMap = [MAsset.Key(assetID: "Bond"): MAsset(assetID: "Bond")]
        for x in [-100, -1, -0.001, 0, 0.001, 1, 100] {
            let holding = MHolding(accountID: "1", securityID: "XXX", lotID: "", shareCount: x, shareBasis: 1)
            XCTAssertNoThrow(try MValuationPosition.validate(holding: holding, securityMap: securityMap))
            let expected = MValuationPosition(snapshotID: "A", accountID: "1", assetID: "Bond", totalBasis: x, marketValue: x)
            let positions = MValuationPosition.createPositions(holdings: [holding], snapshotID: "A", securityMap: securityMap, assetMap: assetMap)
            XCTAssertEqual(1, positions.count)
            XCTAssertEqual([expected], positions)
        }
    }
    
    func testGetFilteredPositions() {
        let pos1 = MValuationPosition(snapshotID: "XYZ", accountID: "1", assetID: "Bond", totalBasis: 1, marketValue: 1)
        let pos2 = MValuationPosition(snapshotID: "XYZ", accountID: "2", assetID: "Bond", totalBasis: 1, marketValue: 1)
        let pos3 = MValuationPosition(snapshotID: "XYZ", accountID: "1", assetID: "LC", totalBasis: 1, marketValue: 1)
        let pos4 = MValuationPosition(snapshotID: "XYZ", accountID: "2", assetID: "LC", totalBasis: 1, marketValue: 1)
        let pos5 = MValuationPosition(snapshotID: "ABC", accountID: "1", assetID: "Bond", totalBasis: 1, marketValue: 1)
        let pos6 = MValuationPosition(snapshotID: "ABC", accountID: "1", assetID: "LC", totalBasis: 1, marketValue: 1)
        
        var model = BaseModel()
        model.valuationPositions = [pos1, pos2, pos3, pos4, pos5, pos6]
        
        var map = AccountFilteredMap()
        let actual1 = MValuationPosition.getPositions(rawPositions: model.valuationPositions, snapshotKeySet: [MValuationSnapshot.Key(snapshotID: "xyz")], accountKeyFilter: { $0 == MAccount.Key(accountID: "1") }, accountFilteredMap: &map)
        let expected1 = [pos1, pos3]
        XCTAssertEqual(expected1, actual1)
        XCTAssertEqual([MAccount.Key(accountID: "1"): true, MAccount.Key(accountID: "2"): false], map)

        map.removeAll()
        let actual2 = MValuationPosition.getPositions(rawPositions: model.valuationPositions, snapshotKeySet: [MValuationSnapshot.Key(snapshotID: "xyz"), MValuationSnapshot.Key(snapshotID: "abc")], accountKeyFilter: { $0 == MAccount.Key(accountID: "1") }, accountFilteredMap: &map)
        let expected2 = [pos1, pos3, pos5, pos6]
        XCTAssertEqual(expected2, actual2)
        XCTAssertEqual([MAccount.Key(accountID: "1"): true, MAccount.Key(accountID: "2"): false], map)

        map.removeAll()
        let actual3 = MValuationPosition.getPositions(rawPositions: model.valuationPositions, snapshotKeySet: [MValuationSnapshot.Key(snapshotID: "xyz")], accountKeyFilter: { $0 == MAccount.Key(accountID: "2") }, accountFilteredMap: &map)
        let expected3 = [pos2, pos4]
        XCTAssertEqual(expected3, actual3)
        XCTAssertEqual([MAccount.Key(accountID: "1"): false, MAccount.Key(accountID: "2"): true], map)
    }
}
