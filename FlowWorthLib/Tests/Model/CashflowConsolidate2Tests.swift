//
//  CashflowConsolidate2Tests.swift
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

class CashflowConsolidate2Tests: XCTestCase {
    
    public typealias MD = ModifiedDietz<Double>
    
    var df: ISO8601DateFormatter!
    var timestamp1A: Date!
    var timestamp1B: Date!
    var timestamp2: Date!
    var timestamp3: Date!
    var timestamp4: Date!
    var model: BaseModel!
    var ax: WorthContext!
    
    var snapshot1: MValuationSnapshot!
    var snapshot2: MValuationSnapshot!
    var cashflow1: MValuationCashflow!
    var cashflow2: MValuationCashflow!
    var position1: MValuationPosition!
    var position2: MValuationPosition!
    var accountAssetKey: AccountAssetKey!
    var period2: DateInterval!
    var cf2: [MValuationCashflow]!
    var cfm2: [Date: Double]!
    var ncf2: Double = 0
    var md2: MD!
    var expected2: MyBaseline!
    var snapshotBaselineMap: SnapshotAccountAssetBaselineMap!
    var mdPre: MD!
    var mdPost: MD!
    
    override func setUpWithError() throws {
        df = ISO8601DateFormatter()
        timestamp1A = df.date(from: "2020-06-01T12:00:00Z")!
        timestamp1B = df.date(from: "2020-06-01T12:00:01Z")!
        timestamp2 = df.date(from: "2020-06-15T12:00:00Z")!
        timestamp3 = df.date(from: "2020-06-20T12:00:00Z")!
        timestamp4 = df.date(from: "2020-06-30T12:00:00Z")!
        model = BaseModel()
        ax = WorthContext(model)
        
        snapshot1 = MValuationSnapshot(snapshotID: "1", capturedAt: timestamp1A)
        snapshot2 = MValuationSnapshot(snapshotID: "2", capturedAt: timestamp4)
        position1 = MValuationPosition(snapshotID: "1", accountID: "1", assetID: "Bond", totalBasis: 1, marketValue: 1900)
        position2 = MValuationPosition(snapshotID: "2", accountID: "1", assetID: "Bond", totalBasis: 1, marketValue: 1600)
        
        accountAssetKey = AccountAssetKey(accountID: "1", assetID: "Bond")
        period2 = DateInterval(start: timestamp1A, end: timestamp4)
        cf2 = []
        cfm2 = [:]
        ncf2 = 0
        snapshotBaselineMap = [:]
    }
    
    func preConsolidateSetup() {
        model.valuationSnapshots = [snapshot1, snapshot2]
        model.valuationCashflows = [cashflow1, cashflow2]
        model.valuationPositions = [position1, position2]
        ax = WorthContext(model)
        
        cf2 = [cashflow1, cashflow2]
        cfm2 = MValuationCashflow.getCashflowMap(cf2)
        ncf2 = MValuationCashflow.getNetCashflow(cf2)
        
        md2 = MD.init(period: period2, startValue: position1.marketValue, endValue: position2.marketValue, cashflowMap: cfm2)!
        
        expected2 = MyBaseline(period: period2,
                               performance: md2.performance,
                               startValue: position1.marketValue,
                               endValue: position2.marketValue,
                               netCashflow: ncf2)
                
        snapshotBaselineMap = MValuationCashflow.getSnapshotBaselineMap(snapshotKeys: ax.orderedSnapshotKeys,
                                                                        snapshotDateIntervalMap: ax.snapshotDateIntervalMap,
                                                                        snapshotPositionsMap: ax.snapshotPositionsMap,
                                                                        snapshotCashflowsMap: ax.snapshotCashflowsMap)
        
        mdPre = getMD()
    }
    
    func postConsolidateSetup() {
        model.consolidateCashflow(snapshotBaselineMap: snapshotBaselineMap, accountMap: ax.accountMap, assetMap: ax.assetMap)
        ax = WorthContext(model)  // rebuild the context
        
        mdPost = getMD()
    }
    
    // calculate performance across all snapshots
    func getMD() -> MD {
        let cashflowMap = MValuationCashflow.getCashflowMap(ax.orderedCashflow)
        return MD.init(period: DateInterval(start: timestamp1A, end: timestamp4),
                       startValue: position1.marketValue,
                       endValue: position2.marketValue,
                       cashflowMap: cashflowMap)!
    }
    
