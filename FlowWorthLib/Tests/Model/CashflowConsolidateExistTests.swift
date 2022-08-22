//
//  CashflowConsolidateExistTests.swift
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

class CashflowConsolidateExistTests: XCTestCase {
    var df: ISO8601DateFormatter!
    var timestamp1: Date!
    var timestamp4: Date!
    var model: BaseModel!
    var ax: WorthContext!
    
    public typealias MD = ModifiedDietz<Double>
    
    override func setUpWithError() throws {
        df = ISO8601DateFormatter()
        timestamp1 = df.date(from: "2020-06-01T12:00:00Z")!
        timestamp4 = df.date(from: "2020-06-30T12:00:00Z")!
        model = BaseModel()
        ax = WorthContext(model)
    }
    
    func testFindNoneForEmpty() {
        XCTAssertFalse(MValuationCashflow.consolidateCandidatesExist(ax))
    }
    
    func testFindNoneForAlreadyConsolidated() {
        let snapshot1 = MValuationSnapshot(snapshotID: "1", capturedAt: timestamp1)
        let snapshot2 = MValuationSnapshot(snapshotID: "2", capturedAt: timestamp4)
        let cashflow1 = MValuationCashflow(transactedAt: timestamp4, accountID: "1", assetID: "Bond", amount: 1)
        let cashflow2 = MValuationCashflow(transactedAt: timestamp4, accountID: "1", assetID: "Equities", amount: 1)
        model.valuationSnapshots = [snapshot1, snapshot2]
        model.valuationCashflows = [cashflow1, cashflow2]
        ax = WorthContext(model)
        
        XCTAssertFalse(MValuationCashflow.consolidateCandidatesExist(ax))
    }
    
    func testFindOneForUnconsolidated() {
        let snapshot1 = MValuationSnapshot(snapshotID: "1", capturedAt: timestamp1)
        let snapshot2 = MValuationSnapshot(snapshotID: "2", capturedAt: timestamp4)
        let cashflow1 = MValuationCashflow(transactedAt: timestamp4, accountID: "1", assetID: "Bond", amount: 1)
        let cashflow2 = MValuationCashflow(transactedAt: timestamp4, accountID: "1", assetID: "Bond", amount: 1)
        model.valuationSnapshots = [snapshot1, snapshot2]
        model.valuationCashflows = [cashflow1, cashflow2]
        ax = WorthContext(model)
        
        XCTAssertTrue(MValuationCashflow.consolidateCandidatesExist(ax))
    }
}
