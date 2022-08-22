//
//  CashflowConsolidateTests.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

@testable import FlowWorthLib
import XCTest

import AllocData

import FlowBase
import ModifiedDietz

class CashflowConsolidateTests: XCTestCase {
    var df: ISO8601DateFormatter!
    var timestamp1A: Date!
    var timestamp1B: Date!
    var timestamp2: Date!
    var timestamp3: Date!
    var timestamp4: Date!
    var timestamp5: Date!
    var timestamp6: Date!
    var timestamp7: Date!
    var model: BaseModel!
    var ax: WorthContext!
    
    public typealias MD = ModifiedDietz<Double>
    
    override func setUpWithError() throws {
        df = ISO8601DateFormatter()
        timestamp1A = df.date(from: "2020-06-01T12:00:00Z")!
        timestamp1B = df.date(from: "2020-06-01T12:00:01Z")!
        timestamp2 = df.date(from: "2020-06-15T12:00:00Z")!
        timestamp3 = df.date(from: "2020-06-20T12:00:00Z")!
        timestamp4 = df.date(from: "2020-06-30T12:00:00Z")!
        timestamp5 = df.date(from: "2020-07-10T12:00:00Z")!
        timestamp6 = df.date(from: "2020-07-22T12:00:00Z")!
        timestamp7 = df.date(from: "2020-07-31T12:00:00Z")!
        model = BaseModel()
        ax = WorthContext(model)
    }
    
    func testGetBaselineMap() throws {
        let period = DateInterval(start: timestamp1A, end: timestamp4)
        let cashflow1 = MValuationCashflow(transactedAt: timestamp2, accountID: "1", assetID: "Bond", amount: 100)
        let cashflow2 = MValuationCashflow(transactedAt: timestamp3, accountID: "1", assetID: "Bond", amount: -50)
        let position1 = MValuationPosition(snapshotID: "1", accountID: "1", assetID: "Bond", totalBasis: 1, marketValue: 1900)
        let position2 = MValuationPosition(snapshotID: "2", accountID: "1", assetID: "Bond", totalBasis: 1, marketValue: 1600)
        let accountAssetKey = AccountAssetKey(accountID: "1", assetID: "Bond")
        let cashflows = [cashflow1, cashflow2]
        let netCashflow = MValuationCashflow.getNetCashflow(cashflows)
        
        let performance = -0.1809 // target performance
        let expectedBaseline = MyBaseline(period: period,
                                          performance: performance,
                                          startValue: position1.marketValue,
                                          endValue: position2.marketValue,
                                          netCashflow: netCashflow)
        
        let positionsBeg: AccountAssetPositionsMap = [accountAssetKey: [position1]]
        let positionsEnd: AccountAssetPositionsMap = [accountAssetKey: [position2]]
        let cashflowsMap: AccountAssetCashflowsMap = [accountAssetKey: cashflows]
        let actual = MValuationCashflow.getBaselineMap(period: period,
                                                       accountAssetPositionsBeg: positionsBeg,
                                                       accountAssetPositionsEnd: positionsEnd,
                                                       accountAssetCashflows: cashflowsMap)
        let expected: AccountAssetBaselineMap = [accountAssetKey: expectedBaseline]
        XCTAssertEqual(expected, actual)
    }
    
    func testConsolidateWithEmptyBaselineMapDiscardsCashflows() throws {
        let snapshot1 = MValuationSnapshot(snapshotID: "1", capturedAt: timestamp1A)
        let snapshot2 = MValuationSnapshot(snapshotID: "2", capturedAt: timestamp4)
        let cashflow1 = MValuationCashflow(transactedAt: timestamp2, accountID: "1", assetID: "Bond", amount: 100)
        let cashflow2 = MValuationCashflow(transactedAt: timestamp3, accountID: "1", assetID: "Bond", amount: -100)
        let position1 = MValuationPosition(snapshotID: "1", accountID: "1", assetID: "Bond", totalBasis: 1, marketValue: 1900)
        let position2 = MValuationPosition(snapshotID: "2", accountID: "1", assetID: "Bond", totalBasis: 1, marketValue: 1600)
        model.valuationSnapshots = [snapshot1, snapshot2]
        model.valuationCashflows = [cashflow1, cashflow2]
        model.valuationPositions = [position1, position2]
        ax = WorthContext(model)
        let emptyMap: SnapshotAccountAssetBaselineMap = [:]
        model.consolidateCashflow(snapshotBaselineMap: emptyMap, accountMap: ax.accountMap, assetMap: ax.assetMap)
        XCTAssertEqual(0, model.valuationCashflows.count)
    }
}