    func testA() throws {
        cashflow1 = MValuationCashflow(transactedAt: timestamp2, accountID: "1", assetID: "Bond", amount: 100)
        cashflow2 = MValuationCashflow(transactedAt: timestamp3, accountID: "1", assetID: "Bond", amount: -50) // +50 for snapshot
        
        preConsolidateSetup()
        
        // generate a expected baseline for FIRST snapshot
        XCTAssertEqual(-0.1809, md2.performance, accuracy: 0.0001)
        XCTAssertEqual(0.3103, expected2.rawWeight, accuracy: 0.0001)
        XCTAssertEqual(0.3103, expected2.weight, accuracy: 0.0001)
        
        // PRE-CONSOLIDATION calculate the MD across single snapshot
        XCTAssertEqual(50.0, mdPre.netCashflowTotal, accuracy: 0.01)
        XCTAssertEqual(-350.0, mdPre.gainOrLoss, accuracy: 0.01)
        XCTAssertEqual(34.48, mdPre.adjustedNetCashflow, accuracy: 0.01)
        XCTAssertEqual(1934.48, mdPre.averageCapital, accuracy: 0.01)
        XCTAssertEqual(-0.1809, mdPre.performance, accuracy: 0.0001)
        
        // generate the baseline map(s) from the model, and verify
        let expected: SnapshotAccountAssetBaselineMap = [snapshot2.primaryKey: [accountAssetKey: expected2]]
        XCTAssertEqual(expected, snapshotBaselineMap)
        
        postConsolidateSetup()

        XCTAssertEqual(1, model.valuationCashflows.count)
        let expectedCF1 = MValuationCashflow(transactedAt: expected2.netDate, accountID: "1", assetID: "Bond", amount: ncf2)
        let cfItems = model.orderedCashflowItems
        XCTAssertEqual(expectedCF1.primaryKey, cfItems[0].primaryKey)
        XCTAssertEqual(expectedCF1.amount, cfItems[0].amount, accuracy: 0.01)
        
        // POST-CONSOLIDATION calculate the MD across single snapshot
        XCTAssertEqual(50.0, mdPost.netCashflowTotal, accuracy: 0.01)
        XCTAssertEqual(-350.0, mdPost.gainOrLoss, accuracy: 0.01)
        XCTAssertEqual(34.48, mdPost.adjustedNetCashflow, accuracy: 0.01)
        XCTAssertEqual(1934.48, mdPost.averageCapital, accuracy: 0.01)
        XCTAssertEqual(-0.1809, mdPost.performance, accuracy: 0.0001)

        XCTAssertEqual(mdPre.performance, mdPost.performance, accuracy: 0.001)
    }
    
    func testB() throws {
        cashflow1 = MValuationCashflow(transactedAt: timestamp2, accountID: "1", assetID: "Bond", amount: -100)
        cashflow2 = MValuationCashflow(transactedAt: timestamp3, accountID: "1", assetID: "Bond", amount: 50) // -50 for snapshot
        
        preConsolidateSetup()
        
        // generate a expected baseline for FIRST snapshot
        XCTAssertEqual(-0.1340, md2.performance, accuracy: 0.0001)
        XCTAssertEqual(0.3103, expected2.rawWeight, accuracy: 0.0001)
        XCTAssertEqual(0.3103, expected2.weight, accuracy: 0.0001)
        
        // PRE-CONSOLIDATION calculate the MD across single snapshot
        XCTAssertEqual(-50.0, mdPre.netCashflowTotal, accuracy: 0.01)
        XCTAssertEqual(-250.0, mdPre.gainOrLoss, accuracy: 0.01)
        XCTAssertEqual(-34.48, mdPre.adjustedNetCashflow, accuracy: 0.01)
        XCTAssertEqual(1865.52, mdPre.averageCapital, accuracy: 0.01)
        XCTAssertEqual(-0.1340, mdPre.performance, accuracy: 0.0001)
                
        let expected: SnapshotAccountAssetBaselineMap = [snapshot2.primaryKey: [accountAssetKey: expected2]]
        XCTAssertEqual(expected, snapshotBaselineMap)
        
        postConsolidateSetup()

        XCTAssertEqual(1, model.valuationCashflows.count)
        let expectedCF1 = MValuationCashflow(transactedAt: expected2.netDate, accountID: "1", assetID: "Bond", amount: ncf2)
        let cfItems = model.orderedCashflowItems
        XCTAssertEqual(expectedCF1.primaryKey, cfItems[0].primaryKey)
        XCTAssertEqual(expectedCF1.amount, cfItems[0].amount, accuracy: 0.01)
        
        // POST-CONSOLIDATION calculate the MD across single snapshot
        XCTAssertEqual(-50.0, mdPost.netCashflowTotal, accuracy: 0.01)
        XCTAssertEqual(-250.0, mdPost.gainOrLoss, accuracy: 0.01)
        XCTAssertEqual(-34.48, mdPost.adjustedNetCashflow, accuracy: 0.01)
        XCTAssertEqual(1865.52, mdPost.averageCapital, accuracy: 0.01)
        XCTAssertEqual(-0.1340, mdPost.performance, accuracy: 0.0001)

        XCTAssertEqual(mdPre.performance, mdPost.performance, accuracy: 0.001)
    }
        
    func test0NCF() throws {
        cashflow1 = MValuationCashflow(transactedAt: timestamp2, accountID: "1", assetID: "Bond", amount: 50)
        cashflow2 = MValuationCashflow(transactedAt: timestamp3, accountID: "1", assetID: "Bond", amount: -50)
        
        preConsolidateSetup()
        
        // generate a expected baseline for FIRST snapshot
        XCTAssertEqual(-0.1572, md2.performance, accuracy: 0.0001)
        XCTAssertEqual(1.0, expected2.rawWeight, accuracy: 0.0001)
        XCTAssertEqual(1.0, expected2.weight, accuracy: 0.0001)
        
        // PRE-CONSOLIDATION calculate the MD across single snapshot
        XCTAssertEqual(0.0, mdPre.netCashflowTotal, accuracy: 0.01)
        XCTAssertEqual(-300.0, mdPre.gainOrLoss, accuracy: 0.01)
        XCTAssertEqual(8.62, mdPre.adjustedNetCashflow, accuracy: 0.01)
        XCTAssertEqual(1908.62, mdPre.averageCapital, accuracy: 0.01)
        XCTAssertEqual(-0.1572, mdPre.performance, accuracy: 0.0001)
        
        // generate the baseline map(s) from the model, and verify
        let expected: SnapshotAccountAssetBaselineMap = [:]
        XCTAssertEqual(expected, snapshotBaselineMap)
        
        postConsolidateSetup()
        
        XCTAssertEqual(0, model.valuationCashflows.count)
        
        // POST-CONSOLIDATION calculate the MD across single snapshot
        XCTAssertEqual(0.0, mdPost.netCashflowTotal, accuracy: 0.01)
        XCTAssertEqual(-300.0, mdPost.gainOrLoss, accuracy: 0.01)
        XCTAssertEqual(0, mdPost.adjustedNetCashflow, accuracy: 0.01)
        XCTAssertEqual(1900, mdPost.averageCapital, accuracy: 0.01)
        XCTAssertEqual(-0.1578, mdPost.performance, accuracy: 0.0001)

        XCTAssertEqual(mdPre.performance, mdPost.performance, accuracy: 0.001)
    }
    
    func testPerformanceOf0AndNonZeroCF() throws {
        cashflow1 = MValuationCashflow(transactedAt: timestamp2, accountID: "1", assetID: "Bond", amount: 100)
        cashflow2 = MValuationCashflow(transactedAt: timestamp3, accountID: "1", assetID: "Bond", amount: -50) // +50 for snapshot
        
        // override default positions
        position1 = MValuationPosition(snapshotID: "1", accountID: "1", assetID: "Bond", totalBasis: 1, marketValue: 1900)
        position2 = MValuationPosition(snapshotID: "2", accountID: "1", assetID: "Bond", totalBasis: 1, marketValue: 1950)
        
        preConsolidateSetup()
        
        // generate a expected baseline for FIRST snapshot
        XCTAssertEqual(0, md2.performance, accuracy: 0.0001)
        XCTAssertEqual(1, expected2.rawWeight, accuracy: 0.0001)
        XCTAssertEqual(1, expected2.weight, accuracy: 0.0001)
        
        // PRE-CONSOLIDATION calculate the MD across single snapshot
        XCTAssertEqual(50.0, mdPre.netCashflowTotal, accuracy: 0.01)
        XCTAssertEqual(0, mdPre.gainOrLoss, accuracy: 0.01)
        XCTAssertEqual(34.48, mdPre.adjustedNetCashflow, accuracy: 0.01)
        XCTAssertEqual(1934.48, mdPre.averageCapital, accuracy: 0.01)
        XCTAssertEqual(0, mdPre.performance, accuracy: 0.0001)
                
        let expected: SnapshotAccountAssetBaselineMap = [snapshot2.primaryKey: [accountAssetKey: expected2]]
        XCTAssertEqual(expected, snapshotBaselineMap)
        
        postConsolidateSetup()

        XCTAssertEqual(1, model.valuationCashflows.count)
        let expectedCF1 = MValuationCashflow(transactedAt: expected2.netDate, accountID: "1", assetID: "Bond", amount: ncf2)
        let cfItems = model.orderedCashflowItems
        XCTAssertEqual(expectedCF1.primaryKey, cfItems[0].primaryKey)
        XCTAssertEqual(expectedCF1.amount, cfItems[0].amount, accuracy: 0.01)
        
        // POST-CONSOLIDATION calculate the MD across single snapshot
        XCTAssertEqual(50.0, mdPost.netCashflowTotal, accuracy: 0.01)
        XCTAssertEqual(0, mdPost.gainOrLoss, accuracy: 0.01)
        XCTAssertEqual(0, mdPost.adjustedNetCashflow, accuracy: 0.01)
        XCTAssertEqual(1900, mdPost.averageCapital, accuracy: 0.01)
        XCTAssertEqual(0, mdPost.performance, accuracy: 0.0001)

        XCTAssertEqual(mdPre.performance, mdPost.performance, accuracy: 0.001)
    }
    
    func testPerformanceOf0AndZeroCF() throws {
        cashflow1 = MValuationCashflow(transactedAt: timestamp2, accountID: "1", assetID: "Bond", amount: -50)
        cashflow2 = MValuationCashflow(transactedAt: timestamp3, accountID: "1", assetID: "Bond", amount: 50) // +0 for snapshot
        
        // override default positions
        position1 = MValuationPosition(snapshotID: "1", accountID: "1", assetID: "Bond", totalBasis: 1, marketValue: 1900)
        position2 = MValuationPosition(snapshotID: "2", accountID: "1", assetID: "Bond", totalBasis: 1, marketValue: 1900)
        
        preConsolidateSetup()
        
        // generate a expected baseline for FIRST snapshot
        XCTAssertEqual(0, md2.performance, accuracy: 0.0001)
        XCTAssertEqual(1, expected2.rawWeight, accuracy: 0.0001)
        XCTAssertEqual(1, expected2.weight, accuracy: 0.0001)
        
        // PRE-CONSOLIDATION calculate the MD across single snapshot
        XCTAssertEqual(0, mdPre.netCashflowTotal, accuracy: 0.01)
        XCTAssertEqual(0, mdPre.gainOrLoss, accuracy: 0.01)
        XCTAssertEqual(-8.62, mdPre.adjustedNetCashflow, accuracy: 0.01)
        XCTAssertEqual(1891.38, mdPre.averageCapital, accuracy: 0.01)
        XCTAssertEqual(0, mdPre.performance, accuracy: 0.0001)
                
        let expected: SnapshotAccountAssetBaselineMap = [:]
        XCTAssertEqual(expected, snapshotBaselineMap)
        
        postConsolidateSetup()

        XCTAssertEqual(0, model.valuationCashflows.count)
        
        // POST-CONSOLIDATION calculate the MD across single snapshot
        XCTAssertEqual(0, mdPost.netCashflowTotal, accuracy: 0.01)
        XCTAssertEqual(0, mdPost.gainOrLoss, accuracy: 0.01)
        XCTAssertEqual(0, mdPost.adjustedNetCashflow, accuracy: 0.01)
        XCTAssertEqual(1900, mdPost.averageCapital, accuracy: 0.01)
        XCTAssertEqual(0, mdPost.performance, accuracy: 0.0001)

        XCTAssertEqual(mdPre.performance, mdPost.performance, accuracy: 0.001)
    }

}
